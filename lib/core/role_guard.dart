import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/user_provider.dart';
import '../routes/app_routes.dart';

class RoleGuard extends StatelessWidget {
  final Widget child;
  final bool requireAuth;
  final bool requireAdmin;
  final bool requireSuperUser;
  final bool requirePro;

  const RoleGuard({
    Key? key,
    required this.child,
    this.requireAuth = true,
    this.requireAdmin = false,
    this.requireSuperUser = false,
    this.requirePro = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF1B3022)),
            ),
          );
        }

        final isAuthenticated = userProvider.isAuthenticated;
        final user = userProvider.user;

        // Check authentication
        if (requireAuth && !isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.signInPage);
          });
          return const SizedBox.shrink();
        }

        if (isAuthenticated && user != null) {
          // Check Admin
          if (requireAdmin && !user.isAdmin) {
            return _buildAccessDenied(context, 'Admin access required.');
          }

          // Check Super User
          if (requireSuperUser && !user.isSuperUser) {
            return _buildAccessDenied(context, 'Super User access required.');
          }

          // Check Pro
          if (requirePro && !user.isPro) {
            return _buildAccessDenied(context, 'Pro subscription required.');
          }
        }

        return child;
      },
    );
  }

  Widget _buildAccessDenied(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Access Denied')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.block, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Access Denied',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
