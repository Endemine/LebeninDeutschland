import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Tägliche Lern-Erinnerung als lokale Benachrichtigung (kein Server, keine Daten).
class ReminderService extends ChangeNotifier {
  static const String _kEnabled = 'reminder_enabled';
  static const String _kHour = 'reminder_hour';
  static const String _kMinute = 'reminder_minute';
  static const int _notificationId = 1001;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _enabled = false;
  int _hour = 18;
  int _minute = 0;
  bool _ready = false;

  bool get enabled => _enabled;
  int get hour => _hour;
  int get minute => _minute;
  String get timeLabel =>
      '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';

  /// Beim App-Start: gespeicherte Einstellung laden und Erinnerung neu planen
  /// (hält sie auch nach Zeitzonen-/Zeitumstellung aktuell).
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool(_kEnabled) ?? false;
      _hour = prefs.getInt(_kHour) ?? 18;
      _minute = prefs.getInt(_kMinute) ?? 0;
      if (_enabled) {
        await _ensureInit();
        await _schedule();
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Erinnerung laden fehlgeschlagen: $e');
    }
  }

  /// Schaltet die Erinnerung ein/aus. Gibt false zurück, wenn die
  /// Benachrichtigungs-Berechtigung verweigert wurde.
  Future<bool> setEnabled(bool value) async {
    try {
      if (value) {
        await _ensureInit();
        if (!await _requestPermission()) return false;
        _enabled = true;
        await _save();
        await _schedule();
      } else {
        _enabled = false;
        await _save();
        await _ensureInit();
        await _plugin.cancel(id: _notificationId);
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Erinnerung umschalten fehlgeschlagen: $e');
      return false;
    }
  }

  Future<void> setTime(int hour, int minute) async {
    _hour = hour;
    _minute = minute;
    await _save();
    if (_enabled) {
      await _ensureInit();
      await _schedule();
    }
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kEnabled, _enabled);
    await prefs.setInt(_kHour, _hour);
    await prefs.setInt(_kMinute, _minute);
  }

  Future<void> _ensureInit() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (e) {
      debugPrint('Zeitzone nicht ermittelbar, nutze UTC: $e');
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  Future<bool> _requestPermission() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? true;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(alert: true, badge: false, sound: true) ?? false;
  }

  Future<void> _schedule() async {
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, _hour, _minute);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id: _notificationId,
      scheduledDate: next,
      title: 'Zeit zum Lernen 📚',
      body: 'Heute schon geübt? Ein paar Fragen bringen dich der Prüfung näher.',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          'Tägliche Lern-Erinnerung',
          channelDescription: 'Erinnert dich einmal täglich ans Üben',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
