import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/user_repository.dart';
import 'login_page.dart';

/// Replaces the auth screens with the home screen after login or register.
void goToHome(BuildContext context, User user) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => HomePage(user: user)),
    (_) => false,
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.user});

  final User user;

  void _logout(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'Welcome, ${user.name}',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Text(
                  'Your home screen is coming soon.',
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.muted),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => _logout(context),
                child: const Text('Log out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
