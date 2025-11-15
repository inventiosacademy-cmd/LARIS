import 'package:flutter/material.dart';

class TemplateSocialMediaPage extends StatefulWidget {
  const TemplateSocialMediaPage({super.key});

  @override
  State<TemplateSocialMediaPage> createState() =>
      _TemplateSocialMediaPageState();
}

class _TemplateSocialMediaPageState extends State<TemplateSocialMediaPage> {
  final List<String> _platforms = const ['Tiktok', 'Instagram', 'YouTube'];
  late String _selectedPlatform;
  late final TextEditingController _copyController;

  @override
  void initState() {
    super.initState();
    _selectedPlatform = _platforms[1];
    _copyController = TextEditingController(
      text: 'Keripik Pisang Premium gurih, renyah, dan tidak bikin enek! Cocok '
          'untuk teman kelip, nonton, atau hadiah kecil buat orang tersayang. '
          'Yuk cobain sekarang! Stok terbatas ❤️🔥',
    );
  }

  @override
  void dispose() {
    _copyController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Template Sosial Media',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1B1F3B),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionTitle(
                title: 'Percantik Gambar',
                subtitle:
                    'Tingkatkan visual produk kamu otomatis dengan filter terbaik.',
              ),
              const SizedBox(height: 16),
              _buildImageSection(theme),
              const SizedBox(height: 32),
              _SectionTitle(
                title: 'Percantik Deskripsi',
                subtitle:
                    'Biarkan AI membuat copywriting yang pas dengan platform kamu.',
              ),
              const SizedBox(height: 16),
              _buildCopySection(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 12),
            blurRadius: 30,
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FB),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE1E5F0)),
              ),
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.image_outlined,
                      size: 62, color: Color(0xFFB3B9C9)),
                  SizedBox(height: 10),
                  Text(
                    'Belum ada gambar',
                    style: TextStyle(color: Color(0xFF7A8195)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => _showSnack('Fitur percantik gambar segera hadir'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1C64FF),
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Percantik Gambar',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 14),
          _InfoTile(
            icon: Icons.layers_outlined,
            title: 'Brand siap tampil',
            subtitle: 'Logo dan watermark kamu otomatis terpasang.',
          ),
          const SizedBox(height: 18),
          OutlinedButton(
            onPressed: () => _showSnack('Tidak ada gambar untuk diunduh'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: const Color(0xFF1C64FF),
              side: const BorderSide(color: Color(0xFFB8C4FF), width: 1.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Download Hasil',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCopySection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            offset: const Offset(0, 12),
            blurRadius: 28,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Copywriting untuk platform apa?',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF22263F),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _platforms
                .map(
                  (platform) => ChoiceChip(
                    label: Text(platform),
                    selected: _selectedPlatform == platform,
                    onSelected: (_) {
                      setState(() {
                        _selectedPlatform = platform;
                      });
                    },
                    selectedColor: const Color(0xFF1C64FF),
                    labelStyle: TextStyle(
                      color: _selectedPlatform == platform
                          ? Colors.white
                          : const Color(0xFF5A607B),
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: const Color(0xFFF4F6FB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _copyController,
            maxLines: 6,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9FAFC),
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFE1E5F0)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.campaign_outlined,
            title: 'Ajakan bertindak otomatis',
            subtitle:
                'CTA akan disesuaikan untuk ${_selectedPlatform.toLowerCase()}.',
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () =>
                _showSnack('Percantik deskripsi untuk $_selectedPlatform'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: const Color(0xFF1C64FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Percantik dengan AI',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => _showSnack('Teks siap disalin'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: const Color(0xFF1C64FF),
              side: const BorderSide(color: Color(0xFFB8C4FF)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            child: const Text(
              'Copy',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF181C2F),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF6C728C),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FB),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF1C64FF)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E2340),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF5E637A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
