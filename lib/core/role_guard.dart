import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/user_provider.dart';
import '../routes/app_routes.dart';
import '../theme/text_style_helper.dart';

class RoleGuard extends StatelessWidget {
  final Widget child;
  final bool requireAuth;
  final bool requireAdmin;
  final bool requireSuperUser;
  final bool requirePro;

  const RoleGuard({
    super.key,
    required this.child,
    this.requireAuth = true,
    this.requireAdmin = false,
    this.requireSuperUser = false,
    this.requirePro = false,
  });

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
          // FR11-6: Real-time Ban Check
          if (user.isBanned) {
            return _buildAccessDenied(
              context,
              'Your account has been suspended. Please contact support.',
              isBan: true,
            );
          }

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

  Widget _buildAccessDenied(
    BuildContext context,
    String message, {
    bool isBan = false,
  }) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F7F2),
      appBar: AppBar(
        title: Text(isBan ? 'Account Suspended' : 'Access Denied'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B3022)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isBan ? Icons.gavel_rounded : Icons.block,
                size: 80,
                color: const Color(0xFF8B0000),
              ),
              const SizedBox(height: 24),
              Text(
                isBan ? 'Access Revoked' : 'Access Denied',
                style: TextStyleHelper.instance.title20BoldOutfit.copyWith(
                  color: const Color(0xFF1B3022),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyleHelper.instance.body14MediumInter.copyWith(
                  color: const Color(0xFF4D6353),
                ),
              ),
              const SizedBox(height: 32),
              if (isBan)
                ElevatedButton(
                  onPressed: () => Provider.of<UserProvider>(
                    context,
                    listen: false,
                  ).signOut(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3022),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              else
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3022),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
