import 'package:flutter/material.dart';

import 'app_colors.dart';

class CopyWritingSection extends StatelessWidget {
  const CopyWritingSection({
    super.key,
    required this.platforms,
    required this.selectedPlatform,
    required this.productNameController,
    required this.productTypeController,
    required this.productSpecialController,
    required this.onPlatformChanged,
    required this.onBeautifyPressed,
    required this.onCopyPressed,
  });

  final List<String> platforms;
  final String selectedPlatform;
  final TextEditingController productNameController;
  final TextEditingController productTypeController;
  final TextEditingController productSpecialController;
  final ValueChanged<String> onPlatformChanged;
  final VoidCallback onBeautifyPressed;
  final VoidCallback onCopyPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
            children: platforms
                .map(
                  (platform) => ChoiceChip(
                    label: Text(platform),
                    selected: selectedPlatform == platform,
                    onSelected: (_) => onPlatformChanged(platform),
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: selectedPlatform == platform
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
          _buildFieldLabel(
            theme,
            label: 'Nama Produk',
            required: true,
          ),
          const SizedBox(height: 6),
          TextField(
            controller: productNameController,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hint: 'Contoh: Keripik Pisang Laris',
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldLabel(
            theme,
            label: 'Jenis Produk',
            required: true,
          ),
          const SizedBox(height: 6),
          TextField(
            controller: productTypeController,
            textInputAction: TextInputAction.next,
            decoration: _inputDecoration(
              hint: 'Contoh: Snack premium tanpa pengawet',
            ),
          ),
          const SizedBox(height: 16),
          _buildFieldLabel(
            theme,
            label: 'Ciri Khusus Produk',
          ),
          const SizedBox(height: 6),
          TextField(
            controller: productSpecialController,
            maxLines: 3,
            decoration: _inputDecoration(
              hint: 'Contoh: Renyah, tidak berminyak, banyak varian rasa',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nama produk dan jenis produk wajib diisi sebelum meneruskan ke AI.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.primary60,
            ),
          ),
          const SizedBox(height: 12),
          TemplateInfoTile(
            icon: Icons.campaign_outlined,
            title: 'Ajakan bertindak otomatis',
            subtitle:
                'CTA akan disesuaikan untuk ${selectedPlatform.toLowerCase()}.',
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onBeautifyPressed,
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
            onPressed: onCopyPressed,
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

  Widget _buildFieldLabel(
    ThemeData theme, {
    required String label,
    bool required = false,
  }) {
    return RichText(
      text: TextSpan(
        text: label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
        children: required
            ? [
                TextSpan(
                  text: ' *',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.redAccent,
                  ),
                ),
              ]
            : null,
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: AppColors.primary05,
      alignLabelWithHint: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary20),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary20),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary40),
      ),
    );
  }
}

class TemplateInfoTile extends StatelessWidget {
  const TemplateInfoTile({
    super.key,
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
