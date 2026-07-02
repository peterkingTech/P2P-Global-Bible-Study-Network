import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../widgets/prayer_stream_player.dart';

// ── Mock data ─────────────────────────────────────────────────────────────────

const _kRooms = [
  (
    name: 'English — Global Intercession',
    language: 'en',
    flag: '🌍',
    participants: 47,
    durationMin: 62,
  ),
  (
    name: 'Deutsch — Gebet für Europa',
    language: 'de',
    flag: '🇩🇪',
    participants: 12,
    durationMin: 28,
  ),
  (
    name: 'Français — Prière pour l\'Afrique',
    language: 'fr',
    flag: '🇫🇷',
    participants: 31,
    durationMin: 45,
  ),
  (
    name: 'Español — Avivamiento',
    language: 'es',
    flag: '🇪🇸',
    participants: 24,
    durationMin: 18,
  ),
  (
    name: 'Kiswahili — Maombi ya Afrika',
    language: 'sw',
    flag: '🇰🇪',
    participants: 19,
    durationMin: 90,
  ),
];

/// List of live prayer rooms the user can join.
class LivePrayerRoomsScreen extends ConsumerWidget {
  const LivePrayerRoomsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.upperRoomBg,
      appBar: AppBar(
        backgroundColor: AppColors.upperRoomBg,
        elevation: 0,
        leading: const BackButton(color: AppColors.upperRoomCream),
        title: Text(
          'Live Prayer Rooms',
          style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.upperRoomCream),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 24/7 stream player
            Padding(
              padding: EdgeInsets.all(16.r),
              child: const PrayerStreamPlayer(),
            ),

            Divider(color: AppColors.upperRoomBorder, height: 1),

            // Rooms list
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.all(16.r),
                itemCount: _kRooms.length,
                separatorBuilder: (_, __) => SizedBox(height: 10.h),
                itemBuilder: (_, i) => _RoomCard(room: _kRooms[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final ({String name, String language, String flag, int participants, int durationMin}) room;
  const _RoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.upperRoomCard,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.upperRoomBorder),
      ),
      child: Row(
        children: [
          Text(room.flag, style: TextStyle(fontSize: 28.sp)),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.upperRoomCream,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    _Pill(
                      '${room.participants} praying',
                      color: AppColors.accentGreen,
                    ),
                    SizedBox(width: 6.w),
                    _Pill('${room.durationMin}m live', color: AppColors.upperRoomAmber),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          TextButton(
            onPressed: () {
              // TODO: join room (open audio/video session)
            },
            style: TextButton.styleFrom(
              backgroundColor: AppColors.upperRoomAmber.withOpacity(0.15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            ),
            child: Text(
              'Join',
              style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.upperRoomAmber),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;
  const _Pill(this.text, {required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        text,
        style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
            color: color),
      ),
    );
  }
}
