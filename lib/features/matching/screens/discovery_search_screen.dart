import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../../core/providers/discovery_provider.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import '../../mentor/widgets/peer_profile_card.dart';

/// Discovery Search — filter by language, timezone, stage, gifts, availability.
class DiscoverySearchScreen extends ConsumerStatefulWidget {
  const DiscoverySearchScreen({super.key});

  @override
  ConsumerState<DiscoverySearchScreen> createState() =>
      _DiscoverySearchScreenState();
}

class _DiscoverySearchScreenState
    extends ConsumerState<DiscoverySearchScreen> {
  DiscoveryFilters _filters = const DiscoveryFilters();

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(discoveryResultsProvider(_filters));

    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        elevation: 0,
        leading: const BackButton(color: AppColors.textDark),
        title: Text(
          'Browse peers',
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: Semantics(
              button: true,
              label: 'Open filters',
              child: GestureDetector(
                onTap: () => _openFilters(context),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.tune,
                          size: 16.sp, color: AppColors.primaryGreen),
                      SizedBox(width: 4.w),
                      Text('Filter',
                          style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Active filter chips
          if (_filters.hasAny) _FilterChips(filters: _filters, onClear: _clearFilters),

          Expanded(
            child: resultsAsync.when(
              loading: () => const LoadingSkeleton(),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (peers) {
                if (peers.isEmpty) {
                  return _EmptyResults(
                    onClearFilters: _filters.hasAny ? _clearFilters : null,
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.all(16.r),
                  itemCount: peers.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (_, i) => PeerProfileCard(
                    peer: peers[i].user,
                    compatibilityScore: peers[i].score,
                    onRequest: () {
                      // TODO: show request dialog
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _clearFilters() =>
      setState(() => _filters = const DiscoveryFilters());

  void _openFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cream,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r))),
      builder: (_) => _FilterSheet(
        filters: _filters,
        onApply: (f) {
          setState(() => _filters = f);
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ── Filter chips row ──────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  final DiscoveryFilters filters;
  final VoidCallback onClear;
  const _FilterChips({required this.filters, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (filters.language != null)
                  _Chip('🗣 ${filters.language}'),
                if (filters.timezoneRange != null)
                  _Chip('🕐 ±${filters.timezoneRange}h'),
                if (filters.sameCountry)
                  _Chip('📍 Same country'),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClear,
            child: Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: Text('Clear',
                  style: TextStyle(
                      fontSize: 12.sp, color: AppColors.textMuted)),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  const _Chip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11.sp, color: AppColors.primaryGreen)),
    );
  }
}

// ── Filter sheet ──────────────────────────────────────────────────────────────

class _FilterSheet extends StatefulWidget {
  final DiscoveryFilters filters;
  final ValueChanged<DiscoveryFilters> onApply;
  const _FilterSheet({required this.filters, required this.onApply});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late DiscoveryFilters _f;

  @override
  void initState() {
    super.initState();
    _f = widget.filters;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Filters',
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark)),
          SizedBox(height: 20.h),

          // Language
          Text('Language',
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMid)),
          SizedBox(height: 8.h),
          _LanguagePicker(
            selected: _f.language,
            onChanged: (lang) => setState(() => _f = _f.copyWith(language: lang)),
          ),

          SizedBox(height: 16.h),

          // Same country toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Same country',
                  style: TextStyle(
                      fontSize: 13.sp, color: AppColors.textDark)),
              Switch(
                value: _f.sameCountry,
                onChanged: (v) =>
                    setState(() => _f = _f.copyWith(sameCountry: v)),
                activeColor: AppColors.primaryGreen,
              ),
            ],
          ),

          SizedBox(height: 20.h),

          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Reset',
                  onPressed: () =>
                      widget.onApply(const DiscoveryFilters()),
                  variant: AppButtonVariant.outlined,
                  compact: true,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: AppButton(
                  label: 'Apply filters',
                  onPressed: () => widget.onApply(_f),
                  compact: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LanguagePicker extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _LanguagePicker({required this.selected, required this.onChanged});

  static const _kLanguages = [
    'English', 'Español', 'Français', 'Deutsch',
    'Português', 'Kiswahili', 'Arabic', 'Hindi',
    'Chinese', 'Amharic', 'Hausa', 'Yoruba',
    'Igbo', 'Russian', 'Korean',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _kLanguages.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final lang = _kLanguages[i];
          final active = selected == lang;
          return GestureDetector(
            onTap: () => onChanged(active ? null : lang),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: active ? AppColors.primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(
                  color: active ? AppColors.primaryGreen : AppColors.borderBeige,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                lang,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: active ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  final VoidCallback? onClearFilters;
  const _EmptyResults({this.onClearFilters});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🌿', style: TextStyle(fontSize: 48.sp)),
          SizedBox(height: 12.h),
          Text('No peers found',
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark)),
          SizedBox(height: 6.h),
          Text(
            'Try broadening your filters or come back later.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted),
          ),
          if (onClearFilters != null) ...[
            SizedBox(height: 16.h),
            AppButton(
              label: 'Clear filters',
              onPressed: onClearFilters,
              compact: true,
              variant: AppButtonVariant.outlined,
            ),
          ],
        ],
      ),
    );
  }
}
