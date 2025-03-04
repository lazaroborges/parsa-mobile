import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:parsa/app/layout/tabs.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:http/http.dart' as http;

class PluggyConnectorPage extends StatefulWidget {
  final String? accountId;
  final bool isUpdate;

  const PluggyConnectorPage({
    super.key, 
    this.accountId,
    this.isUpdate = false,
  });

  @override
  _PluggyConnectorPageState createState() => _PluggyConnectorPageState();
}

class _PluggyConnectorPageState extends State<PluggyConnectorPage> {
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openConnectUrl(context);
    });
  }

  Future<void> _openConnectUrl(BuildContext context) async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final auth0Provider = Provider.of<Auth0Provider>(context, listen: false);
      final credentials = await auth0Provider.credentials;

      if (credentials == null) {
        throw Exception('No credentials available');
      }

      // Determine which endpoint to use based on whether this is an update
      final String endpoint = widget.isUpdate 
          ? '$apiEndpoint/open/connect-mobile-update/' 
          : '$apiEndpoint/open/connect-mobile/';
      
      // For updates, use POST with accountId in the body
      final response = widget.isUpdate && widget.accountId != null
          ? await http.post(
              Uri.parse(endpoint),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${credentials.accessToken}',
              },
              body: jsonEncode({
                'accountId': widget.accountId,
              }),
            )
          : await http.get(
              Uri.parse(endpoint),
              headers: {
                'Authorization': 'Bearer ${credentials.accessToken}',
              },
            );

      // Assuming the response contains the URL to redirect to
      if (response.statusCode == 200) {
        final url = Uri.parse(json.decode(response.body)['redirect_url']);
        if (await canLaunchUrl(url)) {
          await launchUrl(
            url,
            mode: LaunchMode.inAppWebView,
          );
          Navigator.of(context).pop();
        }
      } else {
        throw Exception('Failed to get redirect URL: ${response.statusCode} - ${response.body}');
      }

    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $_error'),
              ElevatedButton(
                onPressed: () => _openConnectUrl(context),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Título'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Conectando..."),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _openConnectUrl(context),
              child: Text("Tentar novamente"),
            ),
          ],
        ),
      ),
    );
  }
}