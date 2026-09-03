/// FlexTenure Merchant — shared animation primitives.
///
/// Everything here is deliberately subtle and *fast* (150–500ms, mostly
/// easeOutCubic/easeOutBack) so the app feels snappy and alive rather than
/// slow or gimmicky. Colors are never touched — only motion, scale, and
/// opacity.
library app_animations;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ---------------------------------------------------------------------------
// Entrance animation — fade + slide-up, with built-in stagger support.
// ---------------------------------------------------------------------------

/// Wrap any widget to have it fade + slide in on first build. Pass an
/// [index] (and optionally [interval]) to stagger a whole list/grid so items
/// cascade in one after another instead of popping in all at once.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.index = 0,
    this.interval = const Duration(milliseconds: 60),
    this.duration = const Duration(milliseconds: 420),
    this.offset = 18,
    this.delay = Duration.zero,
  });

  final Widget child;
  final int index;
  final Duration interval;
  final Duration duration;
  final double offset;
  final Duration delay;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween(
    begin: Offset(0, widget.offset / 100),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    final wait = widget.delay + widget.interval * widget.index;
    Future.delayed(wait, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Convenience: wraps [children] (e.g. a Column's children) each in a
/// staggered [FadeSlideIn] so a whole section cascades in together.
List<Widget> staggeredChildren(List<Widget> children, {Duration delay = Duration.zero}) {
  return [
    for (int i = 0; i < children.length; i++)
      FadeSlideIn(index: i, delay: delay, child: children[i]),
  ];
}

// ---------------------------------------------------------------------------
// Press feedback — generic scale-down-on-tap wrapper used by buttons, cards,
// quick actions, and nav items so every tappable surface feels consistent.
// ---------------------------------------------------------------------------

class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.94,
    this.duration = const Duration(milliseconds: 110),
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final Duration duration;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onTap == null;
    return GestureDetector(
      onTapDown: disabled ? null : (_) => setState(() => _down = true),
      onTapUp: disabled ? null : (_) => setState(() => _down = false),
      onTapCancel: disabled ? null : () => setState(() => _down = false),
      onTap: widget.onTap,
      child: MouseRegion(
        cursor: disabled ? MouseCursor.defer : SystemMouseCursors.click,
        child: AnimatedScale(
          scale: _down ? widget.scale : 1.0,
          duration: widget.duration,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Animated counting number — makes KPI/stat values feel "live" whenever they
// first appear or change, instead of just snapping to a static string.
// ---------------------------------------------------------------------------

/// Animates any numeric-looking string (e.g. "₹ 4,82,600", "186", "32") by
/// counting the digits up from 0. Non-digit characters (currency symbol,
/// commas, spaces) are preserved exactly in place.
class AnimatedCountText extends StatefulWidget {
  const AnimatedCountText(
    this.value, {
    super.key,
    required this.style,
    this.duration = const Duration(milliseconds: 900),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  final String value;
  final TextStyle style;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final int? maxLines;
  final TextOverflow overflow;

  @override
  State<AnimatedCountText> createState() => _AnimatedCountTextState();
}

class _AnimatedCountTextState extends State<AnimatedCountText> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _t = CurvedAnimation(parent: _controller, curve: widget.curve);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _renderAt(double progress) {
    final buffer = StringBuffer();
    for (final rune in widget.value.runes) {
      final ch = String.fromCharCode(rune);
      final digit = int.tryParse(ch);
      if (digit == null) {
        buffer.write(ch);
      } else {
        buffer.write((digit * progress).round().clamp(0, digit));
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _t,
      builder: (context, _) => Text(
        _renderAt(_t.value),
        style: widget.style,
        maxLines: widget.maxLines,
        overflow: widget.overflow,
        softWrap: widget.maxLines == null,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Pulsing dot — for notification badges / "live" indicators.
// ---------------------------------------------------------------------------

class PulseDot extends StatefulWidget {
  const PulseDot({super.key, required this.color, this.size = 8});

  final Color color;
  final double size;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        return SizedBox(
          width: widget.size * 2.6,
          height: widget.size * 2.6,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: (1 - t).clamp(0, 1),
                child: Container(
                  width: widget.size + (widget.size * 1.6 * t),
                  height: widget.size + (widget.size * 1.6 * t),
                  decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
                ),
              ),
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Gentle float — subtle up/down loop, used sparingly (e.g. splash logo) to
// make an otherwise static hero element feel alive without being distracting.
// ---------------------------------------------------------------------------

class GentleFloat extends StatefulWidget {
  const GentleFloat({super.key, required this.child, this.range = 6, this.duration = const Duration(seconds: 3)});

  final Widget child;
  final double range;
  final Duration duration;

  @override
  State<GentleFloat> createState() => _GentleFloatState();
}

class _GentleFloatState extends State<GentleFloat> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: widget.duration)..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final y = math.sin(_controller.value * math.pi) * widget.range;
        return Transform.translate(offset: Offset(0, -y), child: child);
      },
      child: widget.child,
    );
  }
}

// ---------------------------------------------------------------------------
// Route transitions — smooth fade + slide between screens app-wide. Drop-in
// replacement for GoRoute's default `builder:` — use `pageBuilder: fadeThroughPage(...)`.
// ---------------------------------------------------------------------------

Page<void> fadeThroughPage(BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 340),
    reverseTransitionDuration: const Duration(milliseconds: 260),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.03),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
