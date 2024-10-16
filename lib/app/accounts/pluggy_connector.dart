import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pluggy_connect/flutter_pluggy_connect.dart';
import 'package:http/http.dart' as http;
import 'package:parsa/app/layout/tabs.dart';
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/main.dart';

class PluggyConnectorPage extends StatefulWidget {
  const PluggyConnectorPage({super.key});

  @override
  _PluggyConnectorPageState createState() => _PluggyConnectorPageState();
}

class _PluggyConnectorPageState extends State<PluggyConnectorPage> {
  bool _showPluggyConnect = false;
  String _connectToken = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchConnectToken(context);
  }

  Future<void> _fetchConnectToken(BuildContext context) async {
    final auth0 = Auth0Provider.of(context)!.auth0;

    final credentials = await auth0.credentialsManager.credentials();

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
        _connectToken =
            responseBody['connect_token'].toString(); // Ensure it's a String
      });
    } else {
      print(
          'Failed to fetch connect token: ${response.statusCode} ${response.body}');
    }
  }

  void _togglePluggyConnect() {
    setState(() {
      _showPluggyConnect = !_showPluggyConnect;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _connectToken.isEmpty
        ? Center(child: CircularProgressIndicator())
        : PluggyConnect(
            includeSandbox: true,
            onSuccess: (data) {
              print('Success');
              print(jsonEncode(data));
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const TabsPage()),
              );
            },
            onClose: () {
              print('Closed');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const TabsPage()),
              );
            },
            onError: (error) {
              print('Error');
              print(jsonEncode(error));
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const TabsPage()),
              );
            },
            onOpen: () {
              print('Opened');
            },
            onEvent: (payload) {
              print('Event');
              print(jsonEncode(payload));
            },
            connectToken: _connectToken,
          );
  }
}
