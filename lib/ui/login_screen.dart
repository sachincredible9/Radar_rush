import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/service_locator.dart';
import '../core/services/auth_service.dart';
import 'dart:io' show Platform;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'level_selector.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _isRegistering = false;
  String _appVersion = '';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = 'v${packageInfo.version}+${packageInfo.buildNumber}';
      });
    }
  }

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isRegistering) {
        await getIt<AuthService>().registerWithEmail(email, password);
      } else {
        await getIt<AuthService>().signInWithEmail(email, password);
      }
      // No manual navigation needed. main.dart StreamBuilder will rebuild automatically.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authentication failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final user = await getIt<AuthService>().signInWithGoogle();
    if (mounted) setState(() => _isLoading = false);
    if (user != null) {
      // main.dart handles navigation automatically
    } else {
      _showError('Google Sign-In failed. Please ensure Google is enabled in Firebase.');
    }
  }

  Future<void> _handleAppleSignIn() async {
    setState(() => _isLoading = true);
    final user = await getIt<AuthService>().signInWithApple();
    if (mounted) setState(() => _isLoading = false);
    if (user != null) {
      // main.dart handles navigation
    } else {
      _showError('Apple Sign-In failed. Please try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Aesthetic
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [Colors.cyan.withOpacity(0.2), Colors.black],
                  ),
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Logo / Icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.cyan, width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.cyan.withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
                          ],
                        ),
                        child: const Icon(Icons.airplanemode_active, color: Colors.cyan, size: 60),
                      ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
                      
                      const SizedBox(height: 40),
                      
                      Text(
                        'RADAR RUSH',
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ).animate().shimmer(duration: 2.seconds),
                      
                      Text(
                        'AUTHORIZE ACCESS',
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 14,
                          letterSpacing: 2,
                        ),
                      ),
                      
                      const SizedBox(height: 60),
                      
                      if (_isLoading)
                        const CircularProgressIndicator(color: Colors.cyan)
                      else ...[
                        // Form Section for Email/Password
                        _buildEmailForm(),
                        
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            children: [
                              Expanded(child: Divider(color: Colors.white24)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Text('OR', style: TextStyle(color: Colors.white24, fontSize: 12)),
                              ),
                              Expanded(child: Divider(color: Colors.white24)),
                            ],
                          ),
                        ),

                        if (Platform.isIOS) ...[
                          // Apple first on iOS
                          SignInWithAppleButton(
                            onPressed: _handleAppleSignIn,
                            style: SignInWithAppleButtonStyle.black,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          const SizedBox(height: 16),
                          _buildGoogleButton(),
                        ] else ...[
                          // Google first on Android/Others
                          _buildGoogleButton(),
                          if (Platform.isIOS || Platform.isMacOS) ...[
                            const SizedBox(height: 16),
                            SignInWithAppleButton(
                              onPressed: _handleAppleSignIn,
                              style: SignInWithAppleButtonStyle.black,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ],
                        ],
                      ],
                      
                      const Spacer(),
                      const SizedBox(height: 40),
                      
                      Text(
                        'SECURE TERMINAL CONNECTION',
                        style: GoogleFonts.inter(color: Colors.white24, fontSize: 10),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: 10,
            right: 10,
            child: SafeArea(
              child: Text(
                _appVersion,
                style: GoogleFonts.inter(color: Colors.white12, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailForm() {
    return Column(
      children: [
        _buildTextField(
          controller: _emailController,
          label: 'EMAIL',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _passwordController,
          label: 'PASSWORD',
          icon: Icons.lock_outline,
          isPassword: true,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: _handleEmailAuth,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan.withOpacity(0.2),
              foregroundColor: Colors.cyanAccent,
              side: const BorderSide(color: Colors.cyanAccent, width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(_isRegistering ? 'INITIALIZE ACCOUNT' : 'AUTHORIZE LOGIN', style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _isRegistering = !_isRegistering),
          child: Text(
            _isRegistering ? 'ALREADY HAVE AN ACCOUNT? LOGIN' : 'NEW PILOT? REGISTER HERE',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.cyanAccent.withOpacity(0.7), size: 20),
          labelText: label,
          labelStyle: GoogleFonts.orbitron(color: Colors.white38, fontSize: 10, letterSpacing: 1),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleGoogleSignIn,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Official Multi-color Google Logo
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Image.network(
                    'https://image.pngaaa.com/832/2832832-middle.png', // Higher quality multi-color G
                    height: 18,
                    width: 18,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, color: Colors.blue, size: 24),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Sign in with Google',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
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
