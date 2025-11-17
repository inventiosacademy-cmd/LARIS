import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app_colors.dart';
import 'home_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _googleSignIn = GoogleSignIn();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  bool _isGoogleSubmitting = false;
  String? _authError;

  Color get _primaryColor => AppColors.primary;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _isSubmitting) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isSubmitting = true;
      _authError = null;
    });

    String? authErrorMessage;

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrasi berhasil. Selamat datang!')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      authErrorMessage = switch (error.code) {
        'weak-password' => 'Kata sandi terlalu lemah.',
        'email-already-in-use' => 'Email sudah digunakan.',
        'invalid-email' => 'Format email tidak valid.',
        _ => 'Gagal daftar (${error.code}).',
      };
    } catch (_) {
      authErrorMessage = 'Terjadi kesalahan tak terduga. Silakan coba lagi.';
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _authError = authErrorMessage;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isGoogleSubmitting) return;

    setState(() {
      _isGoogleSubmitting = true;
      _authError = null;
    });

    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        if (mounted) {
          setState(() {
            _isGoogleSubmitting = false;
          });
        }
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil masuk dengan Google.')),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _authError = 'Google sign-in gagal (${error.message ?? error.code}).';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _authError = 'Tidak dapat masuk dengan Google. Coba lagi.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _AuthIllustration(
                    title: 'Daftar',
                    subtitle: 'Buat akun baru untuk mulai menggunakan LARIS.',
                    assetPath: 'assets/asset_login.png',
                  ),
                  SizedBox(height: isKeyboardVisible ? 12 : 24),
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                              color: _primaryColor,
                            ),
                            filled: true,
                            fillColor: AppColors.primary05,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email wajib diisi';
                            }
                            final emailPattern = RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            );
                            if (!emailPattern.hasMatch(value.trim())) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Kata sandi',
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: _primaryColor,
                            ),
                            suffixIcon: IconButton(
                              onPressed: _togglePasswordVisibility,
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.primary05,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Kata sandi wajib diisi';
                            }
                            if (value.length < 6) {
                              return 'Minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Konfirmasi kata sandi',
                            prefixIcon: Icon(
                              Icons.lock_reset_outlined,
                              color: _primaryColor,
                            ),
                            suffixIcon: IconButton(
                              onPressed: _toggleConfirmPasswordVisibility,
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                              ),
                            ),
                            filled: true,
                            fillColor: AppColors.primary05,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Konfirmasi kata sandi wajib diisi';
                            }
                            if (value != _passwordController.text) {
                              return 'Kata sandi tidak cocok';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_authError != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              _authError!,
                              style: textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(
                                    'Daftar',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _SocialDivider(),
                        const SizedBox(height: 12),
                        _SocialButtons(
                          onGoogleTap: _isSubmitting || _isGoogleSubmitting
                              ? null
                              : _signInWithGoogle,
                          onFacebookTap: null,
                          isGoogleLoading: _isGoogleSubmitting,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Sudah punya akun?'),
                            TextButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : () {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (_) => const LoginPage(),
                                        ),
                                      );
                                    },
                              child: const Text(
                                'Masuk',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
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

class _AuthIllustration extends StatelessWidget {
  const _AuthIllustration({
    required this.title,
    required this.subtitle,
    required this.assetPath,
  });

  final String title;
  final String subtitle;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final imageHeight = isKeyboardVisible ? 160.0 : 300.0;
    final imageOffset = isKeyboardVisible ? -4.0 : -12.0;
    final spacing = isKeyboardVisible ? 8.0 : 12.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.translate(
          offset: Offset(0, imageOffset),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            height: imageHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Image.asset(
                assetPath,
                width: double.infinity,
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
        SizedBox(height: spacing),
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }
}

class _SocialDivider extends StatelessWidget {
  const _SocialDivider();

  @override
  Widget build(BuildContext context) {
    final color = Colors.black.withOpacity(0.15);
    return Row(
      children: [
        Expanded(child: Divider(color: color, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'atau daftar dengan',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: Divider(color: color, thickness: 1)),
      ],
    );
  }
}

class _SocialButtons extends StatelessWidget {
  const _SocialButtons({
    required this.onGoogleTap,
    required this.onFacebookTap,
    this.isGoogleLoading = false,
    this.isFacebookLoading = false,
  });

  final VoidCallback? onGoogleTap;
  final VoidCallback? onFacebookTap;
  final bool isGoogleLoading;
  final bool isFacebookLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            icon: FontAwesomeIcons.google,
            label: 'Google',
            color: AppColors.primary,
            onPressed: onGoogleTap,
            isLoading: isGoogleLoading,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SocialButton(
            icon: FontAwesomeIcons.facebookF,
            label: 'Facebook',
            color: AppColors.primary,
            onPressed: onFacebookTap,
            isLoading: isFacebookLoading,
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
    this.isLoading = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    return OutlinedButton(
      onPressed: effectiveOnPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: color.withOpacity(0.5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      child: isLoading
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600),
                ),
              ],
            ),
    );
  }
}
