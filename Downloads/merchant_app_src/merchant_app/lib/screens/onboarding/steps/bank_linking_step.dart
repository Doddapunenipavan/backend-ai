import 'package:flutter/material.dart';
import '../../../core/notifications/notification_models.dart';
import '../../../core/notifications/notification_service.dart';
import '../onboarding_data.dart';
import '../onboarding_theme.dart';

class BankLinkingStep extends StatefulWidget {
  const BankLinkingStep({super.key, required this.data, required this.onNext, required this.onBack});

  final OnboardingData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  State<BankLinkingStep> createState() => _BankLinkingStepState();
}

class _BankLinkingStepState extends State<BankLinkingStep> {
  static const banks = [
    {'id': 'hdfc', 'name': 'HDFC Bank', 'type': 'Current Account', 'abbr': 'HD', 'color': Color(0xFF004C8F), 'bg': Color(0xFFE3F0FF)},
    {'id': 'icici', 'name': 'ICICI Bank', 'type': 'Business Account', 'abbr': 'IC', 'color': Color(0xFFF7941D), 'bg': Color(0xFFFFF4E3)},
    {'id': 'sbi', 'name': 'State Bank of India', 'type': 'Current Account', 'abbr': 'SB', 'color': Color(0xFF2262AE), 'bg': Color(0xFFE8F0FB)},
    {'id': 'axis', 'name': 'Axis Bank', 'type': 'Savings / Current', 'abbr': 'AX', 'color': Color(0xFF97144D), 'bg': Color(0xFFFCE8F1)},
    {'id': 'kotak', 'name': 'Kotak Mahindra', 'type': 'Business Account', 'abbr': 'KO', 'color': Color(0xFFEE3124), 'bg': Color(0xFFFDE8E7)},
  ];

  final accountHolder = TextEditingController();
  final accountNumber = TextEditingController();
  final ifsc = TextEditingController();
  bool _verifying = false;
  String? _customBankName;

  Future<void> _addCustomBank() async {
    final nameCtrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add a different bank'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Yes Bank'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(nameCtrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || !mounted) return;
    setState(() {
      widget.data.selectedBank = 'custom:$name';
      widget.data.bankLinked = false;
      _customBankName = name;
    });
  }

  Future<void> _verify() async {
    setState(() => _verifying = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      widget.data.bankLinked = true;
      _verifying = false;
    });
    final bankName = widget.data.selectedBank.startsWith('custom:')
        ? _customBankName ?? 'Your bank'
        : banks.firstWhere((b) => b['id'] == widget.data.selectedBank)['name'];
    NotificationService.instance.push(
      title: 'Bank account linked',
      message: '$bankName account was linked and verified via penny drop.',
      type: AppNotificationType.settlement,
    );
  }

  void _continue() {
    if (widget.data.selectedBank.isEmpty || !widget.data.bankLinked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select and verify a bank account to continue.')),
      );
      return;
    }
    widget.onNext();
  }

  @override
  void dispose() {
    accountHolder.dispose();
    accountNumber.dispose();
    ifsc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        oProgressBar(71),
        const SizedBox(height: 28),
        oPageTitle('Bank Account Linking', 'Link your business bank account for settlements'),
        oCard(
          title: 'Select Your Bank',
          child: Column(children: [
            for (final b in banks) _bankItem(b),
            if (widget.data.selectedBank.startsWith('custom:'))
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: OC.brand, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                  color: OC.brandLight,
                ),
                child: Row(children: [
                  const Icon(Icons.account_balance_rounded, size: 20, color: OC.brand),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(_customBankName ?? '', style: oDm(14, FontWeight.w500, OC.text)),
                  ),
                  const Icon(Icons.check_circle, size: 18, color: OC.brand),
                ]),
              ),
            oBtn('+ Add a different bank', onTap: _addCustomBank, fullWidth: true),
          ]),
        ),
        if (widget.data.selectedBank.isNotEmpty)
          oCard(
            title: 'Account Details',
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              oLabel('Account Holder Name'),
              oInput(hint: 'Acme Pvt. Ltd.', controller: accountHolder),
              const SizedBox(height: 14),
              oLabel('Account Number'),
              oInput(hint: '••••••••••', controller: accountNumber),
              const SizedBox(height: 14),
              oLabel('IFSC Code'),
              oInput(hint: 'HDFC0001234', controller: ifsc),
              const SizedBox(height: 14),
              oLabel('Account Type'),
              oSelect(const ['Current', 'Savings']),
              const SizedBox(height: 14),
              oBtn(
                widget.data.bankLinked
                    ? '✓ Account Verified'
                    : (_verifying ? 'Verifying…' : 'Verify via Penny Drop →'),
                onTap: _verifying || widget.data.bankLinked ? () {} : _verify,
                primary: true,
                fullWidth: true,
              ),
              if (widget.data.bankLinked) oInfoRow('Bank account linked and verified!', ok: true),
            ]),
          ),
        oActionRow(onBack: widget.onBack, nextLabel: 'Continue to Agreement', onNext: _continue),
      ],
    );
  }

  Widget _bankItem(Map<String, dynamic> b) {
    final selected = widget.data.selectedBank == b['id'];
    return InkWell(
      onTap: () => setState(() {
        widget.data.selectedBank = b['id'] as String;
        widget.data.bankLinked = false;
      }),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: selected ? OC.brand : OC.border, width: 1.5),
          borderRadius: BorderRadius.circular(12),
          color: selected ? OC.brandLight : Colors.transparent,
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: b['bg'] as Color, borderRadius: BorderRadius.circular(8)),
            child: Text(b['abbr'] as String, style: oSora(16, FontWeight.w700, b['color'] as Color)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b['name'] as String, style: oDm(14, FontWeight.w500, OC.text)),
              Text(b['type'] as String, style: oDm(12, FontWeight.w400, OC.text3)),
            ]),
          ),
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? OC.brand : Colors.transparent,
              border: Border.all(color: selected ? OC.brand : OC.border2, width: 1.5),
            ),
            child: selected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
          ),
        ]),
      ),
    );
  }
}
