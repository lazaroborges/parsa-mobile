import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pluggy_connect/flutter_pluggy_connect.dart';
import 'package:http/http.dart' as http;

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
    _fetchConnectToken();
  }

  Future<void> _fetchConnectToken() async {
    final response = await http.get(Uri.parse(
        'https://naturally-creative-boxer.ngrok-free.app/open/auth/'));
    if (response.statusCode == 200) {
      setState(() {
        _connectToken = jsonDecode(response.body)['connect_token'];
      });
    } else {
      print('Failed to fetch connect token');
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
            },
            onClose: () {
              print('Closed');
              Navigator.pop(
                  context); // Close the PluggyConnect widget and return to the previous screen
            },
            onError: (error) {
              print('Error');
              print(jsonEncode(error));
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
