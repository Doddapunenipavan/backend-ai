import 'package:flutter/material.dart';
import '../../../core/notifications/notification_models.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/config/verification_links.dart';
import '../../../core/services/verification_link_screen.dart';
import '../onboarding_data.dart';
import '../onboarding_theme.dart';

class BusinessDetailsStep extends StatefulWidget {
  const BusinessDetailsStep(
      {super.key,
      required this.data,
      required this.onNext,
      required this.onBack});

  final OnboardingData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  @override
  State<BusinessDetailsStep> createState() => _BusinessDetailsStepState();
}

class _BusinessDetailsStepState extends State<BusinessDetailsStep> {
  late final businessName =
      TextEditingController(text: widget.data.businessName);
  late final gstin = TextEditingController(text: widget.data.gstin);
  late final pan = TextEditingController(text: widget.data.pan);
  late final cin = TextEditingController(text: widget.data.cin);
  late final year = TextEditingController(text: widget.data.yearIncorporation);
  late final businessEmail =
      TextEditingController(text: widget.data.businessEmail);
  late final businessPhone =
      TextEditingController(text: widget.data.businessPhone);
  late final address = TextEditingController(text: widget.data.address);
  late final city = TextEditingController(text: widget.data.city);
  late final pincode = TextEditingController(text: widget.data.pincode);
  late final country = TextEditingController(text: widget.data.country);

  static const businessTypes = [
    'Sole Proprietorship',
    'Private Limited',
    'LLP',
    'Partnership',
    'Public Limited'
  ];
  static const industries = [
    'Retail',
    'E-Commerce',
    'SaaS / Software',
    'Healthcare',
    'Education',
    'Food & Beverage',
    'Other'
  ];
  static const states = [
    'Maharashtra',
    'Karnataka',
    'Delhi',
    'Tamil Nadu',
    'Gujarat',
    'Other'
  ];

  // GST Search Taxpayer portal — official, manual, no API/login needed.
  static const String _gstManualLink =
      'https://services.gst.gov.in/services/searchtp';

  bool _gstinVerified = false;
  bool _panVerified = false;

  Future<void> _openManualVerify(
      String url, String title, void Function(bool) onDone) async {
    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
          builder: (_) => VerificationLinkScreen(url: url, title: title)),
    );
    if (done == true && mounted) setState(() => onDone(true));
  }

  String? _error;

  void _save() {
    // Required-field check. CIN stays optional since it only applies to
    // registered companies (label says "if applicable").
    final missing = <String>[];
    if (businessName.text.trim().isEmpty) missing.add('Legal Business Name');
    if (widget.data.businessType.isEmpty) missing.add('Business Type');
    if (widget.data.industry.isEmpty) missing.add('Industry / Category');
    if (gstin.text.trim().isEmpty) missing.add('GSTIN');
    if (pan.text.trim().isEmpty) missing.add('PAN Number');
    if (year.text.trim().isEmpty) missing.add('Year of Incorporation');
    if (businessEmail.text.trim().isEmpty) missing.add('Business Email');
    if (businessPhone.text.trim().isEmpty) missing.add('Business Phone');
    if (address.text.trim().isEmpty) missing.add('Registered Address');
    if (city.text.trim().isEmpty) missing.add('City');
    if (widget.data.state.isEmpty) missing.add('State');
    if (pincode.text.trim().isEmpty) missing.add('Pincode');
    if (country.text.trim().isEmpty) missing.add('Country');

    if (missing.isNotEmpty) {
      setState(() => _error = 'Please fill in: ${missing.join(', ')}.');
      return;
    }
    setState(() => _error = null);

    widget.data
      ..businessName = businessName.text
      ..gstin = gstin.text
      ..pan = pan.text
      ..cin = cin.text
      ..yearIncorporation = year.text
      ..businessEmail = businessEmail.text
      ..businessPhone = businessPhone.text
      ..address = address.text
      ..city = city.text
      ..pincode = pincode.text
      ..country = country.text;
    NotificationService.instance.push(
      title: 'Business details saved',
      message:
          '${widget.data.businessName.isEmpty ? "Your business" : widget.data.businessName} details were saved successfully.',
      type: AppNotificationType.onboarding,
    );
    widget.onNext();
  }

  @override
  void dispose() {
    for (final c in [
      businessName,
      gstin,
      pan,
      cin,
      year,
      businessEmail,
      businessPhone,
      address,
      city,
      pincode,
      country
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        oProgressBar(28),
        const SizedBox(height: 28),
        oPageTitle('Business Details', 'Tell us about your business'),
        oCard(
          title: 'Basic Information',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            oLabel('Legal Business Name *'),
            oInput(hint: 'Acme Pvt. Ltd.', controller: businessName),
            const SizedBox(height: 14),
            oFieldPair(
              context,
              'Business Type *',
              oSelect(businessTypes,
                  value: widget.data.businessType,
                  onChanged: (v) =>
                      setState(() => widget.data.businessType = v ?? '')),
              'Industry / Category *',
              oSelect(industries,
                  value: widget.data.industry,
                  onChanged: (v) =>
                      setState(() => widget.data.industry = v ?? '')),
            ),
            const SizedBox(height: 14),
            oFieldPair(
                context,
                'GSTIN *',
                oInput(hint: '29AAFCS1234A1Z5', controller: gstin),
                'PAN Number *',
                oInput(hint: 'AAFCS1234A', controller: pan)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _openManualVerify(
                      _gstManualLink,
                      'Verify GSTIN — GST Portal',
                      (v) => _gstinVerified = v,
                    ),
                    icon: Icon(
                      _gstinVerified ? Icons.check_circle : Icons.open_in_new,
                      size: 16,
                      color: _gstinVerified ? OC.success : OC.brand,
                    ),
                    label: Text(
                      _gstinVerified
                          ? 'GSTIN verified'
                          : 'Verify on GST Portal',
                      style: oDm(12, FontWeight.w600,
                          _gstinVerified ? OC.success : OC.brand),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _openManualVerify(
                      VerificationLinks.pan,
                      'Verify PAN — Income Tax Portal',
                      (v) => _panVerified = v,
                    ),
                    icon: Icon(
                      _panVerified ? Icons.check_circle : Icons.open_in_new,
                      size: 16,
                      color: _panVerified ? OC.success : OC.brand,
                    ),
                    label: Text(
                      _panVerified
                          ? 'PAN verified'
                          : 'Verify on Income Tax Portal',
                      style: oDm(12, FontWeight.w600,
                          _panVerified ? OC.success : OC.brand),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _openManualVerify(
                  VerificationLinks.incomeTaxRegister,
                  'Register — Income Tax Portal',
                  (_) {},
                ),
                style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 4)),
                child: Text(
                  "New to the portal? Register on Income Tax Portal",
                  style: oDm(11, FontWeight.w500, OC.text3),
                ),
              ),
            ),
            const SizedBox(height: 14),
            oFieldPair(
              context,
              'CIN (if applicable)',
              oInput(hint: 'U74999MH2020PTC000000', controller: cin),
              'Year of Incorporation *',
              oInput(
                  hint: '2018', type: TextInputType.number, controller: year),
            ),
          ]),
        ),
        oCard(
          title: 'Contact & Address',
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            oFieldPair(
              context,
              'Business Email *',
              oInput(
                  hint: 'info@acmepvt.com',
                  type: TextInputType.emailAddress,
                  controller: businessEmail),
              'Business Phone *',
              oInput(
                  hint: '+91 98765 43210',
                  type: TextInputType.phone,
                  controller: businessPhone),
            ),
            const SizedBox(height: 14),
            oLabel('Registered Address *'),
            oInput(
                hint: 'Flat No., Building, Street Name...',
                maxLines: 3,
                controller: address),
            const SizedBox(height: 14),
            oFieldPair(
              context,
              'City *',
              oInput(hint: 'Mumbai', controller: city),
              'State *',
              oSelect(states,
                  value: widget.data.state,
                  onChanged: (v) =>
                      setState(() => widget.data.state = v ?? '')),
            ),
            const SizedBox(height: 14),
            oFieldPair(
                context,
                'Pincode *',
                oInput(hint: '400001', controller: pincode),
                'Country *',
                oInput(hint: 'India', controller: country)),
          ]),
        ),
        if (_error != null) oInfoRow(_error!, ok: false),
        oActionRow(
            onBack: widget.onBack, nextLabel: 'Save & Continue', onNext: _save),
      ],
    );
  }
}
