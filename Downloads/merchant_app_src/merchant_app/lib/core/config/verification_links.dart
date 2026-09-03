/// MANUAL (no-API) government verification links.
///
/// These open the real official government portals inside an in-app
/// webview (see VerificationLinkScreen). The person completes the check
/// themselves on the government site, then taps "Done, I've completed
/// this" back in the app — no API integration or key needed.
class VerificationLinks {
  VerificationLinks._();

  // PAN verification — official Income Tax India static PAN-verification
  // page. Using incometaxindia.gov.in (not the Angular SPA at
  // eportal.incometax.gov.in) since that SPA silently redirects to '#/'
  // on mobile browsers before you ever reach the actual form.
  /// Official Income Tax "Verify Your PAN" (merchant KYC)
  static const String pan =
      'https://eportal.incometax.gov.in/iec/foservices/#/pre-login/verifyYourPAN/1';

  // Income Tax e-filing portal registration — for merchants who don't
  // have an e-filing account yet and need to create one before they can
  // do anything else on the portal. Same site as `pan` above, so it can
  // be flaky/blank in embedded webviews — use "Open in Browser" if so.
  static const String incomeTaxRegister =
      'https://eportal.incometax.gov.in/iec/foservices/#/pre-login/register';

  // Aadhaar — UIDAI's official self-service portal (myAadhaar). User logs
  // in with their own Aadhaar OTP and can view/download proof there.
  static const String aadhaar =
      'https://tathya.uidai.gov.in/access/login?role=resident';

  // DigiLocker — official government document locker. User logs in with
  // their own Aadhaar/mobile and links/fetches documents manually.
  static const String digilocker = 'https://www.digilocker.gov.in/';

  // Video KYC — no single public government portal exists for this since
  // it needs a live agent on a vendor platform. Paste your vendor's link
  // here once you have one.
  static const String video = 'https://REPLACE_ME_VIDEO_KYC_LINK';

  // eSign (used on the Agreement step). Heads-up: there is no public,
  // walk-up "manual" NSDL eSign page — real Aadhaar eSign (NSDL / Protean
  // / C-DAC) only works through a paid ASP/API integration, which is why
  // the old esign.nsdl.com link wouldn't load. Until you set up a proper
  // eSign provider account, this points at DigiLocker (which does open
  // and lets a person sign into their own account) as the closest
  // working manual stand-in.
  static const String esign = 'https://www.digilocker.gov.in/';
}
