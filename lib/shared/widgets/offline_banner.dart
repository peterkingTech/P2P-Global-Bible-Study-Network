import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/providers/connectivity_provider.dart';

/// A slim banner that appears at the top of the screen when offline.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    return AnimatedSlide(
      offset: isOnline ? const Offset(0, -1) : Offset.zero,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: isOnline ? 0 : 1,
        duration: const Duration(milliseconds: 300),
        child: Container(
          width: double.infinity,
          color: Colors.orangeAccent,
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
          child: Row(
            children: [
              Icon(Icons.wifi_off, size: 14.sp, color: Colors.white),
              SizedBox(width: 8.w),
              Text(
                'You\'re offline — changes will sync when reconnected.',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
