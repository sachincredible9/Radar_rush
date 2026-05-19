import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/service_locator.dart';
import '../core/services/auth_service.dart';
import '../core/services/persistence_service.dart';
import 'dart:io' show Platform;
import 'dart:ui' show ImageFilter;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'level_selector.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onPlayAsGuest;
  const LoginScreen({super.key, this.onPlayAsGuest});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  bool _isRegistering = false;
  String _appVersion = '';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final persistence = getIt<PersistenceService>();
    final remember = persistence.getRememberMe();
    if (remember) {
      _emailController.text = persistence.getSavedEmail();
      _passwordController.text = persistence.getSavedPassword();
      if (mounted) {
        setState(() {
          _rememberMe = true;
        });
      }
    }
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
      await getIt<PersistenceService>().saveCredentials(email, password, _rememberMe);
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
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    // Sleek responsive sizes
    final double paddingHorizontal = isTablet ? 80.0 : 32.0;
    final double logoSize = isTablet ? 130.0 : 96.0;
    final double logoIconSize = isTablet ? 64.0 : 44.0;
    final double titleFontSize = isTablet ? 36.0 : 26.0;
    final double subtitleFontSize = isTablet ? 14.0 : 11.0;

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

          // Colored background light blobs for liquid glassmorphism depth
          Positioned(
            top: -80,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.cyan.withOpacity(0.12),
              ),
            ),
          ).animate().fadeIn(duration: 1.seconds),
          Positioned(
            bottom: 40,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.withOpacity(0.12),
              ),
            ),
          ).animate().fadeIn(duration: 1.seconds),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Logo / Icon
                      Container(
                        width: logoSize,
                        height: logoSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.cyan, width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.cyan.withOpacity(0.3), blurRadius: 20, spreadRadius: 5),
                          ],
                        ),
                        child: Icon(Icons.airplanemode_active, color: Colors.cyan, size: logoIconSize),
                      ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
                      
                      const SizedBox(height: 20),
                      
                      Text(
                        'RADAR RUSH',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ).animate().shimmer(duration: 2.seconds),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        'AUTHORIZE ACCESS',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: subtitleFontSize,
                          letterSpacing: 2,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Liquid Glass Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    // Premium dark glass with gradient
                                    // When blur is not supported, this acts as a elegant flat fallback
                                    Colors.grey[950]!.withOpacity(0.7),
                                    Colors.black.withOpacity(0.85),
                                  ],
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.onPlayAsGuest != null) ...[
                                    SizedBox(
                                      width: double.infinity,
                                      height: 44,
                                      child: ElevatedButton(
                                        onPressed: widget.onPlayAsGuest,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.cyan,
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          'PLAY AS GUEST',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.orbitron(
                                            fontSize: isTablet ? 14 : 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Row(
                                        children: [
                                          Expanded(child: Divider(color: Colors.white12)),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            child: Text('OR LOGIN TO SAVE PROGRESS', style: TextStyle(color: Colors.white30, fontSize: 10)),
                                          ),
                                          Expanded(child: Divider(color: Colors.white12)),
                                        ],
                                      ),
                                    ),
                                  ],

                                  if (_isLoading)
                                    const CircularProgressIndicator(color: Colors.cyan)
                                  else ...[
                                    _buildEmailForm(),
                                    
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Row(
                                        children: [
                                          Expanded(child: Divider(color: Colors.white12)),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            child: Text('OR', style: TextStyle(color: Colors.white30, fontSize: 10)),
                                          ),
                                          Expanded(child: Divider(color: Colors.white12)),
                                        ],
                                      ),
                                    ),

                                    if (Platform.isIOS) ...[
                                      SignInWithAppleButton(
                                        onPressed: _handleAppleSignIn,
                                        style: SignInWithAppleButtonStyle.whiteOutlined,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      const SizedBox(height: 12),
                                      _buildGoogleButton(),
                                    ] else ...[
                                      _buildGoogleButton(),
                                      if (Platform.isIOS || Platform.isMacOS) ...[
                                        const SizedBox(height: 12),
                                        SignInWithAppleButton(
                                          onPressed: _handleAppleSignIn,
                                          style: SignInWithAppleButtonStyle.whiteOutlined,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ],
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      Text(
                        'SECURE TERMINAL CONNECTION',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(color: Colors.white24, fontSize: 9),
                      ),
                      const SizedBox(height: 16),
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
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _rememberMe,
                activeColor: Colors.cyanAccent,
                checkColor: Colors.black,
                side: const BorderSide(color: Colors.white30, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                setState(() {
                  _rememberMe = !_rememberMe;
                });
              },
              child: Text(
                'REMEMBER ME',
                style: GoogleFonts.orbitron(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
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
            child: Text(_isRegistering ? 'INITIALIZE ACCOUNT' : 'LOGIN', style: GoogleFonts.orbitron(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _isRegistering = !_isRegistering),
          child: Text(
            _isRegistering ? 'ALREADY HAVE AN ACCOUNT? LOGIN' : 'NEW PILOT? REGISTER HERE',
            textAlign: TextAlign.center,
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
