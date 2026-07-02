import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../core/models/prayer_model.dart';
import '../../../core/providers/prayer_provider.dart';
import '../widgets/prayer_request_card.dart';

/// Nation Prayer Wall — scrollable cards filtered by region/category.
class NationPrayerWallScreen extends ConsumerStatefulWidget {
  const NationPrayerWallScreen({super.key});

  @override
  ConsumerState<NationPrayerWallScreen> createState() =>
      _NationPrayerWallScreenState();
}

class _NationPrayerWallScreenState
    extends ConsumerState<NationPrayerWallScreen> {
  PrayerCategory? _filter;

  @override
  Widget build(BuildContext context) {
    final wallAsync = ref.watch(prayerWallProvider);

    return Scaffold(
      backgroundColor: AppColors.upperRoomBg,
      appBar: AppBar(
        backgroundColor: AppColors.upperRoomBg,
        elevation: 0,
        leading: const BackButton(color: AppColors.upperRoomCream),
        title: Text(
          'Nation Prayer Wall',
          style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.upperRoomCream),
        ),
      ),
      body: Column(
        children: [
          // Category filter chips
          SizedBox(
            height: 44.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: [
                _FilterChip(
                  label: 'All',
                  active: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                ...PrayerCategory.values.map((c) => _FilterChip(
                      label: c.name[0].toUpperCase() + c.name.substring(1),
                      active: _filter == c,
                      onTap: () =>
                          setState(() => _filter = _filter == c ? null : c),
                    )),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          Expanded(
            child: wallAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.upperRoomAmber)),
              error: (e, _) => Center(
                  child: Text('Error: $e',
                      style: const TextStyle(color: Colors.white70))),
              data: (prayers) {
                final filtered = _filter == null
                    ? prayers
                    : prayers
                        .where((p) => p.category == _filter)
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No requests yet.\nBe the first to pray.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14.sp, color: AppColors.upperRoomMuted),
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.all(16.r),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (_, i) => PrayerRequestCard(
                    prayer: filtered[i],
                    onPrayed: () => ref
                        .read(prayerNotifierProvider.notifier)
                        .markPrayed(filtered[i].id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.w),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: active
                ? AppColors.upperRoomAmber
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(999.r),
            border: Border.all(
              color: active
                  ? AppColors.upperRoomAmber
                  : AppColors.upperRoomBorder,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: active ? const Color(0xFF100B06) : AppColors.upperRoomMuted,
            ),
          ),
        ),
      ),
    );
  }
}
