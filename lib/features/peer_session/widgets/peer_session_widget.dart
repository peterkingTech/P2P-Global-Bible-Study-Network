import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../config/theme.dart';
import '../../../core/providers/session_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PeerSessionWidget — Peer-to-Peer Global Bible Study Network
// A live, co-present peer Bible study session.
// ─────────────────────────────────────────────────────────────────────────────

// Session checklist steps — core product UX, not demo data
const _kSteps = [
  'Both prayed together',
  'Memory verse recited',
  'Content discussed',
  'Assignment committed',
  'Checkpoint completed',
];

class PeerSessionWidget extends ConsumerStatefulWidget {
  const PeerSessionWidget({super.key});

  @override
  ConsumerState<PeerSessionWidget> createState() => _PeerSessionWidgetState();
}

class _PeerSessionWidgetState extends ConsumerState<PeerSessionWidget> {
  int _seconds = 0;
  List<bool> _checked = List.filled(_kSteps.length, false);
  double _readProgress = 0.0;
  String _peerNote = 'Peer joined the session';
  bool _ended = false;
  bool _confirming = false;
  final TextEditingController _reflectionCtrl = TextEditingController();
  bool _saved = false;

  // Session lesson data (fetched from Supabase via liveSessionProvider)
  String _sessionTitle = 'Bible Study Session';
  String _sessionSubtitle = 'Peer-to-Peer Study';
  String? _memoryVerseText;
  String? _memoryVerseRef;
  List<String> _lessonParagraphs = [];

  Timer? _sessionTimer;
  RealtimeChannel? _presenceChannel;
  final ScrollController _contentScroll = ScrollController();

  // Public callbacks — let helper StatelessWidgets mutate state without
  // directly calling the protected setState().
  void setSaved(bool value) => setState(() => _saved = value);
  void toggleChecked(int index) => setState(() => _checked[index] = !_checked[index]);
  void setConfirming(bool value) => setState(() => _confirming = value);

  @override
  void initState() {
    super.initState();
    _sessionTimer =
        Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_ended && mounted) setState(() => _seconds++);
    });
    _subscribeToPresence();
    _loadSessionLesson();
    _contentScroll.addListener(_onScroll);
  }

  Future<void> _loadSessionLesson() async {
    final session = ref.read(liveSessionProvider).session;
    if (session == null) return;
    try {
      final rows = await Supabase.instance.client
          .from('lessons')
          .select('title, subtitle, content, memory_verse, memory_verse_ref')
          .eq('id', session.lessonId)
          .single();
      if (mounted) {
        setState(() {
          _sessionTitle = (rows['title'] as String?) ?? 'Bible Study Session';
          _sessionSubtitle = (rows['subtitle'] as String?) ?? 'Peer-to-Peer Study';
          _memoryVerseText = rows['memory_verse'] as String?;
          _memoryVerseRef = rows['memory_verse_ref'] as String?;
          final content = (rows['content'] as String?) ?? '';
          _lessonParagraphs = content
              .split('\n\n')
              .where((p) => p.trim().isNotEmpty)
              .toList();
        });
      }
    } catch (_) {
      // Lesson content will remain at defaults; session still functional
    }
  }

  void _subscribeToPresence() {
    final session = ref.read(liveSessionProvider).session;
    if (session == null) return;

    _presenceChannel = Supabase.instance.client
        .channel('session:${session.id}')
        .onPresenceSync((_) {
          final presences = _presenceChannel?.presenceState();
          if (mounted && (presences?.isNotEmpty ?? false)) {
            setState(() => _peerNote = 'Peer is present in this session');
          }
        })
        .onPresenceJoin((_) {
          if (mounted) setState(() => _peerNote = 'Peer joined the session');
        })
        .onPresenceLeave((_) {
          if (mounted) setState(() => _peerNote = 'Peer stepped away');
        })
      ..subscribe((status, _) async {
        if (status == RealtimeSubscribeStatus.subscribed) {
          await _presenceChannel?.track({'user': 'me', 'online_at': DateTime.now().toIso8601String()});
        }
      });
  }

  void _onScroll() {
    final sc = _contentScroll;
    if (sc.position.maxScrollExtent > 0) {
      setState(() => _readProgress =
          (sc.offset / sc.position.maxScrollExtent).clamp(0.0, 1.0));
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _presenceChannel?.unsubscribe();
    _reflectionCtrl.dispose();
    _contentScroll.removeListener(_onScroll);
    _contentScroll.dispose();
    super.dispose();
  }

  String get _mm => (_seconds ~/ 60).toString().padLeft(2, '0');
  String get _ss => (_seconds % 60).toString().padLeft(2, '0');
  int get _completedCount => _checked.where((v) => v).length;

  @override
  Widget build(BuildContext context) {
    if (_ended) return _SessionComplete(this);

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeaderCard(mm: _mm, ss: _ss, state: this),
              SizedBox(height: 16.h),
              // On wide screens: row; on narrow: column
              LayoutBuilder(builder: (context, constraints) {
                final wide = constraints.maxWidth > 600;
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _LessonContent(this)),
                      SizedBox(width: 16.w),
                      SizedBox(
                        width: 300.w,
                        child: _SidePanel(this),
                      ),
                    ],
                  );
                }
                return Column(children: [
                  _LessonContent(this),
                  SizedBox(height: 14.h),
                  _SidePanel(this),
                ]);
              }),
            ],
          ),
        ),

        // End-session confirmation overlay
        if (_confirming)
          _EndConfirmationOverlay(
            completedCount: _completedCount,
            onKeepStudying: () => setState(() => _confirming = false),
            onEnd: () => setState(() {
              _confirming = false;
              _ended = true;
            }),
          ),
      ],
    );
  }
}

// ── Session Complete Screen ───────────────────────────────────────────────────

class _SessionComplete extends StatelessWidget {
  final _PeerSessionWidgetState state;
  const _SessionComplete(this.state);

  @override
  Widget build(BuildContext context) {
    final s = state;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 40.h),
      child: Column(
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: 480.w),
            padding: EdgeInsets.all(28.r),
            decoration: BoxDecoration(
              color: AppColors.lightCream,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: AppColors.borderBeige),
            ),
            child: Column(
              children: [
                Container(
                  width: 52.r,
                  height: 52.r,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check, color: AppColors.primaryGreen, size: 26.sp),
                ),
                SizedBox(height: 18.h),
                Text(
                  'Session complete',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  'You studied together for ${s._mm}:${s._ss} and completed ${s._completedCount} of ${_kSteps.length} steps. Take a moment to reflect before you go.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13.sp, height: 1.6, color: AppColors.textMid),
                ),
                SizedBox(height: 20.h),

                // Reflection input
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'What is one thing God showed you today?',
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textDark),
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: s._reflectionCtrl,
                  minLines: 4,
                  maxLines: 6,
                  onChanged: (_) {
                    if (s._saved) {
                      s.setSaved(false);
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Write a short reflection…',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(color: AppColors.borderBeige),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide: const BorderSide(color: AppColors.borderBeige),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      borderSide:
                          const BorderSide(color: AppColors.accentGreen, width: 2),
                    ),
                    contentPadding: EdgeInsets.all(14.r),
                  ),
                ),
                SizedBox(height: 10.h),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: s._reflectionCtrl,
                  builder: (_, val, __) {
                    final enabled = val.text.trim().isNotEmpty;
                    return GestureDetector(
                      onTap: enabled ? () => s.setSaved(true) : null,
                      child: AnimatedOpacity(
                        opacity: enabled ? 1.0 : 0.40,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 11.h),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            s._saved ? 'Reflection saved' : 'Save reflection',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.cream,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (s._saved) ...[
                  SizedBox(height: 10.h),
                  Text(
                    'Kept in your journal. Grace and peace.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.sp, color: AppColors.primaryGreen),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header Card ───────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  final String mm;
  final String ss;
  final _PeerSessionWidgetState state;
  const _HeaderCard({required this.mm, required this.ss, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: AppColors.lightCream,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderBeige),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state._sessionSubtitle,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.8,
                        color: AppColors.amber,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      state._sessionTitle,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              // Timer pill
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.timer_outlined,
                        size: 15.sp, color: AppColors.primaryGreen),
                    SizedBox(width: 5.w),
                    Text(
                      '$mm:$ss',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          // Memory verse blockquote
          Container(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
            decoration: BoxDecoration(
              color: AppColors.cream,
              borderRadius: BorderRadius.circular(14.r),
              border: const Border(
                left: BorderSide(color: AppColors.amber, width: 2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state._memoryVerseText != null
                      ? '"${state._memoryVerseText}"'
                      : '"Two are better than one, because they have a good reward for their toil."',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                    color: AppColors.darkAmber,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  state._memoryVerseRef ?? 'Ecclesiastes 4:9',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.amber,
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

// ── Lesson Content ────────────────────────────────────────────────────────────

class _LessonContent extends StatelessWidget {
  final _PeerSessionWidgetState state;
  const _LessonContent(this.state);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightCream,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderBeige),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.menu_book_outlined,
                        size: 15.sp, color: AppColors.primaryGreen),
                    SizedBox(width: 6.w),
                    Text(
                      'Lesson reading',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${(state._readProgress * 100).round()}% read',
                  style: TextStyle(
                      fontSize: 11.sp, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          // Progress bar
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999.r),
              child: LinearProgressIndicator(
                value: state._readProgress,
                minHeight: 4.h,
                backgroundColor: AppColors.sessionTrack,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // Scrollable text
          SizedBox(
            height: 380.h,
            child: SingleChildScrollView(
              controller: state._contentScroll,
              padding: EdgeInsets.fromLTRB(18.w, 4.h, 18.w, 18.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: state._lessonParagraphs.isEmpty
                    ? [
                        Padding(
                          padding: EdgeInsets.only(bottom: 14.h),
                          child: Text(
                            'Lesson content is loading. Take a moment to pray together before you begin.',
                            style: TextStyle(
                              fontSize: 14.sp,
                              height: 1.70,
                              color: AppColors.textDark,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ]
                    : state._lessonParagraphs
                        .map(
                          (p) => Padding(
                            padding: EdgeInsets.only(bottom: 14.h),
                            child: Text(
                              p,
                              style: TextStyle(
                                fontSize: 14.sp,
                                height: 1.70,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Side Panel ────────────────────────────────────────────────────────────────

class _SidePanel extends StatelessWidget {
  final _PeerSessionWidgetState state;
  const _SidePanel(this.state);

  @override
  Widget build(BuildContext context) {
    final s = state;
    return Column(
      children: [
        // Peer presence
        _PsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 38.r,
                        height: 38.r,
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            'M',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -2,
                        right: -2,
                        child: Container(
                          width: 11.r,
                          height: 11.r,
                          decoration: BoxDecoration(
                            color: AppColors.accentGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.lightCream, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your study partner',
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textDark),
                      ),
                      Text(
                        'Your peer guide',
                        style: TextStyle(
                            fontSize: 11.sp, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              // Live status
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    _PulsingDot(),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        s._peerNote,
                        style: TextStyle(
                            fontSize: 11.sp, color: AppColors.textMid),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 14.h),

        // Checklist
        _PsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Peer guide checklist',
                    style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryGreen),
                  ),
                  Text(
                    '${s._completedCount}/${_kSteps.length}',
                    style: TextStyle(
                        fontSize: 11.sp, color: AppColors.textMuted),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              ..._kSteps.asMap().entries.map((e) {
                final i = e.key;
                final step = e.value;
                final checked = s._checked[i];
                return Padding(
                  padding: EdgeInsets.only(bottom: 5.h),
                  child: Semantics(
                    toggled: checked,
                    label: step,
                    button: true,
                    child: GestureDetector(
                      onTap: () =>
                          s.toggleChecked(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 9.h),
                        decoration: BoxDecoration(
                          color: checked
                              ? AppColors.primaryGreen.withOpacity(0.10)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 18.r,
                              height: 18.r,
                              decoration: BoxDecoration(
                                color: checked
                                    ? AppColors.primaryGreen
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(4.r),
                                border: Border.all(
                                  color: checked
                                      ? AppColors.primaryGreen
                                      : const Color(0xFFCDBF9F),
                                ),
                              ),
                              child: checked
                                  ? Icon(Icons.check,
                                      size: 12.sp, color: AppColors.cream)
                                  : null,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                step,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: checked
                                      ? AppColors.primaryGreen
                                      : AppColors.textDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),

        SizedBox(height: 14.h),

        // End session button
        GestureDetector(
          onTap: () => s.setConfirming(true),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 11.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: const Color(0xFFD8B78A)),
            ),
            child: Text(
              'End session',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.amber,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── End Confirmation Overlay ──────────────────────────────────────────────────

class _EndConfirmationOverlay extends StatelessWidget {
  final int completedCount;
  final VoidCallback onKeepStudying;
  final VoidCallback onEnd;

  const _EndConfirmationOverlay({
    required this.completedCount,
    required this.onKeepStudying,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onKeepStudying,
      child: Container(
        color: const Color(0x661A1206),
        alignment: Alignment.center,
        padding: EdgeInsets.all(20.r),
        child: GestureDetector(
          onTap: () {}, // prevent tap-through
          child: Container(
            constraints: BoxConstraints(maxWidth: 380.w),
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: AppColors.lightCream,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: AppColors.borderBeige),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'End this session?',
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryGreen,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "You've completed $completedCount of ${_kSteps.length} steps. You'll be able to write a short reflection afterward.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13.sp, height: 1.6, color: AppColors.textMid),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onKeepStudying,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 11.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9E0CB),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            'Keep studying',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textMid,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: onEnd,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 11.h),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            'End session',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.cream,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _PsCard extends StatelessWidget {
  final Widget child;
  const _PsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.lightCream,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderBeige),
      ),
      child: child,
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _opacity = Tween(begin: 0.35, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 6.r,
        height: 6.r,
        decoration: const BoxDecoration(
          color: AppColors.accentGreen,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
