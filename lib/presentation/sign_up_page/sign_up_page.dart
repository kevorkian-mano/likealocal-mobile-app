import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _termsAccepted = false;
  bool _isLoading = false;
  String _passwordStrength = '';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String value) {
    if (value.isEmpty) {
      setState(() => _passwordStrength = '');
    } else if (value.length < 8) {
      setState(() => _passwordStrength = 'Too short');
    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
      setState(() => _passwordStrength = 'Weak (add a number)');
    } else {
      setState(() => _passwordStrength = 'Strong');
    }
  }

  void _handleCreateAccount() async {
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms & Conditions')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
        Navigator.pushReplacementNamed(context, AppRoutes.vibePickerScreen);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Failed: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleSocialSignUp(String provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider sign-up coming soon'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToSignIn() {
    Navigator.pushNamed(context, '/sign_in_page');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FCF5),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          color: const Color(0xFFF7FCF5),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 32,
                children: [
                  // Logo and Title Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: ShapeDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment(-0.00, -0.00),
                            end: Alignment(1.00, 1.00),
                            colors: [Color(0xFF1B3022), Color(0xFF41664C)],
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9999),
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
                        child: const Icon(Icons.location_on, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'LikeALocal',
                        style: TextStyle(
                          color: const Color(0xFF1B3022),
                          fontSize: 24,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w800,
                          height: 1.33,
                          letterSpacing: -0.60,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Title and Subtitle
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Text(
                        'Create Account',
                        style: TextStyle(
                          color: const Color(0xFF191D17),
                          fontSize: 30,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w700,
                          height: 1.20,
                        ),
                      ),
                      Text(
                        'Your journey beyond the guidebook begins here.',
                        style: TextStyle(
                          color: const Color(0xFF434940),
                          fontSize: 16,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400,
                          height: 1.50,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 20,
                      children: [
                        // Full Name Field
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Full Name',
                              style: TextStyle(
                                color: const Color(0xFF434940),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                height: 1.43,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameController,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter your full name';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Manuel Youssef',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFC3C8BC),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: const Icon(Icons.person, color: Color(0xFF434940)),
                                filled: true,
                                fillColor: const Color(0xFFF0F4EC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9999),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                        // Email Field
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            Text(
                              'Email Address',
                              style: TextStyle(
                                color: const Color(0xFF434940),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                height: 1.43,
                              ),
                            ),
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
                                  color: Color(0xFFC3C8BC),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: const Icon(Icons.email, color: Color(0xFF434940)),
                                filled: true,
                                fillColor: const Color(0xFFF0F4EC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9999),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                        // Password Field
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            Text(
                              'Password',
                              style: TextStyle(
                                color: const Color(0xFF434940),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                height: 1.43,
                              ),
                            ),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              onChanged: _onPasswordChanged,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter a password';
                                }
                                if (value!.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Enter your password',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFC3C8BC),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: const Icon(Icons.lock, color: Color(0xFF434940)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                    color: const Color(0xFF434940),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF0F4EC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9999),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                            if (_passwordStrength.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4, left: 16),
                                child: Text(
                                  'Strength: $_passwordStrength',
                                  style: TextStyle(
                                    color: _passwordStrength == 'Strong' ? Colors.green : Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        // Confirm Password Field
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 8,
                          children: [
                            Text(
                              'Confirm Password',
                              style: TextStyle(
                                color: const Color(0xFF434940),
                                fontSize: 14,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                                height: 1.43,
                              ),
                            ),
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please confirm your password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                hintText: 'Confirm your password',
                                hintStyle: const TextStyle(
                                  color: Color(0xFFC3C8BC),
                                  fontSize: 16,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w400,
                                ),
                                prefixIcon: const Icon(Icons.lock, color: Color(0xFF434940)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                    color: const Color(0xFF434940),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscureConfirmPassword = !_obscureConfirmPassword;
                                    });
                                  },
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF0F4EC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(9999),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                        // Terms Checkbox
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 12,
                          children: [
                            Checkbox(
                              value: _termsAccepted,
                              onChanged: (value) {
                                setState(() {
                                  _termsAccepted = value ?? false;
                                });
                              },
                              fillColor: WidgetStateProperty.all(
                                _termsAccepted ? const Color(0xFF1B3022) : const Color(0xFFF0F4EC),
                              ),
                              side: BorderSide(
                                width: 1,
                                color: _termsAccepted ? const Color(0xFF1B3022) : const Color(0x4CC3C8BC),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'I agree to the ',
                                          style: TextStyle(
                                            color: const Color(0xFF434940),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1.25,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Terms & Conditions',
                                          style: TextStyle(
                                            color: const Color(0xFF2D6A4F),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                            height: 1.25,
                                          ),
                                        ),
                                        TextSpan(
                                          text: ' and ',
                                          style: TextStyle(
                                            color: const Color(0xFF434940),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1.25,
                                          ),
                                        ),
                                        TextSpan(
                                          text: 'Privacy Policy',
                                          style: TextStyle(
                                            color: const Color(0xFF2D6A4F),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                            height: 1.25,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '.',
                                          style: TextStyle(
                                            color: const Color(0xFF434940),
                                            fontSize: 14,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w400,
                                            height: 1.25,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Create Account Button
                  GestureDetector(
                    onTap: _handleCreateAccount,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: ShapeDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment(0.21, -1.28),
                          end: Alignment(0.79, 2.28),
                          colors: [Color(0xFF1B3022), Color(0xFF41664C)],
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        shadows: [
                          BoxShadow(
                            color: const Color(0x261B3022),
                            blurRadius: 32,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: _isLoading 
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Create Account',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Plus Jakarta Sans',
                              fontWeight: FontWeight.w700,
                              height: 1.50,
                            ),
                          ),
                    ),
                  ),
                  // Divider
                  Center(
                    child: Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: const Color(0xFFDFE4D7),
                            height: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Or sign up with',
                            style: TextStyle(
                              color: const Color(0xFF434940),
                              fontSize: 14,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                              height: 1.43,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: const Color(0xFFDFE4D7),
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Social Buttons
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 12,
                    children: [
                      GestureDetector(
                        onTap: () => _handleSocialSignUp('Google'),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF0F4EC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.g_mobiledata, size: 20, color: Colors.red),
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
                      GestureDetector(
                        onTap: () => _handleSocialSignUp('Facebook'),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: ShapeDecoration(
                            color: const Color(0xFFF0F4EC),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9999),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.facebook, size: 20, color: Color(0xFF1877F2)),
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
                    ],
                  ),
                  // Sign In Link
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already part of the tribe? ',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF434940),
                            fontSize: 16,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 1.50,
                          ),
                        ),
                        GestureDetector(
                          onTap: _navigateToSignIn,
                          child: const Text(
                            'Sign In',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF2D6A4F),
                              fontSize: 16,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w700,
                              height: 1.50,
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
        ),
      ),
    );
  }
}
