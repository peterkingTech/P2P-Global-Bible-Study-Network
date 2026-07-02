import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/theme.dart';

// ── Curated unreached / persecuted nation prayer targets ─────────────────────
// These are real prayer information sourced from Open Doors World Watch List.

const _kNations = [
  (
    id: 'north_korea',
    name: 'North Korea',
    category: 'Persecution',
    description:
        'The most restricted nation for Christians on Earth. Over 70,000 believers in prison camps. Pray for underground churches.',
    emoji: '🇰🇵',
  ),
  (
    id: 'afghanistan',
    name: 'Afghanistan',
    category: 'Unreached',
    description:
        'Less than 0.1% Christian. The Pashtun, Tajik, and Hazara peoples remain largely without the gospel. Pray for workers.',
    emoji: '🇦🇫',
  ),
  (
    id: 'somalia',
    name: 'Somalia',
    category: 'Conflict',
    description:
        'Decades of civil war have devastated communities. Pray for peace and open doors for the gospel among the Somali people.',
    emoji: '🇸🇴',
  ),
  (
    id: 'yemen',
    name: 'Yemen',
    category: 'Crisis',
    description:
        'Catastrophic humanitarian crisis. Pray for aid workers, secret believers, and an outpouring of the Spirit.',
    emoji: '🇾🇪',
  ),
  (
    id: 'maldives',
    name: 'Maldives',
    category: 'Unreached',
    description:
        'Officially 100% Muslim island nation. No registered churches. Pray for diaspora witnesses and digital evangelism.',
    emoji: '🇲🇻',
  ),
];

// ── Provider: tracks which nations the current user has committed to pray for ─

final _nationCommitmentsProvider =
    StateNotifierProvider<_NationCommitmentsNotifier, Set<String>>(
        (_) => _NationCommitmentsNotifier());

class _NationCommitmentsNotifier extends StateNotifier<Set<String>> {
  _NationCommitmentsNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final rows = await Supabase.instance.client
          .from('mission_commitments')
          .select('nation_id')
          .eq('user_id', user.id);
      state = {for (final r in (rows as List)) r['nation_id'] as String};
    } catch (_) {
      // Offline — start empty; will sync when reconnected
    }
  }

  Future<void> toggle(String nationId) async {
    final user = Supabase.instance.client.auth.currentUser;
    final isCommitted = state.contains(nationId);

    // Optimistic update
    final next = Set<String>.from(state);
    if (isCommitted) {
      next.remove(nationId);
    } else {
      next.add(nationId);
    }
    state = next;

    if (user == null) return;
    try {
      if (isCommitted) {
        await Supabase.instance.client
            .from('mission_commitments')
            .delete()
            .eq('user_id', user.id)
            .eq('nation_id', nationId);
      } else {
        await Supabase.instance.client.from('mission_commitments').upsert({
          'user_id': user.id,
          'nation_id': nationId,
          'committed_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (_) {
      // Revert on failure
      state = isCommitted
          ? {...state, nationId}
          : {...state}..remove(nationId);
    }
  }
}

/// A single "Stand in the Gap" card for a dark / unreached nation.
class DarkNationCard extends ConsumerWidget {
  final int index;
  const DarkNationCard({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = _kNations[index % _kNations.length];
    final committed = ref.watch(_nationCommitmentsProvider).contains(n.id);
    final notifier = ref.read(_nationCommitmentsProvider.notifier);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: committed
              ? AppColors.accentGreen.withOpacity(0.4)
              : AppColors.borderBeige,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(n.emoji, style: TextStyle(fontSize: 24.sp)),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      n.name,
                      style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 7.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        n.category,
                        style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.amber),
                      ),
                    ),
                  ],
                ),
              ),
              if (committed)
                Icon(Icons.shield, size: 20.sp, color: AppColors.accentGreen),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            n.description,
            style: TextStyle(
                fontSize: 13.sp, height: 1.55, color: AppColors.textMid),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () => notifier.toggle(n.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: committed
                    ? AppColors.accentGreen
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(
                  color: committed
                      ? AppColors.accentGreen
                      : AppColors.borderBeige,
                ),
              ),
              child: Text(
                committed ? '🛡️ Standing in the gap' : 'Stand in the gap',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: committed ? Colors.white : AppColors.textMid,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
