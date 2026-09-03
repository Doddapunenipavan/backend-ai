import 'package:flutter/material.dart';

/// Broad category for a notification — drives which icon/colour it renders
/// with and which toggle in Notification Settings controls it.
enum AppNotificationType {
  onboarding,
  payment,
  settlement,
  document,
  security,
  promotion,
  system,
}

class AppNotification {
  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    DateTime? timestamp,
    this.read = false,
  }) : timestamp = timestamp ?? DateTime.now();

  final String id;
  final String title;
  final String message;
  final AppNotificationType type;
  final DateTime timestamp;
  bool read;

  AppNotification copyWith({bool? read}) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      type: type,
      timestamp: timestamp,
      read: read ?? this.read,
    );
  }

  IconData get icon {
    switch (type) {
      case AppNotificationType.onboarding:
        return Icons.checklist_rounded;
      case AppNotificationType.payment:
        return Icons.payments_outlined;
      case AppNotificationType.settlement:
        return Icons.account_balance_wallet_outlined;
      case AppNotificationType.document:
        return Icons.description_outlined;
      case AppNotificationType.security:
        return Icons.shield_outlined;
      case AppNotificationType.promotion:
        return Icons.campaign_outlined;
      case AppNotificationType.system:
        return Icons.info_outline_rounded;
    }
  }

  Color get color {
    switch (type) {
      case AppNotificationType.onboarding:
        return const Color(0xFF1A56DB);
      case AppNotificationType.payment:
        return const Color(0xFF0F6E56);
      case AppNotificationType.settlement:
        return const Color(0xFF0F6E56);
      case AppNotificationType.document:
        return const Color(0xFF854F0B);
      case AppNotificationType.security:
        return const Color(0xFFA32D2D);
      case AppNotificationType.promotion:
        return const Color(0xFF7C3AED);
      case AppNotificationType.system:
        return const Color(0xFF555770);
    }
  }

  String get relativeTime {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}
