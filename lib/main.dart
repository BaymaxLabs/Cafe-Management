import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const TestMessageApp());
}

class TestMessageApp extends StatelessWidget {
  const TestMessageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TestMessageScreen(),
    );
  }
}

class TestMessageScreen extends StatefulWidget {
  const TestMessageScreen({super.key});

  @override
  State<TestMessageScreen> createState() => _TestMessageScreenState();
}

class _TestMessageScreenState extends State<TestMessageScreen> {
  static final _endpoint = Uri.parse('http://localhost:3000/api/test');

  String _message = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadMessage();
  }

  Future<void> _loadMessage() async {
    try {
      final response = await http.get(_endpoint);
      final body = jsonDecode(response.body);

      if (response.statusCode != 200 || body is! Map<String, dynamic>) {
        throw const FormatException('Invalid API response');
      }

      final message = body['message'];
      if (message is! String) {
        throw const FormatException('Missing message field');
      }

      if (mounted) {
        setState(() => _message = message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'Unable to load message');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }
}