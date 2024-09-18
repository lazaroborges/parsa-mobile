import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Ensure you're using the latest version of flutter_inappwebview
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

typedef OnLocationUpdateCallback = void Function(String url);
typedef OnWebViewCreatedCallback = void Function(
    InAppWebViewController controller);
typedef OnWebViewLoadStartCallback = void Function();

class ConnectWebView extends StatelessWidget {
  const ConnectWebView({
    super.key,
    required this.url,
    required this.onLocationUpdate,
    required this.onWebViewLoadStart,
  });

  final String url;
  final OnLocationUpdateCallback onLocationUpdate;
  final OnWebViewLoadStartCallback onWebViewLoadStart;

  void _onWebViewCreated(InAppWebViewController controller) {
    controller.addJavaScriptHandler(
      handlerName: 'pluggyConnectHandler',
      callback: (args) {
        dynamic dataPayload;

        try {
          dataPayload = jsonDecode(args[0] as String);
        } catch (error) {
          return;
        }

        final String type = dataPayload['type'];
        final String message = dataPayload['message'] ?? '';

        if (type == 'OAUTH_OPEN' || type == 'LINK_OPEN') {
          _openLink(message);
          return;
        }

        if (type == 'LOCATION') {
          // Got a location URL update
          onLocationUpdate(message);
          return;
        }
      },
    );
  }

  /// Open a link outside the app
  Future<void> _openLink(String url) async {
    Uri parsedUri = Uri.parse(url);
    if (await canLaunchUrl(parsedUri)) {
      await launchUrl(parsedUri, mode: LaunchMode.externalApplication);
    }
    // Can't open URL, do nothing
  }

  void _onLoadStart(InAppWebViewController controller, Uri? uri) {
    onWebViewLoadStart();
  }

  void _onLoadStop(InAppWebViewController controller, Uri? uri) async {
    /* Note: We are injecting 'ReactNativeWebView' variable because it's implemented
       like this in Connect webapp. We'll keep it like this to simplify API in there. */
    await controller.evaluateJavascript(source: '''
      window.ReactNativeWebView = {
        postMessage: function(message) {
          window.flutter_inappwebview.callHandler("pluggyConnectHandler", message);
        }
      };
      true; // Note: This is required, or you'll sometimes get silent failures
    ''');
  }

  @override
  Widget build(BuildContext context) {
    /// This is required to avoid the webview to block the gestures of the parent widget
    var gestureRecognizers = <Factory<OneSequenceGestureRecognizer>>{
      Factory<OneSequenceGestureRecognizer>(
        () => EagerGestureRecognizer(),
      ),
    };

    return SafeArea(
      child: InAppWebView(
        gestureRecognizers: gestureRecognizers,
        initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(url))),
        onWebViewCreated: _onWebViewCreated,
        onLoadStart: _onLoadStart,
        onLoadStop: _onLoadStop,
        initialSettings: InAppWebViewSettings(
          // Updated setting based on breaking changes
          interceptOnlyAsyncAjaxRequests: true,
        ),
        // Handle potential crashes and type errors
        onConsoleMessage: (controller, consoleMessage) {
          if (kDebugMode) {
            print("Console Message: ${consoleMessage.message}");
          }
        },
      ),
    );
  }
}
