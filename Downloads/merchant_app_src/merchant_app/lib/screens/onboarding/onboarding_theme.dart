import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Onboarding-specific palette — matches the FlexTenure web mock exactly.
/// Deliberately separate from AppColors since this flow uses its own
/// brand blue (#1a56db) + Sora/DM Sans pairing.
class OC {
  OC._();
  static const brand = Color(0xFF1A56DB);
  static const brandLight = Color(0xFFE8F0FE);
  static const brandDark = Color(0xFF1240A4);
  static const surface = Color(0xFFFFFFFF);
  static const surface2 = Color(0xFFF8F9FA);
  static const surface3 = Color(0xFFF1F3F5);
  static const text = Color(0xFF1A1A2E);
  static const text2 = Color(0xFF555770);
  static const text3 = Color(0xFF9A9AB0);
  static const border = Color(0x14000000);
  static const border2 = Color(0x26000000);
  static const success = Color(0xFF0F6E56);
  static const successBg = Color(0xFFE1F5EE);
  static const danger = Color(0xFFA32D2D);
  static const dangerBg = Color(0xFFFCEBEB);
  static const warning = Color(0xFF854F0B);
  static const warningBg = Color(0xFFFAEEDA);
}

TextStyle oSora(double size, FontWeight w, Color c, {double? ls}) =>
    GoogleFonts.sora(
        fontSize: size, fontWeight: w, color: c, letterSpacing: ls);
TextStyle oDm(double size, FontWeight w, Color c) =>
    GoogleFonts.dmSans(fontSize: size, fontWeight: w, color: c);

class OnboardingStepMeta {
  const OnboardingStepMeta(this.label, this.sub);
  final String label;
  final String sub;
}

const onboardingSteps = [
  OnboardingStepMeta('Sign Up / Login', 'Authentication'),
  OnboardingStepMeta('Business Details', 'Company info'),
  OnboardingStepMeta('Document Upload', 'KYC docs'),
  OnboardingStepMeta('KYC Verification', 'Identity check'),
  OnboardingStepMeta('Bank Account', 'Link account'),
  OnboardingStepMeta('Agreement', 'Sign & confirm'),
  OnboardingStepMeta('Approval Status', 'Review outcome'),
];

// ---------------- Shared building blocks ----------------
// These used to be private methods on the one giant State class. They're now
// free functions/widgets so every step file (steps/*.dart) can reuse them.

Widget oProgressBar(double pct) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Container(
        height: 4,
        decoration: BoxDecoration(
            color: OC.border, borderRadius: BorderRadius.circular(2)),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: (pct / 100).clamp(0, 1),
          child: Container(
              decoration: BoxDecoration(
                  color: OC.brand, borderRadius: BorderRadius.circular(2))),
        ),
      ),
      const SizedBox(height: 8),
      Text('${pct.round()}% complete',
          style: oDm(11, FontWeight.w400, OC.text3)),
    ],
  );
}

Widget oPageTitle(String title, String sub) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: oSora(22, FontWeight.w600, OC.text, ls: -0.4)),
        const SizedBox(height: 4),
        Text(sub, style: oDm(14, FontWeight.w400, OC.text2)),
      ],
    ),
  );
}

Widget oCard({required Widget child, String? title}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: OC.surface,
      border: Border.all(color: OC.border),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Row(children: [
            Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                    color: OC.brand, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(title, style: oSora(14, FontWeight.w500, OC.text)),
          ]),
          const SizedBox(height: 16),
        ],
        child,
      ],
    ),
  );
}

Widget oLabel(String s) => Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(s, style: oDm(12, FontWeight.w500, OC.text2)),
    );

/// Renders two labeled fields side-by-side (matches the web mock's grid),
/// falling back to a stacked column on narrow phone widths.
///
/// Uses LayoutBuilder so it responds to the actual container width
/// (not just screen width) — critical when the sidebar is showing on
/// tablet/desktop layouts.
Widget oFieldPair(BuildContext context, String label1, Widget field1,
    String label2, Widget field2) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final w = constraints.maxWidth;
      // Stack vertically when narrower than ~460 (phone widths).
      if (!w.isFinite || w < 460) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            oLabel(label1),
            field1,
            const SizedBox(height: 14),
            oLabel(label2),
            field2,
          ],
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [oLabel(label1), field1],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [oLabel(label2), field2],
            ),
          ),
        ],
      );
    },
  );
}

Widget oInput({
  String? hint,
  TextEditingController? controller,
  TextInputType? type,
  ValueChanged<String>? onChanged,
  int maxLines = 1,
}) {
  return TextField(
    controller: controller,
    keyboardType: type,
    maxLines: maxLines,
    onChanged: onChanged,
    style: oDm(14, FontWeight.w400, OC.text),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: oDm(14, FontWeight.w400, OC.text3),
      filled: true,
      fillColor: OC.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: OC.border2, width: 0.7)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: OC.border2, width: 0.7)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: OC.brand, width: 1.4)),
    ),
  );
}

Widget oSelect(List<String> options,
    {String? value, ValueChanged<String?>? onChanged}) {
  return DropdownButtonFormField<String>(
    value: value != null && options.contains(value) ? value : null,
    // CRITICAL: isExpanded prevents the dropdown from trying to compute
    // intrinsic width, which crashes inside Expanded/flex parents.
    isExpanded: true,
    icon: const Icon(Icons.keyboard_arrow_down_rounded,
        color: OC.text2, size: 20),
    items: options
        .map((o) => DropdownMenuItem(
              value: o,
              child: Text(o,
                  style: oDm(14, FontWeight.w400, OC.text),
                  overflow: TextOverflow.ellipsis),
            ))
        .toList(),
    onChanged: onChanged ?? (_) {},
    decoration: InputDecoration(
      filled: true,
      fillColor: OC.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: OC.border2, width: 0.7)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: OC.border2, width: 0.7)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: OC.brand, width: 1.4)),
    ),
  );
}

/// Universal button used across every step.
///
/// Three critical protections against the "RenderBox not laid out" crash:
///
/// 1. `tapTargetSize: shrinkWrap` — removes Material's forced 48–52px min
///    tap height. Combined with an unbounded Row it was producing
///    `BoxConstraints(w=Infinity, 52<=h<=Infinity)` — the exact crash.
///
/// 2. `minimumSize` — gives a bounded floor so the button never asks for
///    zero size either.
///
/// 3. `IntrinsicWidth` wrap on non-fullWidth buttons — guarantees the
///    parent Row can never hand this button infinite width, no matter
///    what mainAxisAlignment is used.
Widget oBtn(
  String label, {
  required VoidCallback onTap,
  bool primary = false,
  bool danger = false,
  bool success = false,
  bool fullWidth = false,
  bool small = false,
}) {
  final bg = primary
      ? OC.brand
      : (danger ? OC.dangerBg : (success ? OC.successBg : OC.surface));
  final fg = primary
      ? Colors.white
      : (danger ? OC.danger : (success ? OC.success : OC.text));
  final borderColor = primary
      ? OC.brand
      : (danger ? OC.danger : (success ? OC.success : OC.border2));

  final btn = OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: fg,
      side: BorderSide(color: borderColor, width: 0.7),
      padding: EdgeInsets.symmetric(
          horizontal: small ? 14 : 20, vertical: small ? 8 : 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      minimumSize: Size(small ? 80 : 100, small ? 32 : 42),
    ),
    child: Text(label, style: oSora(small ? 13 : 14, FontWeight.w600, fg)),
  );

  if (fullWidth) return SizedBox(width: double.infinity, child: btn);
  return IntrinsicWidth(child: btn);
}

Widget oInfoRow(String text, {bool ok = false}) {
  return Container(
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: ok ? OC.successBg : OC.brandLight,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
                color: ok ? OC.success : OC.brand, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Expanded(
            child: Text(text,
                style: oDm(13, FontWeight.w400, ok ? OC.success : OC.text2))),
      ],
    ),
  );
}

/// Bottom action row (Back / Next).
///
/// CRITICAL: when there's no Back button, we use MainAxisAlignment.end
/// with a single child — NOT spaceBetween with a phantom SizedBox().
/// The phantom child (size zero) combined with spaceBetween was giving
/// the remaining button unbounded width and triggering the crash.
Widget oActionRow({
  bool showBack = true,
  VoidCallback? onBack,
  required String nextLabel,
  required VoidCallback onNext,
}) {
  return Container(
    margin: const EdgeInsets.only(top: 24),
    padding: const EdgeInsets.only(top: 20),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: OC.border)),
    ),
    child: Row(
      mainAxisAlignment:
          showBack ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
      children: [
        if (showBack) oBtn('← Back', onTap: onBack ?? () {}),
        oBtn('$nextLabel →', onTap: onNext, primary: true),
      ],
    ),
  );
}

String oTodayStr() {
  final d = DateTime.now();
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${d.day.toString().padLeft(2, '0')} ${months[d.month - 1]} ${d.year}';
}
