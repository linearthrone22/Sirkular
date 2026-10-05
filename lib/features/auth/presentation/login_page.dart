import 'package:flutter/material.dart';

import '../data/user_repository.dart';
import '../../dashboard/presentation/home_page.dart';
import 'register_page.dart';
import 'widgets/auth_validators.dart';
import 'widgets/auth_widgets.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userRepository = UserRepository();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    try {
      final user = await _userRepository.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      goToHome(context, user);
    } on AuthException catch (e) {
      if (!mounted) return;
      showAuthMessage(context, e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      children: [
        const AuthBrandHeader(),
        const SizedBox(height: 24),
        AuthCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTabs(
                isLogin: true,
                onLoginTap: () {},
                onSignupTap: _openRegister,
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: validateEmail,
                      decoration: const InputDecoration(
                        labelText: 'Email address',
                        prefixIcon: Icon(Icons.mail_outline_rounded),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AuthPasswordField(
                      controller: _passwordController,
                      label: 'Password',
                      validator: validatePasswordLogin,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        // TODO: forgot password flow
                        onPressed: () {},
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      child: _isSubmitting
                          ? const AuthSpinner()
                          : const Text('Login'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
