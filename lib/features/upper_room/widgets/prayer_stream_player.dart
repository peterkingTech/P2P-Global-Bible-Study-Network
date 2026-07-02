import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';

/// Compact audio stream player for the 24/7 prayer streams.
/// Animated waveform bars while playing; tap play/pause to toggle.
class PrayerStreamPlayer extends StatefulWidget {
  final String? streamUrl;
  const PrayerStreamPlayer({super.key, this.streamUrl});

  @override
  State<PrayerStreamPlayer> createState() => _PrayerStreamPlayerState();
}

class _PrayerStreamPlayerState extends State<PrayerStreamPlayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave;
  bool _playing = false;

  // Bar heights cycle (8 bars)
  static const _kBars = [0.4, 0.7, 0.5, 1.0, 0.6, 0.8, 0.45, 0.65];

  @override
  void initState() {
    super.initState();
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _playing = !_playing);
    if (_playing) {
      _wave.repeat(reverse: true);
      // TODO: start audio stream via url_launcher or audio_service
    } else {
      _wave.stop();
      _wave.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.upperRoomCard,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.upperRoomBorder),
      ),
      child: Row(
        children: [
          // Play/Pause button
          Semantics(
            button: true,
            label: _playing ? 'Pause prayer stream' : 'Play prayer stream',
            child: GestureDetector(
              onTap: _toggle,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _playing
                      ? AppColors.upperRoomAmber
                      : Colors.white.withOpacity(0.1),
                  border: Border.all(
                    color: AppColors.upperRoomAmber.withOpacity(0.4),
                  ),
                ),
                child: Icon(
                  _playing ? Icons.pause : Icons.play_arrow,
                  color: _playing
                      ? const Color(0xFF100B06)
                      : AppColors.upperRoomAmber,
                  size: 20.sp,
                ),
              ),
            ),
          ),

          SizedBox(width: 14.w),

          // Stream info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '24/7 Prayer Stream',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.upperRoomCream,
                  ),
                ),
                Text(
                  _playing ? 'Now streaming…' : 'Tap to join',
                  style: TextStyle(
                      fontSize: 11.sp, color: AppColors.upperRoomMuted),
                ),
              ],
            ),
          ),

          SizedBox(width: 14.w),

          // Waveform bars
          AnimatedBuilder(
            animation: _wave,
            builder: (_, __) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: _kBars.asMap().entries.map((e) {
                  final base = e.value;
                  final animated = _playing
                      ? base * (0.4 + 0.6 * (((_wave.value + e.key * 0.13) % 1.0)))
                      : base * 0.25;
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.5.w),
                    child: Container(
                      width: 3.w,
                      height: 20.h * animated,
                      decoration: BoxDecoration(
                        color: AppColors.upperRoomAmber.withOpacity(
                            _playing ? 0.8 : 0.3),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
