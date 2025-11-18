import 'dart:async';

import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'login_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _slides = [
    _OnboardingSlide(
      title: 'Satu Aplikasi untuk UMKM Naik Level',
      description:
          'Semua tools AI dalam satu aplikasi. Praktis, cepat, dan siap melesatkan bisnis.',
      imageAsset: 'assets/logo.png',
    ),
    _OnboardingSlide(
      title: 'Foto Produk Naik Kelas',
      description:
          'Ubah foto biasa jadi kualitas profesional. Cerah, tajam, dan menarik di semua platform.',
      imageAsset: 'assets/meningkatkan_produk.png',
    ),
    _OnboardingSlide(
      title: 'Copywriting Otomatis Lebih Menjual',
      description:
          'Copywriting otomatis yang langsung jualan. Cocok untuk Instagram, TikTok, YouTube, dan marketplace.',
      imageAsset: 'assets/copywriting.png',
    ),
    _OnboardingSlide(
      title: 'Harga Jual Paling Pas di Pasar',
      description:
          'Rekomendasi harga jual otomatis dari HPP, lokasi, dan tren kompetitor untuk profit maksimal.',
      imageAsset: 'assets/HPP.png',
    ),
    _OnboardingSlide(
      title: 'Logo Instan untuk UMKM',
      description:
          'Logo profesional siap pakai dalam hitungan detik. Pas untuk brand baru atau rebranding.',
      imageAsset: 'assets/generate_logo.png',
    ),
  ];

  final _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _handlePageChanged(int index) {
    setState(() => _currentPage = index);
    _startAutoSlide();
  }

  void _handleGetStarted() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  void _startAutoSlide() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.primary05,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _handlePageChanged,
                physics: const BouncingScrollPhysics(),
                itemCount: _slides.length,
                itemBuilder: (_, index) {
                  final slide = _slides[index];
                  return _OnboardingSlideView(slide: slide);
                },
              ),
            ),
            const SizedBox(height: 12),
            _PageIndicators(
              itemCount: _slides.length,
              currentIndex: _currentPage,
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _handleGetStarted,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(52),
                    textStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text('Get Started'),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _OnboardingSlideView extends StatelessWidget {
  const _OnboardingSlideView({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleColor = Colors.grey.shade800;
    final bodyColor = Colors.grey.shade700;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.60,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: Image.asset(
                slide.imageAsset,
                key: ValueKey(slide.imageAsset),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.primary40,
                      size: 64,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tambahkan ilustrasi ke ${slide.imageAsset}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: Column(
              key: ValueKey(slide.title),
              children: [
                Text(
                  slide.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  slide.description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: bodyColor,
                    height: 1.4,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _PageIndicators extends StatelessWidget {
  const _PageIndicators({required this.itemCount, required this.currentIndex});

  final int itemCount;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(itemCount, (index) {
        final isActive = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 18 : 8,
          height: 6,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

class _OnboardingSlide {
  final String title;
  final String description;
  final String imageAsset;

  const _OnboardingSlide({
    required this.title,
    required this.description,
    required this.imageAsset,
  });
}
