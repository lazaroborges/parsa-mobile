// import 'package:app_links/app_links.dart';
// import 'package:flutter/material.dart';

// import 'utils.dart';
// import 'package:parsa/core/services/pluggy/src/connect_webview.dart';

// // TODO: Add types and replace Object
// typedef OnSuccessCallback = void Function(dynamic data);
// typedef OnErrorCallback = void Function(dynamic error);
// typedef OnEventCallback = void Function(dynamic payload);

// final appLinks = AppLinks();

// class PluggyConnect extends StatefulWidget {
//   PluggyConnect(
//       {super.key,
//       this.url = 'https://connect.pluggy.ai',
//       required this.connectToken,
//       this.includeSandbox = false,
//       this.updateItem,
//       this.connectorTypes = const [],
//       this.connectorIds = const [],
//       this.selectedConnectorId,
//       this.countries = const [],
//       this.language = 'pt',
//       this.onSuccess,
//       this.onError,
//       this.onOpen,
//       this.onClose,
//       this.onEvent}) {
//     WidgetsFlutterBinding.ensureInitialized();
//     _connectUrl = buildConnectUrl(
//         connectToken,
//         updateItem,
//         connectorIds,
//         connectorTypes,
//         countries,
//         includeSandbox,
//         language,
//         selectedConnectorId,
//         url);
//   }

//   final String url;
//   final String connectToken;
//   final bool includeSandbox;
//   final String? updateItem;
//   final int? selectedConnectorId;

//   // TODO: Add types
//   final List<String> connectorTypes;
//   final List<int> connectorIds;

//   // TODO: Add types
//   final List<String> countries;
//   final String language;
//   final OnSuccessCallback? onSuccess;
//   final OnErrorCallback? onError;
//   final VoidCallback? onOpen;
//   final VoidCallback? onClose;
//   final OnEventCallback? onEvent;
//   late final String _connectUrl;

//   @override
//   State<StatefulWidget> createState() => _PluggyConnectState();
// }

// class _PluggyConnectState extends State<PluggyConnect> {
//   String? _lastTimestamp;
//   bool _isInitialLoaded = false;

//   _handleConnectUrlUpdate(String query) {
//     final queryParams = Uri.splitQueryString(query.replaceFirst('?', ''));
//     final events = queryParams['events'];
//     final itemId = queryParams['item_id'];
//     final timestamp = queryParams['timestamp'];
//     final itemStatus = queryParams['item_status'];
//     final executionStatus = queryParams['execution_status'];
//     final connectorId = queryParams['connector_id'];
//     final connectorName = queryParams['connector_name'];
//     final error = queryParams['error'];
//     final eventType = events?.split(',').last;

//     // skip if there is no new events
//     if (eventType == null || _lastTimestamp == timestamp) {
//       return;
//     }

//     setState(() {
//       _lastTimestamp = timestamp;
//     });

//     // event item data
//     final itemData = {
//       'id': itemId,
//       'status': itemStatus,
//       'executionStatus': executionStatus,
//     };

//     // event connector data
//     final connectorData = {
//       'id': connectorId,
//       'name': connectorName,
//     };

//     if (isConnectEventType(eventType)) {
//       final Map<String, dynamic> data = {};
//       if (isInstitutionSelectedEventType(eventType)) {
//         if (connectorId != null && connectorName != null) {
//           data['connector'] = connectorData;
//         } else {
//           data['connector'] = null;
//         }
//       }
//       if (eventsWithItemInPayload(eventType)) {
//         data['item'] = itemData;
//       }

//       widget.onEvent?.call({
//         'event': eventType,
//         'timestamp': DateTime.now().millisecondsSinceEpoch,
//         ...data
//       });
//       return;
//     }

//     switch (eventType) {
//       case 'OPEN':
//         widget.onOpen?.call();
//         break;
//       case 'CLOSE':
//         widget.onClose?.call();
//         if (_isInitialLoaded) {
//           setState(() => _isInitialLoaded = false);
//         }
//         break;
//       case 'ERROR':
//         widget.onError?.call({
//           'message': error ?? '',
//           ...(itemId != null
//               ? {
//                   'data': {
//                     'item': itemData,
//                   }
//                 }
//               : {})
//         });
//         break;
//       case 'SUCCESS':
//         widget.onSuccess?.call({'item': itemData});
//         break;
//     }
//   }

//   _handleConnectWebViewLoadStart() async {
//     if (!_isInitialLoaded) {
//       // Check if the app was opened by a deep link
//       String? link = await appLinks.getLatestLinkString();

//       if (link != null) {
//         // In this case, we need to unmount the new PluggyConnect widget and return to the previous screen
//         // TODO: find a better way to solve this
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           Navigator.pop(context);
//         });
//         return;
//       }

//       // set isInitialLoaded true, to toggle opacity
//       setState(() => _isInitialLoaded = true);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     var connectWebView = ConnectWebView(
//       url: widget._connectUrl,
//       onLocationUpdate: _handleConnectUrlUpdate,
//       onWebViewLoadStart: _handleConnectWebViewLoadStart,
//     );

//     return Opacity(
//         opacity: _isInitialLoaded ? 1 : 0,
//         child: Stack(
//           children: [connectWebView],
//         ));
//   }
// }
