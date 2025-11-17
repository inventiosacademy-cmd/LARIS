import 'package:flutter/material.dart';

import 'app_colors.dart';

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
      backgroundColor: AppColors.primary05,
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
            color: AppColors.primary,
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
                  color: AppColors.primary05,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.primary20),
                ),
              height: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.image_outlined,
                    size: 62,
                    color: AppColors.primary40,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Belum ada gambar',
                    style: TextStyle(color: AppColors.primary60),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => _showSnack('Fitur percantik gambar segera hadir'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
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
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary20, width: 1.2),
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
              color: AppColors.primary,
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
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: _selectedPlatform == platform
                          ? Colors.white
                          : AppColors.primary60,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: AppColors.primary05,
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
              fillColor: AppColors.primary05,
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary20),
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
              backgroundColor: AppColors.primary,
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
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary20),
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
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.primary60,
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
        color: AppColors.primary05,
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
            child: Icon(icon, color: AppColors.primary),
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
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary60,
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
