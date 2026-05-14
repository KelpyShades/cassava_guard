import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firebase_auth_service.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool _validEmail(String v) {
    return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v);
  }

  void _toast(String msg, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color ?? AppColors.primary,
        content: Text(msg),
      ),
    );
  }

  String _authErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is disabled in Firebase Console.';
      default:
        return e.message ?? e.code;
    }
  }

  Future<void> _goDashboard() async {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  Future<void> _login() async {
    final email = _email.text.trim();
    final password = _password.text;
    if (email.isEmpty || password.isEmpty) {
      _toast('Please enter your email and password', color: Colors.orange);
      return;
    }
    if (!_validEmail(email)) {
      _toast('Please enter a valid email address', color: Colors.orange);
      return;
    }
    setState(() => _busy = true);
    try {
      await FirebaseAuthService.signInWithEmail(
        email: email,
        password: password,
      );
      if (!mounted) return;
      _toast('Signed in', color: AppColors.primaryLight);
      await _goDashboard();
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _toast(_authErrorMessage(e), color: Colors.red.shade700);
      }
    } catch (e) {
      if (mounted) {
        _toast('Sign in failed: $e', color: Colors.red.shade700);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _google() async {
    setState(() => _busy = true);
    try {
      final cred = await FirebaseAuthService.signInWithGoogle();
      if (!mounted) return;
      if (cred == null) {
        _toast('Google sign-in cancelled', color: Colors.orange);
        return;
      }
      _toast('Signed in with Google', color: AppColors.primaryLight);
      await _goDashboard();
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _toast(_authErrorMessage(e), color: Colors.red.shade700);
      }
    } catch (e) {
      if (mounted) {
        _toast('Google sign-in failed: $e', color: Colors.red.shade700);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _email.text.trim();
    if (email.isEmpty || !_validEmail(email)) {
      _toast('Enter your email above first', color: Colors.orange);
      return;
    }
    setState(() => _busy = true);
    try {
      await FirebaseAuthService.sendPasswordResetEmail(email);
      if (mounted) {
        _toast('Password reset email sent', color: AppColors.primaryLight);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _toast(_authErrorMessage(e), color: Colors.red.shade700);
      }
    } catch (e) {
      if (mounted) {
        _toast('Could not send reset email: $e', color: Colors.red.shade700);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: primaryGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '🌿 CassavaGuard',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Protecting cassava crops with AI-powered disease detection',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textLight,
                                  ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Sign in',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !_busy,
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                            prefixIcon: Icon(Icons.email_outlined,
                                color: AppColors.textLight),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _password,
                          obscureText: true,
                          enabled: !_busy,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline,
                                color: AppColors.textLight),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _busy ? null : _login,
                            icon: _busy
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.login),
                            label: const Text('Login'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _busy
                                ? null
                                : () => Navigator.pushNamed(
                                      context,
                                      '/create-account',
                                    ),
                            icon: const Icon(Icons.person_add_outlined),
                            label: const Text('Create a new account'),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(),
                        ),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _busy ? null : _google,
                            icon: const Icon(Icons.g_mobiledata, size: 28),
                            label: const Text('Sign in with Google'),
                          ),
                        ),
                        TextButton(
                          onPressed: _busy ? null : _forgotPassword,
                          child: const Text('Forgot password?'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
