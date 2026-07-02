import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../config/constants.dart';

/// Manages local push notifications for session reminders, prayer alerts,
/// and mentor messages.
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialised = false;

  // ── Initialisation ─────────────────────────────────────────────────────────

  static Future<void> init() async {
    if (_initialised) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _createChannels();
    _initialised = true;
  }

  static Future<void> _createChannels() async {
    const channels = [
      AndroidNotificationChannel(
        AppConstants.prayerChannelId,
        'Prayer Reminders',
        description: 'Reminders to pray and view the prayer wall.',
        importance: Importance.defaultImportance,
      ),
      AndroidNotificationChannel(
        AppConstants.sessionChannelId,
        'Session Reminders',
        description: 'Reminders for upcoming peer study sessions.',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        AppConstants.mentorChannelId,
        'Mentor Alerts',
        description: 'Messages and alerts from your mentor.',
        importance: Importance.high,
      ),
    ];

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    for (final c in channels) {
      await androidPlugin?.createNotificationChannel(c);
    }
  }

  static void _onNotificationTap(NotificationResponse response) {
    // TODO: use payload to navigate via GoRouter
    // GoRouter.of(navigatorKey.currentContext!).go(response.payload!);
  }

  // ── Show helpers ───────────────────────────────────────────────────────────

  static Future<void> showSessionReminder({
    required int id,
    required String partnerName,
    required DateTime scheduledAt,
  }) async {
    await _plugin.show(
      id,
      'Session starting soon',
      'You have a study session with $partnerName',
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.sessionChannelId,
          'Session Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: '/peer-session',
    );
  }

  static Future<void> showPrayerReminder() async {
    await _plugin.show(
      0,
      'Time to pray 🙏',
      'Someone on the prayer wall needs your intercession.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.prayerChannelId,
          'Prayer Reminders',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: '/upper-room',
    );
  }

  static Future<void> cancelAll() => _plugin.cancelAll();

  static Future<void> cancel(int id) => _plugin.cancel(id);
}
