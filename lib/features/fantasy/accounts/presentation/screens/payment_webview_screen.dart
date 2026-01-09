import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:Dream247/core/global_widgets/sub_container.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String htmlContent;

  const PaymentWebViewScreen({super.key, required this.htmlContent});

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  InAppWebViewController? webViewController;
  double progress = 0;

  @override
  Widget build(BuildContext context) {
    return SubContainer(
      showAppBar: true,
      showWalletIcon: false,
      headerText: "",
      addPadding: false,
      child: Stack(
        children: [
          InAppWebView(
            initialData: InAppWebViewInitialData(
              data: widget.htmlContent, // Load HTML directly
              mimeType: 'text/html',
              encoding: 'utf-8',
              baseUrl: WebUri('about:blank'),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              useOnDownloadStart: true,
              mediaPlaybackRequiresUserGesture: false,
            ),
            onWebViewCreated: (controller) {
              webViewController = controller;
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
}
