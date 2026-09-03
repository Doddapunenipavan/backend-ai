import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_data.dart';
import 'onboarding_theme.dart';
import 'steps/agreement_step.dart';
import 'steps/application_status_step.dart';
import 'steps/auth_step.dart';
import 'steps/bank_linking_step.dart';
import 'steps/business_details_step.dart';
import 'steps/document_upload_step.dart';
import 'steps/kyc_verification_step.dart';

/// Controller/shell for the 7-step merchant onboarding flow.
///
/// Persists the user's current step to SharedPreferences so that
/// backgrounding + reopening the app resumes at the exact same step.
class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({super.key});

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen>
    with WidgetsBindingObserver {
  int currentStep = 0;
  final Set<int> completedSteps = {};
  final OnboardingData data = OnboardingData();
  bool _restored = false;

  static const _kStepKey = 'onboarding_current_step';
  static const _kCompletedKey = 'onboarding_completed_steps';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _restoreProgress();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Save whenever app goes to background / gets paused. Guarantees the
  /// step is persisted even if the OS kills the process from background.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _saveProgress();
    }
  }

  Future<void> _restoreProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStep = prefs.getInt(_kStepKey) ?? 0;
      final savedCompleted = prefs.getStringList(_kCompletedKey) ?? [];
      if (!mounted) return;
      setState(() {
        currentStep = savedStep.clamp(0, onboardingSteps.length - 1);
        completedSteps
          ..clear()
          ..addAll(savedCompleted.map(int.parse));
        _restored = true;
      });
    } catch (_) {
      // Corrupt prefs — start fresh.
      if (!mounted) return;
      setState(() => _restored = true);
    }
  }

  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kStepKey, currentStep);
      await prefs.setStringList(
        _kCompletedKey,
        completedSteps.map((e) => e.toString()).toList(),
      );
    } catch (_) {
      // Silently ignore — worst case user restarts at step 1.
    }
  }

  /// Dismiss any open keyboard / focused field *before* swapping the page
  /// content. Changing `currentStep` rebuilds an entirely different subtree —
  /// if a TextField below is still focused (keyboard open/animating) when
  /// that happens, the old RenderEditable can get disposed mid-layout.
  void _unfocus() => FocusManager.instance.primaryFocus?.unfocus();

  /// Runs [fn] inside setState after the current frame finishes, so
  /// keyboard/focus teardown doesn't race the step swap. Also persists
  /// the new step to prefs.
  void _deferredSetState(VoidCallback fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(fn);
        _saveProgress();
      }
    });
  }

  void goToStep(int i) {
    _unfocus();
    _deferredSetState(() => currentStep = i);
  }

  void nextStep() {
    _unfocus();
    _deferredSetState(() {
      completedSteps.add(currentStep);
      if (currentStep < onboardingSteps.length - 1) currentStep++;
    });
  }

  void prevStep() {
    _unfocus();
    if (currentStep > 0) _deferredSetState(() => currentStep--);
  }

  @override
  Widget build(BuildContext context) {
    // Show a lightweight loading state until we've restored, so the user
    // never sees "step 1" flash before jumping to their actual last step.
    if (!_restored) {
      return const Scaffold(
        backgroundColor: Color(0xFFF1F3F5),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1A56DB)),
        ),
      );
    }

    final isWide = MediaQuery.of(context).size.width > 700;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: OC.surface3,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: Row(
                children: [
                  if (isWide) _sidebar(),
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        isWide ? 40 : 16,
                        24,
                        isWide ? 40 : 16,
                        24 + bottomInset,
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 640),
                          child: KeyedSubtree(
                            key: ValueKey(currentStep),
                            child: _stepFor(currentStep),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Header ----------------
  Widget _header() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: OC.surface,
        border: Border(bottom: BorderSide(color: OC.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: OC.brand,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              Text('FlexTenure',
                  style: oSora(18, FontWeight.w700, OC.brand, ls: -0.3)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: OC.brandLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Step ${currentStep + 1} of ${onboardingSteps.length}',
              style: oSora(12, FontWeight.w500, OC.brand),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Sidebar ----------------
  Widget _sidebar() {
    return Container(
      width: 260,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: const BoxDecoration(
        color: OC.surface,
        border: Border(right: BorderSide(color: OC.border)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Text('ONBOARDING',
                  style: oSora(11, FontWeight.w500, OC.text3, ls: 0.8)),
            ),
            for (int i = 0; i < onboardingSteps.length; i++) ...[
              _stepItem(i),
              if (i < onboardingSteps.length - 1)
                Container(
                  margin: const EdgeInsets.only(left: 33),
                  width: 1,
                  height: 20,
                  color: OC.border,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _stepItem(int i) {
    final isActive = i == currentStep;
    final isDone = completedSteps.contains(i) && !isActive;
    final isReachable =
        isDone || isActive || completedSteps.contains(i - 1) || i == 0;
    return InkWell(
      onTap: isReachable ? () => goToStep(i) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: isActive ? OC.brandLight : Colors.transparent,
        child: Row(
          children: [
            if (isActive)
              Container(
                width: 3,
                height: 28,
                color: OC.brand,
                margin: const EdgeInsets.only(right: -3),
              ),
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isActive ? OC.brand : (isDone ? OC.successBg : OC.surface2),
                border: Border.all(
                  color:
                      isActive ? OC.brand : (isDone ? OC.success : OC.border2),
                  width: 1.5,
                ),
              ),
              child: Text(
                isDone ? '✓' : '${i + 1}',
                style: oSora(
                  12,
                  FontWeight.w600,
                  isActive ? Colors.white : (isDone ? OC.success : OC.text3),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    onboardingSteps[i].label,
                    style: oDm(
                      13,
                      isActive ? FontWeight.w500 : FontWeight.w400,
                      isActive ? OC.brand : (isDone ? OC.success : OC.text2),
                    ),
                  ),
                  Text(onboardingSteps[i].sub,
                      style: oDm(11, FontWeight.w400, OC.text3)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Step routing ----------------
  Widget _stepFor(int step) {
    switch (step) {
      case 0:
        return AuthStep(data: data, onNext: nextStep);
      case 1:
        return BusinessDetailsStep(
            data: data, onNext: nextStep, onBack: prevStep);
      case 2:
        return DocumentUploadStep(
            data: data, onNext: nextStep, onBack: prevStep);
      case 3:
        return KycVerificationStep(
            data: data, onNext: nextStep, onBack: prevStep);
      case 4:
        return BankLinkingStep(data: data, onNext: nextStep, onBack: prevStep);
      case 5:
        return AgreementStep(data: data, onNext: nextStep, onBack: prevStep);
      default:
        return ApplicationStatusStep(data: data);
    }
  }
}
