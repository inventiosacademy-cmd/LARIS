import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'app_colors.dart';
import 'firebase_options.dart';
import 'onboarding_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const SplashView(),
    );
  }
}

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  late final VideoPlayerController _videoController;
  late final Future<void> _initializeVideo;
  bool _videoInitializationFailed = false;
  bool _hasNavigated = false;
  static const _splashStartColor = AppColors.primary;
  static const _splashEndColor = AppColors.primary80;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset('assets/splash.mp4');
    _initializeVideo = _initialiseVideoPlayer();
    _videoController.addListener(_handleVideoStatus);

    Future.delayed(const Duration(seconds: 8), _navigateToOnboarding);
  }

  Future<void> _initialiseVideoPlayer() async {
    try {
      await _videoController.initialize();
      if (!mounted) return;
      setState(() {});
      _videoController
        ..setLooping(false)
        ..setVolume(0.0)
        ..setPlaybackSpeed(1.5)
        ..play();
    } catch (error) {
      _videoInitializationFailed = true;
      debugPrint('Splash video failed to load: $error');
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _handleVideoStatus() {
    if (!_videoController.value.isInitialized) return;
    final position = _videoController.value.position;
    final duration = _videoController.value.duration;
    if (position >= duration) {
      _navigateToOnboarding();
    }
  }

  void _navigateToOnboarding() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingPage()),
    );
  }

  @override
  void dispose() {
    _videoController
      ..removeListener(_handleVideoStatus)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_splashStartColor, _splashEndColor],
          ),
        ),
        child: FutureBuilder<void>(
          future: _initializeVideo,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _SplashFallback(
                isLoading: false,
                message: 'Tidak dapat memutar animasi awal.',
              );
            }

            if (snapshot.connectionState != ConnectionState.done) {
              return const _SplashFallback(isLoading: true);
            }

            if (!_videoController.value.isInitialized) {
              if (_videoInitializationFailed) {
                return const _SplashFallback(
                  isLoading: false,
                  message: 'Video splash tidak tersedia.',
                );
              }
              return const _SplashFallback(isLoading: true);
            }

            return Align(
              alignment: const Alignment(-0.2, 0.0),
              child: SizedBox(
                width: 260,
                child: AspectRatio(
                  aspectRatio: _videoController.value.aspectRatio,
                  child: VideoPlayer(_videoController),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SplashFallback extends StatelessWidget {
  const _SplashFallback({
    required this.isLoading,
    this.message,
  });

  final bool isLoading;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const SizedBox(
              height: 48,
              width: 48,
              child: CircularProgressIndicator(color: Colors.white),
            )
          else
            const Icon(
              Icons.videocam_off_outlined,
              size: 48,
              color: Colors.white,
            ),
          const SizedBox(height: 16),
          Text(
            isLoading ? 'Memuat...' : (message ?? 'Sedang menyiapkan aplikasi.'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
