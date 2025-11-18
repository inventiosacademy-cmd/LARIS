import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'copy_writing.dart';
import 'template_social_media.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const List<_FeatureItem> _featureItems = [
    _FeatureItem(
      id: 'template',
      title: 'Foto Produk',
      icon: Icons.grid_view_rounded,
      assetIcon: 'assets/meningkatkan_produk.png',
      backgroundColor: AppColors.neutral95,
      iconColor: AppColors.primary,
    ),
    _FeatureItem(
      id: 'hpp',
      title: 'HPP',
      icon: Icons.insert_chart_outlined_rounded,
      assetIcon: 'assets/HPP.png',
      backgroundColor: AppColors.neutral95,
      iconColor: AppColors.primary,
    ),
    _FeatureItem(
      id: 'logo',
      title: 'Logo Branding',
      icon: Icons.brush_outlined,
      assetIcon: 'assets/generate_logo.png',
      backgroundColor: AppColors.neutral95,
      iconColor: AppColors.primary,
    ),
    _FeatureItem(
      id: 'copywriting',
      title: 'Copywriting',
      icon: Icons.edit_outlined,
      assetIcon: 'assets/copywriting.png',
      backgroundColor: AppColors.neutral95,
      iconColor: AppColors.primary,
    ),
    _FeatureItem(
      id: 'konsultan',
      title: 'Konsultan AI',
      icon: Icons.psychology_alt_outlined,
      backgroundColor: AppColors.neutral95,
      iconColor: AppColors.primary,
    ),
    _FeatureItem(
      id: 'pitch',
      title: 'Pitch Deck',
      icon: Icons.slideshow_outlined,
      backgroundColor: AppColors.neutral95,
      iconColor: AppColors.primary,
    ),
  ];

  static const List<_EventInfo> _eventInfos = [
    _EventInfo(
      title: 'Event Acara Laris',
      description: 'Eksplor strategi branding modern bersama mentor kreatif.',
      date: '12 Des 2025 - 09.00 WIB',
      location: 'Jakarta Creative Hub',
      gradient: [AppColors.primary, AppColors.primary80],
      accent: AppColors.primary,
      textColor: Colors.white,
    ),
    _EventInfo(
      title: 'Workshop Branding Digital',
      description: 'Hands-on session membuat identitas visual dan konten AI.',
      date: '19 Des 2025 - 13.00 WIB',
      location: 'Bandung Workspace',
      gradient: [AppColors.primary, AppColors.primary60],
      accent: AppColors.primary,
      textColor: Colors.white,
    ),
  ];

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final friendlyName = _deriveFriendlyName(user);
    return Scaffold(
      backgroundColor: AppColors.neutral95,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          children: [
            _ToolsPage(
              featureItems: HomePage._featureItems,
              onTap: (item) => _handleFeatureTap(context, item),
            ),
            EventAndClassPage(eventInfos: HomePage._eventInfos),
            ProfilePage(friendlyName: friendlyName, email: user?.email ?? ''),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        onTap: _handleNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Tools AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'Event & Kelas',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  void _handleFeatureTap(BuildContext context, _FeatureItem item) {
    switch (item.id) {
      case 'template':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TemplateSocialMediaPage()),
        );
        break;
      case 'copywriting':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CopyWritingPage()),
        );
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${item.title} segera hadir!')));
    }
  }

  void _handleNavTap(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    setState(() {
      _currentIndex = index;
    });
  }
}

class _FeatureButton extends StatelessWidget {
  const _FeatureButton({required this.item, this.onTap});

  final _FeatureItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = Colors.grey.shade800;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            height: 180,
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: _FeatureIcon(item: item),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: labelColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.info});

  final _EventInfo info;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: info.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: info.gradient.last.withOpacity(0.35),
            offset: const Offset(0, 14),
            blurRadius: 30,
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Text(
              'Event Acara',
              style: theme.textTheme.labelLarge?.copyWith(
                color: info.textColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            info.title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: info.textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            info.description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: info.textColor.withOpacity(0.88),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: info.textColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  info.date,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: info.textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.place_outlined, size: 18, color: info.textColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  info.location,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: info.textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: info.accent,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              textStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Text('Lihat Event'),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final String id;
  final String title;
  final IconData icon;
  final String? assetIcon;
  final Color backgroundColor;
  final Color iconColor;

  const _FeatureItem({
    required this.id,
    required this.title,
    required this.icon,
    this.assetIcon,
    required this.backgroundColor,
    required this.iconColor,
  });
}

class _FeatureIcon extends StatelessWidget {
  const _FeatureIcon({required this.item});

  final _FeatureItem item;

  @override
  Widget build(BuildContext context) {
    final fallback = _FeatureIconFallback(item: item);
    if (item.assetIcon == null) return fallback;

    return Image.asset(
      item.assetIcon!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}

class _FeatureIconFallback extends StatelessWidget {
  const _FeatureIconFallback({required this.item});

  final _FeatureItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(item.icon, color: item.iconColor, size: 36),
    );
  }
}

String _deriveFriendlyName(User? user) {
  final rawDisplayName = user?.displayName?.trim();
  if (rawDisplayName != null && rawDisplayName.isNotEmpty) {
    return rawDisplayName.split(' ').first;
  }

  final email = user?.email;
  if (email == null || email.isEmpty) return 'Pengguna';
  final localPart = email.split('@').first;
  final sanitized = localPart
      .split(RegExp(r'[._-]+'))
      .firstWhere((part) => part.isNotEmpty, orElse: () => localPart);
  final lettersOnly = RegExp(r'[A-Za-z]+').stringMatch(sanitized) ?? sanitized;
  if (lettersOnly.isEmpty) return 'Pengguna';

  final lower = lettersOnly.toLowerCase();
  return lower[0].toUpperCase() + lower.substring(1);
}

class _EventInfo {
  final String title;
  final String description;
  final String date;
  final String location;
  final List<Color> gradient;
  final Color accent;
  final Color textColor;

  const _EventInfo({
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.gradient,
    required this.accent,
    required this.textColor,
  });
}

class _FooterSectionCard extends StatelessWidget {
  const _FooterSectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _EventCarousel extends StatefulWidget {
  const _EventCarousel({required this.eventInfos});

  final List<_EventInfo> eventInfos;

  @override
  State<_EventCarousel> createState() => _EventCarouselState();
}

class _EventCarouselState extends State<_EventCarousel> {
  late final PageController _controller;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.9);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.eventInfos;
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (index) => setState(() => _current = index),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final info = events[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _EventCard(info: info),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            events.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _current == index ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _current == index
                    ? AppColors.primary
                    : Colors.grey.shade400,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.initialName,
    required this.initialEmail,
  });

  final String initialName;
  final String initialEmail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ProfileField(label: 'Nama Lengkap', initialValue: initialName),
        const SizedBox(height: 12),
        const _ProfileField(
          label: 'Jenis Usaha',
          hintText: 'Contoh: Kuliner, Fashion, Konsultan, dsb.',
        ),
        const SizedBox(height: 12),
        _ProfileField(
          label: 'Email',
          initialValue: initialEmail,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        const _ProfileField(
          label: 'Kontak / WhatsApp',
          hintText: '+62...',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil tersimpan.')),
              );
            },
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Simpan Profil'),
          ),
        ),
      ],
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    this.initialValue,
    this.hintText,
    this.keyboardType,
  });

  final String label;
  final String? initialValue;
  final String? hintText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: AppColors.neutral95,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _ToolsPage extends StatelessWidget {
  const _ToolsPage({required this.featureItems, required this.onTap});

  final List<_FeatureItem> featureItems;
  final void Function(_FeatureItem) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tools AI',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: featureItems.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final item = featureItems[index];
              return _FeatureButton(item: item, onTap: () => onTap(item));
            },
          ),
        ],
      ),
    );
  }
}

class EventAndClassPage extends StatelessWidget {
  const EventAndClassPage({required this.eventInfos});

  final List<_EventInfo> eventInfos;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: _FooterSectionCard(
        title: 'Event & Kelas',
        child: SizedBox(
          height: 160,
          child: Center(
            child: Text(
              'Segera hadir! Jadwal event dan kelas sedang disiapkan.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({required this.friendlyName, required this.email});

  final String friendlyName;
  final String email;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: _FooterSectionCard(
        title: 'Profil',
        child: _ProfileSection(initialName: friendlyName, initialEmail: email),
      ),
    );
  }
}
