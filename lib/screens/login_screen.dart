import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../app.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_button.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();
  bool signUp = false;
  bool obscurePassword = true;
  bool acceptedTerms = false;
  bool submitting = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    if (signUp && !acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms of Service.')),
      );
      return;
    }
    setState(() => submitting = true);
    try {
      if (signUp) {
        await authService.signUp(
          email: emailController.text,
          password: passwordController.text,
          fullName: nameController.text,
        );
      } else {
        await authService.signIn(
          email: emailController.text,
          password: passwordController.text,
        );
      }
      if (!mounted) return;
      // Explicit navigation rather than waiting on Firebase's
      // authStateChanges() stream, which was found to be unreliable in
      // Flutter Web dev sessions (see app.dart for details). Kick off the
      // data load first so HomeScreen's loading spinner shows immediately
      // rather than a blank Explore tab.
      BookingScope.of(context).initialize();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AuthService.messageFor(error))),
      );
    } catch (error) {
      // Catches anything that isn't a FirebaseAuthException (e.g. a
      // Firestore error while writing the users/{uid} role doc during
      // sign-up) so a failure is visible instead of silently doing
      // nothing.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong: $error')),
      );
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  Future<void> forgotPassword() async {
    final emailFieldController =
        TextEditingController(text: emailController.text.trim());
    final dialogFormKey = GlobalKey<FormState>();
    bool sending = false;

    final sent = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Reset Password'),
          content: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Enter your account email and we'll send you a link to "
                  'reset your password.',
                  style: TextStyle(color: AppColors.muted),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailFieldController,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (value) =>
                      value != null && value.contains('@')
                          ? null
                          : 'Enter a valid email address',
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: sending
                  ? null
                  : () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: sending
                  ? null
                  : () async {
                      if (!dialogFormKey.currentState!.validate()) return;
                      setDialogState(() => sending = true);
                      try {
                        await authService.sendPasswordResetEmail(
                          emailFieldController.text.trim(),
                        );
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext, true);
                        }
                      } on FirebaseAuthException catch (error) {
                        setDialogState(() => sending = false);
                        if (!dialogContext.mounted) return;
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                          SnackBar(
                              content:
                                  Text(AuthService.messageFor(error))),
                        );
                      }
                    },
              child: Text(sending ? 'Sending...' : 'Send Reset Link'),
            ),
          ],
        ),
      ),
    );
    emailFieldController.dispose();
    if (sent == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(32, 34, 32, 30),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  signUp ? 'Create Account' : 'Welcome Back!',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 14),
                Text(
                  signUp
                      ? 'Sign up to reserve your next table.'
                      : 'Please log in to continue.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.muted,
                      ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: submitting
                            ? null
                            : () => setState(() => signUp = false),
                        child: Text('Log In',
                            style: TextStyle(
                                color: signUp ? AppColors.muted : AppColors.red,
                                fontWeight: FontWeight.w800)),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: submitting
                            ? null
                            : () => setState(() => signUp = true),
                        child: Text('Sign Up',
                            style: TextStyle(
                                color: signUp ? AppColors.red : AppColors.muted,
                                fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
                if (signUp) ...[
                  const SizedBox(height: 18),
                  _label('Full Name'),
                  TextFormField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(hintText: 'Enter your full name'),
                    validator: (value) => (value?.trim().isNotEmpty ?? false)
                        ? null
                        : 'Enter your full name',
                  ),
                  const SizedBox(height: 18),
                  _label('Phone Number'),
                  TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        hintText: 'Enter your phone number'),
                    validator: (value) => (value?.trim().length ?? 0) >= 8
                        ? null
                        : 'Enter a valid phone number',
                  ),
                  const SizedBox(height: 18),
                ],
                _label(signUp ? 'Email Address' : 'Email'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'Enter your email',
                    prefixIcon: Icon(Icons.mail_outline_rounded),
                  ),
                  validator: (value) => value != null && value.contains('@')
                      ? null
                      : 'Enter a valid email address',
                ),
                const SizedBox(height: 18),
                _label('Password'),
                const SizedBox(height: 10),
                TextFormField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () => obscurePassword = !obscurePassword,
                      ),
                      icon: Icon(obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined),
                    ),
                  ),
                  validator: (value) => (value?.length ?? 0) >= 6
                      ? null
                      : 'Password must contain at least 6 characters',
                ),
                if (!signUp)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: submitting ? null : forgotPassword,
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColors.redDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else ...[
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: acceptedTerms,
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    onChanged: (value) =>
                        setState(() => acceptedTerms = value ?? false),
                    title: const Text(
                      'I agree to the Terms of Service and Privacy Policy.',
                      style: TextStyle(color: AppColors.muted, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                AppButton(
                  label: submitting
                      ? (signUp ? 'Creating Account...' : 'Logging In...')
                      : (signUp ? 'Create Account' : 'Log In'),
                  onPressed: submitting ? null : submit,
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: submitting
                        ? null
                        : () => setState(() => signUp = !signUp),
                    child: Text(
                      signUp
                          ? 'Already have an account? Log in'
                          : 'New here? Create an account',
                      style: const TextStyle(
                        color: AppColors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                if (!signUp) ...[
                  const SizedBox(height: 22),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or continue with'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _socialButton('G'),
                      _socialButton('X'),
                      _socialButton('f'),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      );

  Widget _socialButton(String text) => OutlinedButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Social sign-in coming soon.')),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(74, 58),
          side: const BorderSide(color: AppColors.border),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
}