import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/providers/user_provider.dart';
import '../../routes/app_routes.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  void _handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
        // FR1-2: Check email verification status
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null && !firebaseUser.emailVerified) {
          await userProvider.signOut();
          if (!mounted) return;
          setState(() => _isLoading = false);
          _showVerificationBanner();
          return;
        }
        if (!mounted) return;
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.explorePageWithNotifScreen,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign In Failed: ${e.toString()}')),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // FR1-2: Show unverified email banner with resend option
  void _showVerificationBanner() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.mark_email_unread_outlined, color: Color(0xFF1B3022)),
            SizedBox(width: 10),
            Text(
              'Verify Your Email',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Your email is not verified. Please check your inbox or tap below to resend the verification link.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1B3022)),
            onPressed: () async {
              Navigator.pop(ctx);
              await _handleResendVerification();
            },
            child: Text('Resend Email', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleResendVerification() async {
    try {
      // Sign in temporarily to get the user object for resend
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim().toLowerCase(),
        password: _passwordController.text.trim(),
      );
      await credential.user?.sendEmailVerification();
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Verification email sent! Please check your inbox.'),
          backgroundColor: Color(0xFF1B3022),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not resend email: ${e.toString()}')),
      );
    }
  }

  void _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email to reset password'),
        ),
      );
      return;
    }

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.resetPassword(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset link sent to your email')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    }
  }

  void _handleSocialSignIn(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider sign-in coming soon'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToSignUp() {
    Navigator.pushNamed(context, AppRoutes.signUpPage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF5),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(color: Color(0xFFF7FAF5)),
            child: Stack(
              children: [
                // Background circles
                Positioned(
                  left: -96,
                  top: -96,
                  child: Container(
                    width: 384,
                    height: 384,
                    decoration: ShapeDecoration(
                      color: const Color(0x4CD6E8D8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 102,
                  top: 596,
                  child: Container(
                    width: 384,
                    height: 384,
                    decoration: ShapeDecoration(
                      color: const Color(0x4CBDE9D0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9999),
                      ),
                    ),
                  ),
                ),
                // Main content
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 40,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 448),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Header
                          Text(
                            'LikeALocal',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF191C19),
                              fontSize: 36,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w800,
                              height: 1.11,
                              letterSpacing: -0.90,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Your curated journey begins here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: const Color(0xFF434943),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                            ),
                          ),
                          const SizedBox(height: 31),
                          // Form Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: const Color(0x141B3022),
                                  blurRadius: 32,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Title Section
                                  Text(
                                    'Welcome Back',
                                    style: TextStyle(
                                      color: const Color(0xFF191C19),
                                      fontSize: 24,
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontWeight: FontWeight.w700,
                                      height: 1.33,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Please enter your details to sign in.',
                                    style: TextStyle(
                                      color: const Color(0xFF434943),
                                      fontSize: 14,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: 1.43,
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // Email Field
                                  Text(
                                    'EMAIL ADDRESS',
                                    style: TextStyle(
                                      color: const Color(0xFF434943),
                                      fontSize: 12,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                      height: 1.33,
                                      letterSpacing: 0.60,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  TextFormField(
                                    controller: _emailController,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'Please enter your email';
                                      }
                                      if (!value!.contains('@')) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'mano@yahoo.com',
                                      hintStyle: const TextStyle(
                                        color: Color(0xFFC1C8C0),
                                        fontSize: 16,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.email,
                                        color: Color(0xFF434943),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF1F4EF),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          9999,
                                        ),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Password Label Row
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'PASSWORD',
                                        style: TextStyle(
                                          color: const Color(0xFF434943),
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                          fontWeight: FontWeight.w600,
                                          height: 1.33,
                                          letterSpacing: 0.60,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: _handleForgotPassword,
                                        child: Text(
                                          'Forgot Password?',
                                          style: const TextStyle(
                                            color: Color(0xFF1B3022),
                                            fontSize: 12,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w700,
                                            height: 1.33,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Password Field
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    validator: (value) {
                                      if (value?.isEmpty ?? true) {
                                        return 'Please enter your password';
                                      }
                                      if (value!.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                    decoration: InputDecoration(
                                      hintText: '••••••••',
                                      hintStyle: const TextStyle(
                                        color: Color(0xFFC1C8C0),
                                        fontSize: 16,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.lock,
                                        color: Color(0xFF434943),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                          color: const Color(0xFF434943),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF1F4EF),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          9999,
                                        ),
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // Sign In Button
                                  GestureDetector(
                                    onTap: _handleSignIn,
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 16,
                                      ),
                                      decoration: ShapeDecoration(
                                        gradient: const LinearGradient(
                                          begin: Alignment(0.46, -0.46),
                                          end: Alignment(0.54, 1.46),
                                          colors: [
                                            Color(0xFF1B3022),
                                            Color(0xFF2D4B39),
                                          ],
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            9999,
                                          ),
                                        ),
                                        shadows: [
                                          BoxShadow(
                                            color: const Color(0x19000000),
                                            blurRadius: 6,
                                            offset: const Offset(0, 4),
                                            spreadRadius: -4,
                                          ),
                                        ],
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Text(
                                              'Sign In',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontFamily: 'Plus Jakarta Sans',
                                                fontWeight: FontWeight.w700,
                                                height: 1.56,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // Divider with text
                                  Center(
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Divider(
                                            color: const Color(0xFFE1E4DF),
                                            height: 1,
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          child: Text(
                                            'OR CONTINUE WITH',
                                            style: TextStyle(
                                              color: const Color(0xFFC1C8C0),
                                              fontSize: 12,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                              height: 1.33,
                                              letterSpacing: 1.20,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Divider(
                                            color: const Color(0xFFE1E4DF),
                                            height: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // Google Button
                                  GestureDetector(
                                    onTap: () => _handleSocialSignIn('Google'),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFF0F4EC),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            9999,
                                          ),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.g_mobiledata,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Google',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Color(0xFF191D17),
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w700,
                                              height: 1.43,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Facebook Button
                                  GestureDetector(
                                    onTap: () =>
                                        _handleSocialSignIn('Facebook'),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: ShapeDecoration(
                                        color: const Color(0xFFF0F4EC),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            9999,
                                          ),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.facebook,
                                            size: 20,
                                            color: Color(0xFF1877F2),
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            'Facebook',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Color(0xFF191D17),
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w700,
                                              height: 1.43,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // Sign Up Link
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'New to LikeALocal? ',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Color(0xFF434943),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1.43,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _navigateToSignUp,
                                          child: const Text(
                                            'Create an account',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Color(0xFF3B634E),
                                              fontSize: 14,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w700,
                                              decoration:
                                                  TextDecoration.underline,
                                              height: 1.43,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
