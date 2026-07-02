import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/animations/harvest_celebration_overlay.dart';


/// Mega Harvest — a global synchronised prayer event where all active users
/// pray the same Scripture passage simultaneously across timezones.
///
/// TODO: Implement Supabase realtime presence channel for live participant
/// count and synchronised countdown start.
class MegaHarvestScreen extends ConsumerStatefulWidget {
  const MegaHarvestScreen({super.key});

  @override
  ConsumerState<MegaHarvestScreen> createState() => _MegaHarvestScreenState();
}

class _MegaHarvestScreenState extends ConsumerState<MegaHarvestScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _joined = false;
  int _participants = 1247;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _join() {
    setState(() {
      _joined = true;
      _participants++;
    });
    HarvestCelebrationOverlay.show(
      context,
      milestone: 'You\'re praying alongside $_participants believers worldwide!',
      emoji: '🌾',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF06110D),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            children: [
              // ── Nav bar ────────────────────────────────────────────────
              Align(
                alignment: Alignment.centerLeft,
                child: BackButton(color: Colors.white70),
              ),
              const Spacer(),

              // ── Pulsing globe icon ────────────────────────────────────
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) => Container(
                  width: 140.w,
                  height: 140.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryGreen
                        .withOpacity(0.1 + _pulse.value * 0.12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen
                            .withOpacity(0.3 + _pulse.value * 0.3),
                        blurRadius: 40 + _pulse.value * 20,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text('🌾', style: TextStyle(fontSize: 64.sp)),
                  ),
                ),
              ),
              SizedBox(height: 36.h),

              // ── Title ─────────────────────────────────────────────────
              Text(
                'Mega Harvest',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '"The harvest is plentiful, but the workers are few."\n— Matthew 9:37',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white60,
                  fontStyle: FontStyle.italic,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 28.h),

              // ── Participant count ─────────────────────────────────────
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 24.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(40.r),
                  border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '$_participants praying now',
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── CTA ───────────────────────────────────────────────────
              if (!_joined)
                AppButton(
                  label: 'Join the Harvest',
                  onPressed: _join,
                )
              else ...[
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                        color: AppColors.primaryGreen.withOpacity(0.4)),
                  ),
                  child: Text(
                    '🙏  You\'re praying with the global body.\nStay on this screen to stay connected.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: Colors.white,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
