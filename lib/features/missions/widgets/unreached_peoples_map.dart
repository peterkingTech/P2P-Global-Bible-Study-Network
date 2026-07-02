import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';

// ── Static unreached people groups (Joshua Project subset) ────────────────────

const _kUnreached = [
  (name: 'Uyghur', country: 'China', population: '11M', religion: 'Islam', emoji: '🇨🇳'),
  (name: 'Pashtun', country: 'Afghanistan', population: '49M', religion: 'Islam', emoji: '🇦🇫'),
  (name: 'Bengali Muslim', country: 'Bangladesh', population: '130M', religion: 'Islam', emoji: '🇧🇩'),
  (name: 'Brahmin', country: 'India', population: '60M', religion: 'Hinduism', emoji: '🇮🇳'),
  (name: 'Somali', country: 'Somalia', population: '19M', religion: 'Islam', emoji: '🇸🇴'),
  (name: 'Berber', country: 'Algeria', population: '5M', religion: 'Islam', emoji: '🇩🇿'),
];

/// Compact scrollable list of unreached people groups with prayer prompt.
class UnreachedPeoplesMap extends StatelessWidget {
  const UnreachedPeoplesMap({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _kUnreached.length,
        separatorBuilder: (_, __) => SizedBox(width: 10.w),
        itemBuilder: (_, i) => _PeopleCard(group: _kUnreached[i]),
      ),
    );
  }
}

class _PeopleCard extends StatefulWidget {
  final ({String name, String country, String population, String religion, String emoji}) group;
  const _PeopleCard({required this.group});

  @override
  State<_PeopleCard> createState() => _PeopleCardState();
}

class _PeopleCardState extends State<_PeopleCard> {
  bool _prayed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _prayed = !_prayed),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 130.w,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: _prayed
              ? AppColors.accentGreen.withOpacity(0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: _prayed ? AppColors.accentGreen : AppColors.borderBeige,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(widget.group.emoji, style: TextStyle(fontSize: 18.sp)),
                const Spacer(),
                if (_prayed)
                  Text('🙏', style: TextStyle(fontSize: 14.sp)),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              widget.group.name,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.group.country,
              style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted),
            ),
            const Spacer(),
            Text(
              widget.group.population,
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.amber),
            ),
            Text(
              widget.group.religion,
              style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
