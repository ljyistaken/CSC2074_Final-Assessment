import 'package:flutter/material.dart';

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
  bool signUp = false;
  bool obscurePassword = true;
  bool acceptedTerms = false;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void submit() {
    if (!formKey.currentState!.validate()) return;
    if (signUp && !acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms of Service.')),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
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
                        onPressed: () => setState(() => signUp = false),
                        child: Text('Log In',
                            style: TextStyle(
                                color: signUp ? AppColors.muted : AppColors.red,
                                fontWeight: FontWeight.w800)),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => setState(() => signUp = true),
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
                      onPressed: () =>
                          ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Password recovery coming soon.')),
                      ),
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
                    label: signUp ? 'Create Account' : 'Log In',
                    onPressed: submit),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() => signUp = !signUp),
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
        onPressed: () {},
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
