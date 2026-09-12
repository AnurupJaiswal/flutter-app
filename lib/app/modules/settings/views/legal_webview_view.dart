import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LegalWebViewView extends StatefulWidget {
  final String? title;
  final String? url;
  final String? htmlData;
  final bool? isPrivacyPolicy;

  const LegalWebViewView({
    super.key,
    this.title,
    this.url,
    this.htmlData,
    this.isPrivacyPolicy,
  });

  @override
  State<LegalWebViewView> createState() => _LegalWebViewViewState();
}

class _LegalWebViewViewState extends State<LegalWebViewView> {
  late final WebViewController _controller;
  int _loadingProgress = 0;
  bool _isLoading = true;
  bool _hasError = false;

  late final String _pageTitle;
  late final String? _pageUrl;
  late final String? _htmlContent;
  late final bool _isPrivacy;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>?;
    _pageTitle = widget.title ?? (args?['title'] ?? 'Document');
    _pageUrl = widget.url ?? args?['url'];
    _htmlContent = widget.htmlData ?? args?['htmlData'];
    _isPrivacy = widget.isPrivacyPolicy ?? (args?['isPrivacy'] ?? true);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(CC.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress;
              });
            }
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _hasError = true;
                _isLoading = false;
              });
            }
          },
        ),
      );

    _loadContent();
  }

  void _loadContent() {
    final html = _htmlContent;
    final url = _pageUrl;
    if (html != null && html.isNotEmpty) {
      _loadHtmlData(html);
    } else if (url != null && url.isNotEmpty) {
      try {
        _controller.loadRequest(Uri.parse(url));
      } catch (_) {
        _loadHtmlData(_getFallbackHtml());
      }
    } else {
      _loadHtmlData(_getFallbackHtml());
    }
  }

  void _loadHtmlData(String rawHtml) {
    setState(() {
      _isLoading = false;
    });

    if (rawHtml.toLowerCase().contains('<html') || rawHtml.toLowerCase().contains('<!doctype html')) {
      _controller.loadHtmlString(rawHtml);
    } else {
      final formattedHtml = '''
      <!DOCTYPE html>
      <html>
      <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {
            background-color: ${CC.isDark ? '#121212' : '#FFFFFF'};
            color: ${CC.isDark ? '#E0E0E0' : '#212121'};
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            padding: 20px;
            line-height: 1.6;
          }
          h1 {
            color: ${CC.isDark ? '#00E5FF' : '#00A3B5'};
            font-size: 24px;
            margin-bottom: 8px;
          }
          .subtitle {
            color: ${CC.isDark ? '#9E9E9E' : '#757575'};
            font-size: 13px;
            margin-bottom: 24px;
            border-bottom: 1px solid ${CC.isDark ? '#2C2C2C' : '#E0E0E0'};
            padding-bottom: 12px;
          }
          h2 {
            color: ${CC.isDark ? '#FFFFFF' : '#000000'};
            font-size: 16px;
            margin-top: 20px;
            margin-bottom: 8px;
          }
          p {
            color: ${CC.isDark ? '#B0B0B0' : '#424242'};
            font-size: 14px;
            margin-bottom: 16px;
          }
          a {
            color: ${CC.isDark ? '#00E5FF' : '#00A3B5'};
          }
        </style>
      </head>
      <body>
        $rawHtml
      </body>
      </html>
      ''';
      _controller.loadHtmlString(formattedHtml);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: CC.background,
      child: Scaffold(
        backgroundColor: CC.background,
        appBar: CW.commonAppbar(
          isNotHomepage: true,
          title: _pageTitle,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_rounded, color: CC.textPrimary, size: 20),
              tooltip: "Reload HTML Data",
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _isLoading = true;
                });
                _loadContent();
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              if (_isLoading && _loadingProgress < 100)
                LinearProgressIndicator(
                  value: _loadingProgress / 100.0,
                  backgroundColor: CC.surface,
                  color: CC.primary,
                  minHeight: 3,
                ),
              Expanded(
                child: Stack(
                  children: [
                    RepaintBoundary(
                      child: WebViewWidget(controller: _controller),
                    ),
                    if (_hasError)
                      Container(
                        color: CC.background,
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.code_off_rounded, size: 48, color: CC.grey),
                              const SizedBox(height: 16),
                              Text(
                                "Unable to display HTML data",
                                style: TS.sectionTitle(color: CC.textPrimary),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Tap below to render default document template.",
                                style: TS.caption(color: CC.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              CW.commonBtn(
                                title: "Render Document",
                                width: 200,
                                onTap: () {
                                  setState(() {
                                    _hasError = false;
                                  });
                                  _loadHtmlData(_getFallbackHtml());
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getFallbackHtml() {
    final titleText = _isPrivacy ? "Privacy Policy" : "Terms & Conditions";
    final bodyContent = _isPrivacy
        ? '''
        <h2>1. Information We Collect</h2>
        <p>Lala AI collects channel analytics data, user account metadata, and prompt interactions to optimize content creation workflows and AI response accuracy.</p>

        <h2>2. Data Security & Encryption</h2>
        <p>All stored assets, scripts, and API authorization tokens are encrypted using AES-256 standards. We do not sell your personal or channel data to third parties.</p>

        <h2>3. Third-Party Integrations</h2>
        <p>When connecting social media accounts (such as YouTube, TikTok, or Instagram), data fetched is solely utilized for performance analytics and script generation.</p>

        <h2>4. Your Data Rights</h2>
        <p>You reserve the right to request a full export of your creator data or permanently delete your account at any time within the app settings.</p>
        '''
        : '''
        <h2>1. Acceptance of Terms</h2>
        <p>By accessing or using Lala AI services, you agree to be bound by these Terms and Conditions. If you do not agree, please discontinue use of the platform.</p>

        <h2>2. Content Ownership</h2>
        <p>You retain 100% full ownership rights to all scripts, hooks, and creative outputs generated through Lala AI tools.</p>

        <h2>3. Fair Usage Policy</h2>
        <p>Users must adhere to daily API generation thresholds specified in their active subscription tier. Automated scraping or misuse is strictly prohibited.</p>

        <h2>4. Subscriptions & Billing</h2>
        <p>Subscriptions renew automatically on a recurring monthly or annual basis. You may modify or cancel your plan at any time through the Manage Subscription section.</p>
        ''';

    return '''
    <h1>$titleText</h1>
    <div class="subtitle">Effective Date: September 2026 | Lala AI Legal Center</div>
    $bodyContent
    ''';
  }
}
