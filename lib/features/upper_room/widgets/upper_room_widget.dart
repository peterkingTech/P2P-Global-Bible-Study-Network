import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';
import '../../root_network/widgets/root_network_widget.dart';

// ─────────────────────────────────────────────────────────────────────────────
// UpperRoomWidget — mirrors upper-room.tsx
// Where the Church prays as one.
// ─────────────────────────────────────────────────────────────────────────────

class _PrayerRoom {
  final String id;
  final String nation;
  final String language;
  final int present;
  const _PrayerRoom(
      {required this.id,
      required this.nation,
      required this.language,
      required this.present});
}

class _WallRequest {
  final int id;
  final String nation;
  final String text;
  final String when;
  const _WallRequest(
      {required this.id,
      required this.nation,
      required this.text,
      required this.when});
}

const _kRooms = [
  _PrayerRoom(id: 'ng', nation: 'Nigeria', language: 'English · Yoruba', present: 42),
  _PrayerRoom(id: 'kr', nation: 'South Korea', language: 'Korean', present: 31),
  _PrayerRoom(id: 'br', nation: 'Brazil', language: 'Português', present: 28),
  _PrayerRoom(id: 'in', nation: 'India', language: 'Hindi · Tamil', present: 55),
  _PrayerRoom(id: 'ke', nation: 'Kenya', language: 'Swahili · English', present: 19),
  _PrayerRoom(id: 'de', nation: 'Germany', language: 'Deutsch', present: 12),
];

const _kInitialWall = [
  _WallRequest(
      id: 1,
      nation: 'Kenya',
      text: "For my father's health, that the Lord would grant healing and peace to our home.",
      when: '3m ago'),
  _WallRequest(
      id: 2,
      nation: 'Brazil',
      text: 'Wisdom for a hard decision this week. Pray I would seek Him first.',
      when: '11m ago'),
  _WallRequest(
      id: 3,
      nation: 'India',
      text: 'For our small gathering — that we would love one another well and stay faithful.',
      when: '24m ago'),
  _WallRequest(
      id: 4,
      nation: 'South Korea',
      text: 'Comfort for a friend who is grieving. May she know she is not alone.',
      when: '38m ago'),
];

const _kConfirmations = [
  'Someone prayed for you',
  'A believer in Nairobi lifted your name',
  'You were remembered in prayer',
  'Someone is praying with you now',
];

class UpperRoomWidget extends StatefulWidget {
  const UpperRoomWidget({super.key});

  @override
  State<UpperRoomWidget> createState() => _UpperRoomWidgetState();
}

class _UpperRoomWidgetState extends State<UpperRoomWidget> {
  bool _playing = false;
  int _streamSeconds = 0;
  String? _activeRoom;
  final List<_WallRequest> _wall = List.of(_kInitialWall);
  final TextEditingController _draftCtrl = TextEditingController();
  bool _recording = false;
  String? _confirmation;
  int _nextId = 100;
  int _confirmIndex = 0;

  Timer? _streamTimer;
  Timer? _confirmTimer;

  @override
  void initState() {
    super.initState();
    // First confirmation after 3.5s, then every 12s
    Future.delayed(const Duration(milliseconds: 3500), _showConfirmation);
    _confirmTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      _showConfirmation();
    });
  }

  void _showConfirmation() {
    if (!mounted) return;
    setState(
        () => _confirmation = _kConfirmations[_confirmIndex % _kConfirmations.length]);
    _confirmIndex++;
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _confirmation = null);
    });
  }

  void _togglePlayback() {
    setState(() => _playing = !_playing);
    if (_playing) {
      _streamTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _streamSeconds++);
      });
    } else {
      _streamTimer?.cancel();
    }
  }

  void _submitRequest() {
    final text = _draftCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _wall.insert(
        0,
        _WallRequest(id: _nextId++, nation: 'Your room', text: text, when: 'just now'),
      );
      _draftCtrl.clear();
    });
  }

  @override
  void dispose() {
    _streamTimer?.cancel();
    _confirmTimer?.cancel();
    _draftCtrl.dispose();
    super.dispose();
  }

  String get _mm => (_streamSeconds ~/ 60).toString().padLeft(2, '0');
  String get _ss => (_streamSeconds % 60).toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeroSection(),
              SizedBox(height: 20.h),
              _StreamPlayer(
                playing: _playing,
                mm: _mm,
                ss: _ss,
                onToggle: _togglePlayback,
              ),
              SizedBox(height: 16.h),
              _LivePrayerRooms(
                activeRoom: _activeRoom,
                onSelect: (id) =>
                    setState(() => _activeRoom = _activeRoom == id ? null : id),
              ),
              SizedBox(height: 16.h),
              _PrayerRequestInput(
                controller: _draftCtrl,
                recording: _recording,
                onToggleRecord: () =>
                    setState(() => _recording = !_recording),
                onSubmit: _submitRequest,
              ),
              SizedBox(height: 16.h),
              _NationPrayerWall(wall: _wall),
              SizedBox(height: 80.h),
            ],
          ),
        ),

        // Anonymous prayer confirmation toast
        if (_confirmation != null)
          Positioned(
            bottom: 24.h,
            left: 16.w,
            right: 16.w,
            child: Semantics(
              liveRegion: true,
              child: Center(
                child: AnimatedOpacity(
                  opacity: _confirmation != null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: AppColors.upperRoomCard.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(999.r),
                      border: Border.all(
                        color: AppColors.upperRoomAmber.withOpacity(0.30),
                      ),
                    ),
                    child: Text(
                      _confirmation!,
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: const Color(0xFFE8CF9C)),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Hero Section ──────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.upperRoomBg,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.upperRoomBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Root network at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 140.h,
            child: const RootNetworkWidget(),
          ),
          // Foreground content
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 36.h, 20.w, 100.h),
            child: Column(
              children: [
                Text(
                  'The Upper Room',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 3.5,
                    color: AppColors.upperRoomAmber,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Where the Church prays as one',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.upperRoomCream,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Beneath everything we build, a hidden root system of prayer runs quietly through every nation. Come and be still.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.6,
                    color: AppColors.upperRoomMuted.withOpacity(0.80),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stream Player ─────────────────────────────────────────────────────────────

class _StreamPlayer extends StatefulWidget {
  final bool playing;
  final String mm;
  final String ss;
  final VoidCallback onToggle;
  const _StreamPlayer(
      {required this.playing,
      required this.mm,
      required this.ss,
      required this.onToggle});

  @override
  State<_StreamPlayer> createState() => _StreamPlayerState();
}

class _StreamPlayerState extends State<_StreamPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _wave;

  @override
  void initState() {
    super.initState();
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _UrCard(
      child: Column(
        children: [
          Row(
            children: [
              // Play/Pause button
              GestureDetector(
                onTap: widget.onToggle,
                child: Semantics(
                  button: true,
                  label: widget.playing ? 'Pause prayer stream' : 'Play prayer stream',
                  child: Container(
                    width: 52.r,
                    height: 52.r,
                    decoration: const BoxDecoration(
                      color: AppColors.upperRoomAmber,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.playing ? Icons.pause : Icons.play_arrow,
                      color: AppColors.upperRoomCard,
                      size: 24.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 6.r,
                          height: 6.r,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.playing
                                ? AppColors.upperRoomAmber
                                : const Color(0xFF5C4A2A),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '24 / 7 Prayer Stream',
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                            color: AppColors.upperRoomAmber,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Continuous intercession · Global room',
                      style: TextStyle(
                          fontSize: 13.sp, color: AppColors.upperRoomCream),
                    ),
                  ],
                ),
              ),
              Text(
                '${widget.mm}:${widget.ss}',
                style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.upperRoomMuted.withOpacity(0.70)),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          // Waveform
          Semantics(
            excludeSemantics: true,
            child: AnimatedBuilder(
              animation: _wave,
              builder: (_, __) => SizedBox(
                height: 32.h,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(40, (i) {
                    final height = 0.20 +
                        (sin(i * 0.9) * sin(i * 0.9)) * 0.70;
                    final animated =
                        widget.playing ? (sin(_wave.value * 2 * pi + i * 0.7) + 1) / 2 : 0.0;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0.5.w),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: (height * 32 * (0.5 + animated * 0.5)).h,
                          decoration: BoxDecoration(
                            color: AppColors.upperRoomAmber
                                .withOpacity(widget.playing ? 0.40 : 0.15),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Live Prayer Rooms ─────────────────────────────────────────────────────────

class _LivePrayerRooms extends StatelessWidget {
  final String? activeRoom;
  final ValueChanged<String> onSelect;
  const _LivePrayerRooms(
      {required this.activeRoom, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final active = _kRooms.cast<_PrayerRoom?>()
        .firstWhere((r) => r?.id == activeRoom, orElse: () => null);

    return _UrCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Live prayer rooms',
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.upperRoomCream),
          ),
          SizedBox(height: 3.h),
          Text(
            'Join brothers and sisters gathered by nation and language.',
            style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.upperRoomMuted.withOpacity(0.70)),
          ),
          SizedBox(height: 14.h),
          // 2-column grid
          for (int r = 0; r < (_kRooms.length / 2).ceil(); r++) ...[
            Row(
              children: [
                for (int c = 0; c < 2; c++) ...[
                  if (r * 2 + c < _kRooms.length) ...[
                    Expanded(
                      child: _RoomTile(
                        room: _kRooms[r * 2 + c],
                        isActive: activeRoom == _kRooms[r * 2 + c].id,
                        onTap: () => onSelect(_kRooms[r * 2 + c].id),
                      ),
                    ),
                    if (c == 0) SizedBox(width: 8.w),
                  ],
                ],
              ],
            ),
            if (r < (_kRooms.length / 2).ceil() - 1) SizedBox(height: 8.h),
          ],
          if (active != null) ...[
            SizedBox(height: 14.h),
            AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: AppColors.upperRoomAmber.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'You have quietly joined the ${active.nation} room. May you sense His nearness here.',
                  style: TextStyle(
                      fontSize: 11.sp, color: const Color(0xFFE8CF9C)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RoomTile extends StatelessWidget {
  final _PrayerRoom room;
  final bool isActive;
  final VoidCallback onTap;
  const _RoomTile(
      {required this.room, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.upperRoomAmber.withOpacity(0.10)
              : AppColors.upperRoomBg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isActive
                ? AppColors.upperRoomAmber.withOpacity(0.60)
                : AppColors.upperRoomBorder,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.nation,
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.upperRoomCream),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    room.language,
                    style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.upperRoomMuted.withOpacity(0.70)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            Icon(Icons.people_outline,
                size: 13.sp, color: AppColors.upperRoomMuted),
            SizedBox(width: 3.w),
            Text(
              '${room.present}',
              style: TextStyle(
                  fontSize: 11.sp, color: AppColors.upperRoomMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Prayer Request Input ──────────────────────────────────────────────────────

class _PrayerRequestInput extends StatelessWidget {
  final TextEditingController controller;
  final bool recording;
  final VoidCallback onToggleRecord;
  final VoidCallback onSubmit;

  const _PrayerRequestInput({
    required this.controller,
    required this.recording,
    required this.onToggleRecord,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return _UrCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share a prayer request',
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.upperRoomCream),
          ),
          SizedBox(height: 3.h),
          Text(
            'Your request is shared gently and anonymously with those praying.',
            style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.upperRoomMuted.withOpacity(0.70)),
          ),
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.upperRoomBg,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: AppColors.upperRoomBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: controller,
                  minLines: 3,
                  maxLines: 5,
                  style: TextStyle(
                      fontSize: 13.sp, color: AppColors.upperRoomCream),
                  decoration: InputDecoration(
                    hintText: 'Write your request, or hold to speak…',
                    hintStyle: TextStyle(
                        color: const Color(0xFF8A7448), fontSize: 13.sp),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Voice button
                    GestureDetector(
                      onTap: onToggleRecord,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: recording
                              ? AppColors.upperRoomAmber.withOpacity(0.20)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.mic_none_outlined,
                                size: 16.sp,
                                color: recording
                                    ? const Color(0xFFEFB659)
                                    : AppColors.upperRoomMuted),
                            SizedBox(width: 5.w),
                            Text(
                              recording ? 'Listening…' : 'Voice',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: recording
                                    ? const Color(0xFFEFB659)
                                    : AppColors.upperRoomMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Send button
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller,
                      builder: (_, val, __) {
                        final enabled = val.text.trim().isNotEmpty;
                        return GestureDetector(
                          onTap: enabled ? onSubmit : null,
                          child: AnimatedOpacity(
                            opacity: enabled ? 1.0 : 0.30,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 6.h),
                              decoration: BoxDecoration(
                                color: AppColors.upperRoomAmber,
                                borderRadius: BorderRadius.circular(999.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.send_outlined,
                                      size: 12.sp,
                                      color: AppColors.upperRoomCard),
                                  SizedBox(width: 5.w),
                                  Text(
                                    'Send up',
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.upperRoomCard,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Nation Prayer Wall ────────────────────────────────────────────────────────

class _NationPrayerWall extends StatelessWidget {
  final List<_WallRequest> wall;
  const _NationPrayerWall({required this.wall});

  @override
  Widget build(BuildContext context) {
    return _UrCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nation prayer wall',
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.upperRoomCream),
          ),
          SizedBox(height: 3.h),
          Text(
            'Requests rising from around the world. Pause on one and pray.',
            style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.upperRoomMuted.withOpacity(0.70)),
          ),
          SizedBox(height: 14.h),
          ...wall.map((req) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _WallCard(request: req),
              )),
        ],
      ),
    );
  }
}

class _WallCard extends StatefulWidget {
  final _WallRequest request;
  const _WallCard({required this.request});

  @override
  State<_WallCard> createState() => _WallCardState();
}

class _WallCardState extends State<_WallCard> {
  bool _prayed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.upperRoomBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.upperRoomBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.request.nation,
                style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.upperRoomAmber),
              ),
              Text(
                widget.request.when,
                style: TextStyle(
                    fontSize: 10.sp, color: const Color(0xFF8A7448)),
              ),
            ],
          ),
          SizedBox(height: 7.h),
          Text(
            widget.request.text,
            style: TextStyle(
                fontSize: 13.sp,
                height: 1.6,
                color: const Color(0xFFE8DDC4)),
          ),
          SizedBox(height: 10.h),
          // Pray button
          GestureDetector(
            onTap: _prayed ? null : () => setState(() => _prayed = true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 8.h),
              decoration: BoxDecoration(
                color: _prayed
                    ? AppColors.upperRoomAmber.withOpacity(0.10)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999.r),
                border: Border.all(
                  color: _prayed
                      ? Colors.transparent
                      : AppColors.upperRoomAmber.withOpacity(0.40),
                ),
              ),
              child: Text(
                _prayed ? 'You prayed for this. Amen.' : 'I prayed for this',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: _prayed
                      ? const Color(0xFF8A7448)
                      : AppColors.upperRoomAmber,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Card container ─────────────────────────────────────────────────────────────

class _UrCard extends StatelessWidget {
  final Widget child;
  const _UrCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.upperRoomCard,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.upperRoomBorder),
      ),
      child: child,
    );
  }
}
