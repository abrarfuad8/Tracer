import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'otp_verification_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  // عنوان السيرفر
  static const String baseUrl = 'http://192.168.8.80:5000';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    // التحقق من النموذج
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String email = _emailController.text.trim().toLowerCase();

    try {
      final http.Response response = await http.post(
        Uri.parse('$baseUrl/send-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (!mounted) {
        return;
      }

      // التأكد أن السيرفر أعاد JSON
      if (response.body.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Server returned an empty response')),
        );
        return;
      }

      final dynamic decodedData = jsonDecode(response.body);

      if (decodedData is! Map<String, dynamic>) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid server response')),
        );
        return;
      }

      final Map<String, dynamic> data = decodedData;

      if (response.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code sent to your email')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(email: email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message']?.toString() ?? 'Failed to send verification code',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not connect to the server')),
      );
    } finally {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email';
    }

    final String email = value.trim();

    final RegExp emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Icon
                const Icon(Icons.lock_reset, size: 90),

                const SizedBox(height: 25),

                // Title
                const Text(
                  'Reset Your Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                // Description
                const Text(
                  'Enter your email address and we will send '
                  'you a verification code.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 35),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: _validateEmail,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    hintText: 'example@gmail.com',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 25),

                // Send OTP button
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _sendOtp,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      _isLoading ? 'Sending...' : 'Send Verification Code',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
