import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../data/services/supabase_service.dart';
import '../widgets/brand_mark.dart';

/// Email authentication matching the compact welcome/login states in the design.
/// It is only shown for Supabase-enabled builds without an active session.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isSignUp = false;
  bool _isBusy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isBusy = true);
    try {
      if (_isSignUp) {
        await SupabaseService.client.auth.signUp(
          email: _email.text.trim(),
          password: _password.text,
        );
        if (!mounted) return;
        _showMessage('Check your inbox to confirm your account.');
      } else {
        await SupabaseService.client.auth.signInWithPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
        if (!mounted) return;
        context.go('/');
      }
    } on AuthException catch (error) {
      _showMessage(error.message, isError: true);
    } catch (_) {
      _showMessage('Something went wrong. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _continueWithGoogle() async {
    setState(() => _isBusy = true);
    try {
      await SupabaseService.client.auth.signInWithOAuth(OAuthProvider.google);
    } on AuthException catch (error) {
      _showMessage(error.message, isError: true);
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? AppColors.accentError
            : AppColors.accentSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 28),
                  const Center(child: BrandMark(size: 62)),
                  const SizedBox(height: 18),
                  Text(
                    _isSignUp ? 'JOIN BRAINBOX' : 'WELCOME\nTO BRAINBOX',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _isSignUp
                        ? 'Build a learning habit that sticks.'
                        : 'Learn, practice, and grow every day.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 34),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                    ),
                    validator: (value) => value != null && value.contains('@')
                        ? null
                        : 'Enter a valid email address.',
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (value) => value != null && value.length >= 6
                        ? null
                        : 'Use at least 6 characters.',
                  ),
                  const SizedBox(height: 18),
                  FilledButton(
                    onPressed: _isBusy ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Text(
                        _isBusy
                            ? 'PLEASE WAIT…'
                            : _isSignUp
                            ? 'CREATE ACCOUNT'
                            : 'LOG IN',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OR',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _isBusy ? null : _continueWithGoogle,
                    icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                    label: const Text('CONTINUE WITH GOOGLE'),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: _isBusy
                        ? null
                        : () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Log in'
                          : 'New here? Create an account',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
