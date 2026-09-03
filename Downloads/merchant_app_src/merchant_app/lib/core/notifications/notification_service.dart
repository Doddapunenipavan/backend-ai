import 'dart:async';
import 'package:flutter/foundation.dart';
import 'notification_models.dart';

/// App-wide notification bus.
///
/// Any screen can call `NotificationService.instance.push(...)` to raise a
/// notification. It is immediately:
///   1. added to the persistent in-app feed (`items`, exposed via ChangeNotifier
///      so the Notification Center + bell badge rebuild instantly), and
///   2. broadcast on [liveStream] so a global overlay (see
///      `widgets/notifications/notification_banner.dart`) can pop up a
///      real-time toast on top of whatever screen the user is currently on —
///      this is what gives the app "real-time notification" behaviour without
///      needing a backend push service.
class NotificationService extends ChangeNotifier {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final List<AppNotification> _items = [];
  List<AppNotification> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((n) => !n.read).length;

  final StreamController<AppNotification> _liveController =
      StreamController<AppNotification>.broadcast();

  /// Subscribe to this to show a live toast/banner the instant a
  /// notification is pushed, regardless of which screen is on-screen.
  Stream<AppNotification> get liveStream => _liveController.stream;

  int _counter = 0;

  AppNotification push({
    required String title,
    required String message,
    AppNotificationType type = AppNotificationType.system,
  }) {
    final notification = AppNotification(
      id: 'ntf_${DateTime.now().millisecondsSinceEpoch}_${_counter++}',
      title: title,
      message: message,
      type: type,
    );
    _items.insert(0, notification);
    notifyListeners();
    _liveController.add(notification);
    return notification;
  }

  void markRead(String id) {
    final i = _items.indexWhere((n) => n.id == id);
    if (i == -1) return;
    _items[i] = _items[i].copyWith(read: true);
    notifyListeners();
  }

  void markAllRead() {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(read: true);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _liveController.close();
    super.dispose();
  }
}
