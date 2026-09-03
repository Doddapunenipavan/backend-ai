import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/notifications/notification_models.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/routing/app_router.dart';

/// Wrap the app (see `main.dart`) with this widget to get real-time,
/// in-app "push" style banners: the instant any screen calls
/// `NotificationService.instance.push(...)`, a banner slides down from the
/// top over whatever is currently on screen, then auto-dismisses.
///
/// This is what makes notifications feel "real-time" — the user doesn't have
/// to be on the Notifications screen to see them.
class NotificationBannerHost extends StatefulWidget {
  const NotificationBannerHost({super.key, required this.child});

  final Widget child;

  @override
  State<NotificationBannerHost> createState() => _NotificationBannerHostState();
}

class _NotificationBannerHostState extends State<NotificationBannerHost>
    with SingleTickerProviderStateMixin {
  StreamSubscription<AppNotification>? _sub;
  AppNotification? _current;
  Timer? _hideTimer;
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  late final Animation<Offset> _offset = Tween<Offset>(
    begin: const Offset(0, -1.2),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _sub = NotificationService.instance.liveStream.listen(_show);
  }

  void _show(AppNotification n) {
    _hideTimer?.cancel();
    setState(() => _current = n);
    _controller.forward(from: 0);
    _hideTimer = Timer(const Duration(seconds: 4), _hide);
  }

  void _hide() {
    if (!mounted) return;
    _controller.reverse().then((_) {
      if (mounted) setState(() => _current = null);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    _hideTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = _current;
    return Stack(
      children: [
        widget.child,
        if (n != null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: SlideTransition(
                position: _offset,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Material(
                    elevation: 8,
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        _hideTimer?.cancel();
                        _hide();
                        final navCtx = rootNavigatorKey.currentContext;
                        if (navCtx != null) navCtx.push('/profile/notifications');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: n.color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(n.icon, color: n.color, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    n.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    n.message,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF555770)),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFF9A9AB0)),
                              onPressed: () {
                                _hideTimer?.cancel();
                                _hide();
                              },
                            ),
                          ],
                        ),
                      ),
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
