import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Opens a verification link (PAN / GST / Aadhaar / DigiLocker / Video KYC
/// / eSign) inside the app. When the person taps "Done, I've completed
/// this" after finishing on the government page, this pops back with
/// `true` and the calling screen marks that step as verified.
///
/// Some government portals (e.g. the Income Tax e-filing PAN check) are
/// JS-heavy single-page apps that don't render inside an in-app WebView
/// — they show a blank shell / footer only. For those cases there's an
/// "Open in Browser" button that launches the real system browser
/// instead, where the page works normally.
class VerificationLinkScreen extends StatefulWidget {
  const VerificationLinkScreen(
      {super.key, required this.url, required this.title});

  final String url;
  final String title;

  @override
  State<VerificationLinkScreen> createState() => _VerificationLinkScreenState();
}

class _VerificationLinkScreenState extends State<VerificationLinkScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) => setState(() => _loading = true),
        onPageFinished: (_) => setState(() => _loading = false),
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(widget.url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(false),
        ),
        actions: [
          IconButton(
            tooltip: 'Open in Browser',
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openInBrowser,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.amber.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: Colors.brown),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Page looks blank or incomplete? Tap "Open in Browser" above — some government sites need a real browser.',
                    style: TextStyle(fontSize: 12, color: Colors.brown),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_loading) const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text("Done, I've completed this"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
