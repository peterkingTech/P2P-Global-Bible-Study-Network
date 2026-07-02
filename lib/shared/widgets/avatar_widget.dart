import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../config/theme.dart';

/// Circular avatar with a [Image.network] image and an initials fallback.
///
/// Displays initials in a coloured circle when [imageUrl] is null or fails
/// to load. Drop-in replacement for CachedNetworkImage-based avatars.
class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String displayName;
  final double size;
  final Color? bgColor;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    required this.displayName,
    this.size = 40,
    this.bgColor,
  });

  String get _initials {
    final parts = displayName.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final bg = bgColor ?? AppColors.primaryGreen;

    return ClipOval(
      child: SizedBox(
        width: size.w,
        height: size.w,
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                width: size.w,
                height: size.w,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _Initials(
                  initials: _initials,
                  bg: bg,
                  size: size,
                ),
                loadingBuilder: (_, child, progress) {
                  if (progress == null) return child;
                  return _Initials(initials: _initials, bg: bg, size: size);
                },
              )
            : _Initials(initials: _initials, bg: bg, size: size),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String initials;
  final Color bg;
  final double size;

  const _Initials({
    required this.initials,
    required this.bg,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      color: bg.withAlpha(51),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: bg,
            fontSize: (size * 0.38).sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
