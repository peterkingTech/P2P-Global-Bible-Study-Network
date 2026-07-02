import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';

// ── Static nation data ────────────────────────────────────────────────────────

const _kNations = [
  (name: 'North Korea', category: 'Persecution', description: 'The most restricted nation for Christians on Earth. Pray for underground churches.', emoji: '🇰🇵'),
  (name: 'Afghanistan', category: 'Unreached', description: 'Less than 0.1% Christian. Pray for the Pashtun, Tajik, and Hazara peoples.', emoji: '🇦🇫'),
  (name: 'Somalia', category: 'Conflict', description: 'Decades of civil war. Pray for peace and open doors for the gospel.', emoji: '🇸🇴'),
  (name: 'Yemen', category: 'Crisis', description: 'Humanitarian crisis. Pray for aid workers and secret believers.', emoji: '🇾🇪'),
  (name: 'Maldives', category: 'Unreached', description: '100% Muslim island nation. No known churches. Pray for diaspora witnesses.', emoji: '🇲🇻'),
];

/// A single "Stand in the Gap" card for a dark / unreached nation.
class DarkNationCard extends StatefulWidget {
  final int index;
  const DarkNationCard({super.key, required this.index});

  @override
  State<DarkNationCard> createState() => _DarkNationCardState();
}

class _DarkNationCardState extends State<DarkNationCard> {
  bool _committed = false;

  @override
  Widget build(BuildContext context) {
    final n = _kNations[widget.index % _kNations.length];

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: _committed
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
              if (_committed)
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
            onTap: () => setState(() => _committed = !_committed),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: _committed
                    ? AppColors.accentGreen
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(
                  color: _committed
                      ? AppColors.accentGreen
                      : AppColors.borderBeige,
                ),
              ),
              child: Text(
                _committed ? '🛡️ Standing in the gap' : 'Stand in the gap',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: _committed ? Colors.white : AppColors.textMid,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
