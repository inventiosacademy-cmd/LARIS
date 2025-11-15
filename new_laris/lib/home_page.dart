import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const List<_FeatureItem> _featureItems = [
    _FeatureItem(
      title: 'Template\nSosial Media',
      icon: Icons.grid_view_rounded,
      backgroundColor: Color(0xFFFFF3F6),
      iconColor: Color(0xFFFF6B8A),
    ),
    _FeatureItem(
      title: 'HPP',
      icon: Icons.insert_chart_outlined_rounded,
      backgroundColor: Color(0xFFEFF5FF),
      iconColor: Color(0xFF2E64FF),
    ),
    _FeatureItem(
      title: 'Konsultan AI',
      icon: Icons.psychology_alt_outlined,
      backgroundColor: Color(0xFFEFFBF4),
      iconColor: Color(0xFF00A56F),
    ),
    _FeatureItem(
      title: 'Logo Branding',
      icon: Icons.brush_outlined,
      backgroundColor: Color(0xFFFFF4E6),
      iconColor: Color(0xFFFF8A00),
    ),
    _FeatureItem(
      title: 'Copywriting',
      icon: Icons.edit_outlined,
      backgroundColor: Color(0xFFEFF1FF),
      iconColor: Color(0xFF4A57FF),
    ),
    _FeatureItem(
      title: 'Pitch Deck',
      icon: Icons.slideshow_outlined,
      backgroundColor: Color(0xFFF4ECFF),
      iconColor: Color(0xFF8257FF),
    ),
  ];

  static const List<_EventInfo> _eventInfos = [
    _EventInfo(
      title: 'Event Acara Laris',
      description: 'Eksplor strategi branding modern bersama mentor kreatif.',
      date: '12 Des 2025 - 09.00 WIB',
      location: 'Jakarta Creative Hub',
      gradient: [
        Color(0xFF5364FF),
        Color(0xFF6D8BFF),
      ],
      accent: Color(0xFF3A4CFF),
      textColor: Colors.white,
    ),
    _EventInfo(
      title: 'Workshop Branding Digital',
      description: 'Hands-on session membuat identitas visual dan konten AI.',
      date: '19 Des 2025 - 13.00 WIB',
      location: 'Bandung Workspace',
      gradient: [
        Color(0xFFFF8FB1),
        Color(0xFFFFB37D),
      ],
      accent: Color(0xFFEE5C87),
      textColor: Colors.white,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  _CircleIconButton(icon: Icons.menu_rounded),
                  Spacer(),
                  _CircleIconButton(icon: Icons.notifications_none_rounded),
                  SizedBox(width: 12),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Color(0xFFFFE6EC),
                    child: Icon(
                      Icons.person,
                      color: Color(0xFFFF5C8A),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Hello Nessa',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C2033),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Apa yang kamu butuhkan untuk brand kamu hari ini?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6E7384),
                ),
              ),
              const SizedBox(height: 24),
              const _SearchField(),
              const SizedBox(height: 24),
              Text(
                'Layanan Kreatif',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C2033),
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
                  return _FeatureButton(item: _featureItems[index]);
                },
              ),
              const SizedBox(height: 32),
              Text(
                'Event Acara',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1C2033),
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
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFFB0B4C1),
              ),
          prefixIcon:
              const Icon(Icons.search_rounded, color: Color(0xFF9095A5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class _FeatureButton extends StatelessWidget {
  const _FeatureButton({required this.item});

  final _FeatureItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
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
              color: const Color(0xFF1F2637),
            ),
          ),
        ],
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

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(icon, color: const Color(0xFF1C2033)),
    );
  }
}

class _FeatureItem {
  final String title;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  const _FeatureItem({
    required this.title,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });
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
