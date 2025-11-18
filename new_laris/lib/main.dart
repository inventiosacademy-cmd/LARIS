import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'firebase_options.dart';
import 'home_page.dart';
import 'onboarding_page.dart';
import 'services/session_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LARIS AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      home: const _StartupRouter(),
    );
  }
}

class _StartupRouter extends StatefulWidget {
  const _StartupRouter();

  @override
  State<_StartupRouter> createState() => _StartupRouterState();
}

class _StartupRouterState extends State<_StartupRouter> {
  late final Future<bool> _shouldAutoLogin;

  @override
  void initState() {
    super.initState();
    _shouldAutoLogin = _resolveAutoLoginPreference();
  }

  Future<bool> _resolveAutoLoginPreference() async {
    final rememberMeEnabled = await SessionPreferences.getRememberMeEnabled();
    final currentUser = FirebaseAuth.instance.currentUser;
    return rememberMeEnabled && currentUser != null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _shouldAutoLogin,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        final shouldGoHome = snapshot.data ?? false;
        return shouldGoHome ? const HomePage() : const _OnboardingWithLoading();
      },
    );
  }
}

class _OnboardingWithLoading extends StatefulWidget {
  const _OnboardingWithLoading();

  @override
  State<_OnboardingWithLoading> createState() => _OnboardingWithLoadingState();
}

class _OnboardingWithLoadingState extends State<_OnboardingWithLoading> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: _SimpleLoadingIndicator()));
    }

    return const OnboardingPage();
  }
}

class _SimpleLoadingIndicator extends StatelessWidget {
  const _SimpleLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: AppColors.primary),
        const SizedBox(height: 16),
        Text(
          'Memuat konten...',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
