import 'package:flutter/material.dart';

import '../../auth/data/user_repository.dart';
import '../../auth/presentation/login_page.dart';
import 'mobile_dashboard.dart';
import 'web_dashboard.dart';

/// Replaces the auth screens with the home screen after login or register.
void goToHome(BuildContext context, User user) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => HomePage(user: user)),
    (_) => false,
  );
}

/// Returns to the login screen and clears the navigation stack.
void logout(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (_) => false,
  );
}

/// Picks the web layout (sidebar and grid) or the mobile layout by width.
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.user});

  final User user;

  static const _webBreakpoint = 1100.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _webBreakpoint) {
          return WebDashboard(user: user);
        }
        return MobileDashboard(user: user);
      },
    );
  }
}
