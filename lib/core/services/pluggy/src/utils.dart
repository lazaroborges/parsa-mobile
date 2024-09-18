import 'dart:convert';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'version.dart';

const _connectEvents = [
  'SUBMITTED_CONSENT',
  'SUBMITTED_LOGIN',
  'SUBMITTED_MFA',
  'SELECTED_INSTITUTION',
  'LOGIN_SUCCESS',
  'LOGIN_MFA_SUCCESS',
  'LOGIN_STEP_COMPLETED',
  'ITEM_RESPONSE'
];

const _connectItemRelatedEvents = [
  'LOGIN_SUCCESS',
  'LOGIN_MFA_SUCCESS',
  'LOGIN_STEP_COMPLETED',
  'ITEM_RESPONSE'
];

buildConnectUrl(
    String connectToken,
    String? updateItem,
    List<int> connectorIds,
    List<String> connectorTypes,
    List<String> countries,
    bool includeSandbox,
    String language,
    int? selectedConnectorId,
    String url) {
  final queryParameters = {
    'connect_token': connectToken,
    'update_item': updateItem,
    'connector_ids': connectorIds.join(','),
    'connector_types': connectorTypes.join(','),
    'countries': countries.join(','),
    'with_sandbox': includeSandbox.toString(),
    'lang': language,
    'selected_connector_id': selectedConnectorId?.toString(),
    'sdkVersion': getSdkVersion(),
  };

  final query = Uri(queryParameters: queryParameters).query;
  return '$url?$query';
}

isConnectEventType(String event) {
  return _connectEvents.contains(event);
}

eventsWithItemInPayload(String event) {
  return _connectItemRelatedEvents.contains(event);
}

isInstitutionSelectedEventType(String event) {
  return event == 'SELECTED_INSTITUTION';
}

///
/// Utility to send a message payload as a JS 'message' event to an existing WebView instance.
///
sendMessageToWebView(InAppWebViewController? webViewController,
    Map<String, dynamic> payload) async {
  if (webViewController == null) {
    throw Exception("webViewController can't be null");
  }
  final sourceToInject = '''
      (function() {
        document.dispatchEvent(new MessageEvent('message', {
          data: ${jsonEncode(payload)}
        }));
      })();
    ''';
  await webViewController.evaluateJavascript(source: sourceToInject);
}
