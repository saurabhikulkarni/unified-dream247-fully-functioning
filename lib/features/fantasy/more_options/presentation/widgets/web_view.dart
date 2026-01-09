import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:Dream247/core/global_widgets/sub_container.dart';

class CustomWebView extends StatefulWidget {
  final String title, url;
  const CustomWebView({super.key, required this.title, required this.url});

  @override
  State<CustomWebView> createState() => _CustomWebViewState();
}

class _CustomWebViewState extends State<CustomWebView> {
  InAppWebViewController? webViewController;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return SubContainer(
      showAppBar: true,
      showWalletIcon: false,
      headerText: widget.title,
      addPadding: false,
      child: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              useOnDownloadStart: true,
              mediaPlaybackRequiresUserGesture: false,
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
            },

            // VERY IMPORTANT: Detect navigation change
            onLoadStart: (controller, url) {
              _handleNavigation(url.toString());
            },

            onLoadStop: (controller, url) {
              _handleNavigation(url.toString());
            },

            onProgressChanged: (controller, progress) {
              setState(() {
                this.progress = progress / 100;
              });
            },
          ),
          if (progress < 1.0) LinearProgressIndicator(value: progress),
        ],
      ),
    );
  }

  // 👇 Watch for success or failure URLs
  void _handleNavigation(String url) {
    if (url.contains("success") ||
        url.contains("paid") ||
        url.contains("completed")) {
      Navigator.pop(context, "success"); // return result
    } else if (url.contains("failed") || url.contains("cancel")) {
      Navigator.pop(context, "failed");
    }
  }
}
