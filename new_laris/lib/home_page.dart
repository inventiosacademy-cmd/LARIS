import 'package:characters/characters.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'template_social_media.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const List<_FeatureItem> _featureItems = [
    _FeatureItem(
      id: 'template',
      title: 'Template\nSosial Media',
      icon: Icons.grid_view_rounded,
      backgroundColor: AppColors.primary10,
      iconColor: AppColors.primary,
    ),
    _FeatureItem(
      id: 'hpp',
      title: 'HPP',
      icon: Icons.insert_chart_outlined_rounded,
      backgroundColor: AppColors.primary05,
      iconColor: AppColors.primary,
    ),
    _FeatureItem(
      id: 'konsultan',
      title: 'Konsultan AI',
      icon: Icons.psychology_alt_outlined,
      backgroundColor: AppColors.primary20,
      iconColor: AppColors.primary,
    ),
    _FeatureItem(
      id: 'logo',
      title: 'Logo Branding',
      icon: Icons.brush_outlined,
      backgroundColor: AppColors.primary05,
      iconColor: AppColors.primary,
    ),
    _FeatureItem(
      id: 'copywriting',
      title: 'Copywriting',
      icon: Icons.edit_outlined,
      backgroundColor: AppColors.primary10,
      iconColor: AppColors.primary,
    ),
    _FeatureItem(
      id: 'pitch',
      title: 'Pitch Deck',
      icon: Icons.slideshow_outlined,
      backgroundColor: AppColors.primary05,
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final friendlyName = _deriveFriendlyName(user);
    final avatarInitial = friendlyName.isNotEmpty
        ? friendlyName.characters.first.toUpperCase()
        : 'P';
    final headingColor = Colors.grey.shade800;
    final bodyColor = Colors.grey.shade700;

    return Scaffold(
      backgroundColor: AppColors.primary05,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary10,
                    child: Text(
                      avatarInitial,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: headingColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Hi, $friendlyName 👋',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: headingColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Apa yang kamu butuhkan untuk brand kamu hari ini?',
                style: theme.textTheme.bodyMedium?.copyWith(color: bodyColor),
              ),
              const SizedBox(height: 24),
              const _SearchField(),
              const SizedBox(height: 24),
              Text(
                'Layanan Kreatif',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: headingColor,
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _featureItems.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final item = _featureItems[index];
                  return _FeatureButton(
                    item: item,
                    onTap: () => _handleFeatureTap(context, item),
                  );
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Event Acara',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: headingColor,
                ),
              ),
              const SizedBox(height: 16),
              ..._eventInfos.map(
                (event) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _EventCard(info: event),
                ),
              ),
            ],
          ),
        ),
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
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${item.title} segera hadir!')));
    }
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 6),
            blurRadius: 16,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari layanan kreatif ...',
          hintStyle: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
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
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: item.backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item.icon, color: item.iconColor, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: labelColor,
                ),
              ),
            ],
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
  final Color backgroundColor;
  final Color iconColor;

  const _FeatureItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });
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

