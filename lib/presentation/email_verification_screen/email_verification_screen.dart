import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/providers/user_provider.dart';
import '../../routes/app_routes.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> with SingleTickerProviderStateMixin {
  Timer? _timer;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;
  bool _isChecking = false;
  bool _isResending = false;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Smooth entry animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    // Auto-polling verification status every 4 seconds in the background
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      _checkEmailVerified(autoPoll: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  // Reloads Firebase User and checks if verified
  Future<void> _checkEmailVerified({bool autoPoll = false}) async {
    if (_isChecking && !autoPoll) return;
    if (mounted && !autoPoll) {
      setState(() => _isChecking = true);
    }

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.reloadUser();
      
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null && firebaseUser.emailVerified) {
        _timer?.cancel();
        _cooldownTimer?.cancel();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified successfully! Welcome to the community.'),
              backgroundColor: Color(0xFF1B3022),
            ),
          );
          
          // Proceed to VibePicker if user preferences are empty, otherwise to Explore initialRoute
          if (userProvider.user?.selectedVibes.isEmpty ?? true) {
            Navigator.pushReplacementNamed(context, AppRoutes.vibePickerScreen);
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.initialRoute);
          }
        }
        return;
      }

      if (!autoPoll && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email is not verified yet. Please check your inbox and tap the link.'),
            backgroundColor: Color(0xFF8B2635),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error checking email verification status: $e');
    } finally {
      if (mounted && !autoPoll) {
        setState(() => _isChecking = false);
      }
    }
  }

  // Sends email verification and starts a 60-second cooldown timer
  Future<void> _resendVerificationEmail() async {
    if (_cooldownSeconds > 0 || _isResending) return;
    setState(() => _isResending = true);

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        await firebaseUser.sendEmailVerification();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('A fresh verification link has been sent to your inbox!'),
              backgroundColor: Color(0xFF1B3022),
            ),
          );
        }
        _startCooldownTimer();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend: ${e.toString()}'),
            backgroundColor: const Color(0xFF8B2635),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _startCooldownTimer() {
    setState(() => _cooldownSeconds = 60);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds == 0) {
        timer.cancel();
      } else {
        if (mounted) {
          setState(() {
            _cooldownSeconds--;
          });
        }
      }
    });
  }

  // Handle logout / change email
  Future<void> _handleLogOut() async {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.initialRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    final emailAddress = firebaseUser?.email ?? 'your registered email';

    return PopScope(
      canPop: false, // Strictly stuck - physical/system back button is disabled
      onPopInvoked: (didPop) {
        if (didPop) return;
        // User cannot leave this screen until verified or logged out
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7FCF5),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              // Beautiful aesthetic background circles
              Positioned(
                left: -80,
                top: -80,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: const ShapeDecoration(
                    color: Color(0x33E8F2E9),
                    shape: CircleBorder(),
                  ),
                ),
              ),
              Positioned(
                right: -100,
                bottom: -100,
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: const ShapeDecoration(
                    color: Color(0x33DCECE0),
                    shape: CircleBorder(),
                  ),
                ),
              ),
              SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Elegant brand logo / title
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: ShapeDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF1B3022), Color(0xFF41664C)],
                                  ),
                                  shape: const CircleBorder(),
                                ),
                                child: const Icon(Icons.location_on, color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'LikeALocal',
                                style: TextStyle(
                                  color: Color(0xFF1B3022),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  fontFamily: 'Plus Jakarta Sans',
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          // Beautiful curved blocker card
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: const Color(0xFFE8F2E9), width: 1.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0C1B3022),
                                  blurRadius: 24,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Verification icon with a pulsing design
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: const ShapeDecoration(
                                        color: Color(0xFFE8F2E9),
                                        shape: CircleBorder(),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.mark_email_read_rounded,
                                      color: Color(0xFF1B3022),
                                      size: 38,
                                    ),
                                    SizedBox(
                                      width: 80,
                                      height: 80,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          const Color(0xFF1B3022).withOpacity(0.3),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'Verify Your Email',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 24,
                                    color: Color(0xFF1B3022),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14,
                                      color: Color(0xFF4D6353),
                                      height: 1.6,
                                    ),
                                    children: [
                                      const TextSpan(text: 'We have sent a verification link to:\n'),
                                      TextSpan(
                                        text: '$emailAddress\n\n',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1B3022),
                                        ),
                                      ),
                                      const TextSpan(
                                        text: 'To unlock your account and begin personalizing your travel DNA, please tap the link inside that email.',
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),
                                // Real-time active status notice
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D6A4F)),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Listening for verification...',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF2D6A4F).withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // Check status button
                                GestureDetector(
                                  onTap: () => _checkEmailVerified(autoPoll: false),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    decoration: ShapeDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF1B3022), Color(0xFF41664C)],
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(9999),
                                      ),
                                    ),
                                    child: _isChecking
                                        ? const Center(
                                            child: SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2.5,
                                              ),
                                            ),
                                          )
                                        : const Text(
                                            'I\'ve Verified My Email',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Resend option
                                GestureDetector(
                                  onTap: _cooldownSeconds == 0 && !_isResending ? _resendVerificationEmail : null,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7FCF5),
                                      borderRadius: BorderRadius.circular(9999),
                                      border: Border.all(color: const Color(0xFFDFE4D7)),
                                    ),
                                    child: _isResending
                                        ? const Center(
                                            child: SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                color: Color(0xFF1B3022),
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            _cooldownSeconds > 0
                                                ? 'Resend Link in ${_cooldownSeconds}s'
                                                : 'Resend Verification Email',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: _cooldownSeconds > 0
                                                  ? const Color(0xFF8C9F90)
                                                  : const Color(0xFF1B3022),
                                              fontSize: 14,
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Premium logout / wrong email option
                          TextButton.icon(
                            onPressed: _handleLogOut,
                            icon: const Icon(Icons.logout_rounded, size: 16, color: Color(0xFF8B2635)),
                            label: const Text(
                              'Log Out / Change Email',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF8B2635),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
