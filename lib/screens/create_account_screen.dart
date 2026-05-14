import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firebase_auth_service.dart';
import '../theme/app_theme.dart';

/// Register a new user with email/password (Firebase Auth).
/// Route: `/create-account`
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _displayName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _busy = false;

  @override
  void dispose() {
    _displayName.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
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
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      case 'operation-not-allowed':
        return 'Email/password sign-up is disabled in Firebase Console.';
      default:
        return e.message ?? e.code;
    }
  }

  Future<void> _submit() async {
    final email = _email.text.trim();
    final password = _password.text;
    final confirm = _confirmPassword.text;
    if (email.isEmpty || password.isEmpty) {
      _toast('Please enter email and password', color: Colors.orange);
      return;
    }
    if (!_validEmail(email)) {
      _toast('Please enter a valid email address', color: Colors.orange);
      return;
    }
    if (password.length < 6) {
      _toast('Password must be at least 6 characters', color: Colors.orange);
      return;
    }
    if (password != confirm) {
      _toast('Passwords do not match', color: Colors.orange);
      return;
    }
    setState(() => _busy = true);
    try {
      await FirebaseAuthService.createAccount(
        email: email,
        password: password,
        displayName: _displayName.text,
      );
      if (!mounted) return;
      _toast(
        'Account created. Check your email for a verification link.',
        color: AppColors.primaryLight,
      );
      Navigator.pushReplacementNamed(context, '/dashboard');
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        _toast(_authErrorMessage(e), color: Colors.red.shade700);
      }
    } catch (e) {
      if (mounted) {
        _toast('Sign up failed: $e', color: Colors.red.shade700);
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
      Navigator.pushReplacementNamed(context, '/dashboard');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: primaryGradient),
        child: SafeArea(
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
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed:
                                  _busy ? null : () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back),
                              tooltip: 'Back to sign in',
                            ),
                          ),
                          Text(
                            'Create account',
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
                            'We will send a verification link to your email.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: AppColors.textLight),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _displayName,
                            textCapitalization: TextCapitalization.words,
                            enabled: !_busy,
                            decoration: const InputDecoration(
                              labelText: 'Your name (optional)',
                              hintText: 'e.g. Kwame Mensah',
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: AppColors.textLight,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            enabled: !_busy,
                            decoration: const InputDecoration(
                              labelText: 'Email address',
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppColors.textLight,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _password,
                            obscureText: true,
                            enabled: !_busy,
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: AppColors.textLight,
                              ),
                              helperText: 'At least 6 characters',
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _confirmPassword,
                            obscureText: true,
                            enabled: !_busy,
                            decoration: const InputDecoration(
                              labelText: 'Confirm password',
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: AppColors.textLight,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: _busy ? null : _submit,
                            icon: _busy
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.person_add),
                            label: const Text('Create account'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: AppColors.primary,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Divider(),
                          ),
                          OutlinedButton.icon(
                            onPressed: _busy ? null : _google,
                            icon: const Icon(Icons.g_mobiledata, size: 28),
                            label: const Text('Continue with Google'),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed:
                                _busy ? null : () => Navigator.pop(context),
                            child: const Text('Already have an account? Sign in'),
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
      ),
    );
  }
}
