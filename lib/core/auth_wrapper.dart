import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/user_provider.dart';
import '../core/providers/connectivity_provider.dart';
import '../presentation/onboarding_screen/onboarding_screen.dart';
import '../presentation/explore_page_with_notif_screen/explore_page_with_notif_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../presentation/email_verification_screen/email_verification_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserProvider, ConnectivityProvider>(
      builder: (context, userProvider, connectivityProvider, child) {
        if (!connectivityProvider.isOnline) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    size: 80,
                    color: Color(0xFF1B3022),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Connection Lost',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B3022),
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Please check your internet connection to continue exploring LikeALocal.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4D6353),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      // Trigger a refresh if possible
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B3022),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (userProvider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF1B3022)),
            ),
          );
        }

        if (userProvider.isAuthenticated) {
          final firebaseUser = FirebaseAuth.instance.currentUser;
          if (firebaseUser != null && !firebaseUser.emailVerified) {
            return const EmailVerificationScreen();
          }
          return const ExplorePageWithNotifScreen();
        } else {
          return OnboardingScreen.builder(context);
        }
      },
    );
  }
}
