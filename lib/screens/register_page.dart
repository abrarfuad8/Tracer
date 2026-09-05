import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/user_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final UserService _userService = UserService();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      email: _emailController.text.trim().toLowerCase(),
      password: _passwordController.text,
    );

    try {
      final success = await _userService.registerUser(user);

      if (!mounted) return;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An account with this email already exists'),
          ),
        );

        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to create account')));
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
      appBar: AppBar(title: const Text('Create Account')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Icon(Icons.person_add_outlined, size: 70),

              const SizedBox(height: 20),

              const Text(
                'Create your Tracer account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                'Join Tracer and start reporting lost items.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your name';
                  }

                  if (value.trim().length < 3) {
                    return 'Name must be at least 3 characters';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }

                  final email = value.trim().toLowerCase();

                  final emailRegex = RegExp(
                    r'^[a-z0-9]+([._%+-][a-z0-9]+)*@[a-z0-9-]+(\.[a-z0-9-]+)+$',
                  );

                  if (!emailRegex.hasMatch(email)) {
                    return 'Please enter a valid email';
                  }

                  // Commonly mistyped email domains
                  const invalidDomains = {
                    'gmai.com',
                    'gmial.com',
                    'gamil.com',
                    'gmail.co',
                    'gmail.con',
                    'gmail.cmo',
                    'yaho.com',
                    'yahoo.con',
                    'hotmai.com',
                    'hotmial.com',

                    'outlok.com',
                    'outlook.con',
                    'gmail.om',
                    'gmain.com',
                    'gimal.com',
                    'gmial.om',
                  };

                  final domain = email.split('@').last;

                  if (invalidDomains.contains(domain)) {
                    return 'Please enter a valid email domain';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }

                  final password = value;
                  final name = _nameController.text.trim().toLowerCase();
                  final email = _emailController.text.trim().toLowerCase();

                  if (password.length < 8) {
                    return 'Password must be at least 8 characters';
                  }

                  if (!RegExp(r'[A-Z]').hasMatch(password)) {
                    return 'Password must contain an uppercase letter';
                  }

                  if (!RegExp(r'[a-z]').hasMatch(password)) {
                    return 'Password must contain a lowercase letter';
                  }

                  if (!RegExp(r'[0-9]').hasMatch(password)) {
                    return 'Password must contain a number';
                  }

                  if (!RegExp(
                    r'[!@#$%^&*(),.?":{}|<>_\-+=/\\[\]]',
                  ).hasMatch(password)) {
                    return 'Password must contain a special character';
                  }

                  if (password.toLowerCase() == name) {
                    return 'Password cannot be the same as your name';
                  }

                  if (password.toLowerCase() == email) {
                    return 'Password cannot be the same as your email';
                  }

                  const commonPasswords = {
                    'password',
                    'password123',
                    '12345678',
                    '123456789',
                    '1234567890',
                    'qwerty',
                    'qwerty123',
                    'admin',
                    'admin123',
                    'welcome',
                    'welcome123',
                    'letmein',
                    'iloveyou',
                    'abc123',
                    '11111111',
                    '00000000',
                  };

                  if (commonPasswords.contains(password.toLowerCase())) {
                    return 'This password is too common';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }

                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
