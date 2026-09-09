import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'reset_password_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;

  const OtpVerificationPage({super.key, required this.email});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _otpController = TextEditingController();

  bool _isLoading = false;

  static const String baseUrl = 'http://192.168.8.80:5000';

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String otp = _otpController.text.trim();

    try {
      final http.Response response = await http.post(
        Uri.parse('$baseUrl/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email, 'otp': otp}),
      );

      if (!mounted) {
        return;
      }

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
        // الانتقال إلى صفحة إنشاء كلمة المرور الجديدة
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(email: widget.email),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['message']?.toString() ?? 'Invalid verification code',
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Email')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 50),

              const Icon(Icons.verified_user_outlined, size: 90),

              const SizedBox(height: 25),

              const Text(
                'Enter Verification Code',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 15),

              Text(
                'We sent a 6-digit verification code to:\n'
                '${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 35),

              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 6,
                decoration: const InputDecoration(
                  labelText: 'Verification Code',
                  hintText: '123456',
                  prefixIcon: Icon(Icons.pin_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the verification code';
                  }

                  if (value.trim().length != 6) {
                    return 'Code must contain 6 digits';
                  }

                  if (int.tryParse(value.trim()) == null) {
                    return 'Code must contain numbers only';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify Code'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
