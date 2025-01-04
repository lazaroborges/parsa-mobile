import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pluggy_connect/flutter_pluggy_connect.dart';
import 'package:http/http.dart' as http;
import 'package:parsa/app/layout/tabs.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/i18n/translations.g.dart';
import 'package:parsa/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;

class PluggyConnectorPage extends StatefulWidget {
  const PluggyConnectorPage({super.key});

  @override
  _PluggyConnectorPageState createState() => _PluggyConnectorPageState();
}

class _PluggyConnectorPageState extends State<PluggyConnectorPage> {
  String _connectToken = '';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchConnectToken(context);
    });
  }

  Future<void> _fetchConnectToken(BuildContext context) async {
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

      final response = await http.get(
        Uri.parse('$apiEndpoint/api/auth/'),
        headers: {
          'Authorization': 'Bearer ${credentials.accessToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        setState(() {
          _connectToken = responseBody['connect_token'].toString();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch token: ${response.statusCode}');
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
                onPressed: () => _fetchConnectToken(context),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: PluggyConnect(
        includeSandbox: !kReleaseMode,
        onSuccess: (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.connections.success)),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const TabsPage()),
          );
        },
        onClose: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const TabsPage()),
          );
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(t.connections.error)),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const TabsPage()),
          );
        },
        connectToken: _connectToken,
      ),
    );
  }
}
