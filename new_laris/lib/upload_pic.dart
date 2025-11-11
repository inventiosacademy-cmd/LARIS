import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _addLogo = true;
  int _selectedLogoModel = 0;
  double _positionValue = 0.55;
  double _sizeValue = 0.4;
  double _opacityValue = 0.75;
  int _selectedBackground = 0;

  final _logoOptions = const [
    Icons.camera_alt_outlined,
    Icons.image_outlined,
    Icons.widgets_outlined,
    Icons.rounded_corner,
  ];

  final _backgroundOptions = const [
    _BackgroundOption(label: 'Original', color: Color(0xFFBDBDBD)),
    _BackgroundOption(label: 'Putih Bersih', color: Color(0xFFF5F5F5)),
    _BackgroundOption(
      label: 'Gradien',
      gradient: LinearGradient(
        colors: [Color(0xFF6A7CFF), Color(0xFF88E1FF)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    _BackgroundOption(
      label: 'Studio Blur',
      gradient: LinearGradient(
        colors: [Color(0xFF5671FF), Color(0xFF8EC5FC)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    ),
    _BackgroundOption(
      label: 'Warna Kustom',
      gradient: LinearGradient(
        colors: [Color(0xFFB8926A), Color(0xFFF3E0C5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
        title: Text(
          'Upload Photo',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPreviewCard(theme),
            const SizedBox(height: 24),
            _buildAddLogoToggle(theme),
            const SizedBox(height: 20),
            Text(
              'Model logo',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildLogoOptionsRow(theme),
            const SizedBox(height: 28),
            _buildSliderSection(
              context,
              label: 'POSISI',
              value: _positionValue,
              enabled: _addLogo,
              onChanged: (value) {
                setState(() {
                  _positionValue = value;
                });
              },
            ),
            const SizedBox(height: 24),
            _buildSliderSection(
              context,
              label: 'UKURAN',
              value: _sizeValue,
              enabled: _addLogo,
              onChanged: (value) {
                setState(() {
                  _sizeValue = value;
                });
              },
            ),
            const SizedBox(height: 24),
            _buildSliderSection(
              context,
              label: 'OPASITAS',
              value: _opacityValue,
              enabled: _addLogo,
              onChanged: (value) {
                setState(() {
                  _opacityValue = value;
                });
              },
            ),
            const SizedBox(height: 28),
            Text(
              'Background',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            _buildBackgroundOptions(theme),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Perindah'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: () {},
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Simpan'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewCard(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE0E0E0), Color(0xFFF5F5F5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      color: const Color(0xFFB97A56),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(
                      Icons.shopping_bag_rounded,
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.8),
                      size: 100,
                    ),
                  ),
                ),
              ),
              if (_addLogo)
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Opacity(
                    opacity: _opacityValue,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        'LOGO',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddLogoToggle(ThemeData theme) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          _addLogo = !_addLogo;
        });
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: _addLogo,
            onChanged: (value) {
              setState(() {
                _addLogo = value ?? false;
              });
            },
          ),
          const SizedBox(width: 8),
          Text(
            'Tambahkan logo',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoOptionsRow(ThemeData theme) {
    return Row(
      children: List.generate(_logoOptions.length, (index) {
        final selected = _selectedLogoModel == index;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
                right: index == _logoOptions.length - 1 ? 0 : 12),
            child: _SelectableIconTile(
              icon: _logoOptions[index],
              selected: selected,
              enabled: _addLogo,
              onTap: () {
                setState(() {
                  _selectedLogoModel = index;
                });
              },
              theme: theme,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSliderSection(
    BuildContext context, {
    required String label,
    required double value,
    bool enabled = true,
    required ValueChanged<double> onChanged,
  }) {
    final theme = Theme.of(context);
    final textColor = enabled
        ? theme.colorScheme.onSurface.withValues(alpha: 0.8)
        : theme.colorScheme.onSurface.withValues(alpha: 0.3);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: enabled
                ? theme.colorScheme.primary
                : theme.colorScheme.surfaceContainerHighest,
            inactiveTrackColor: theme.colorScheme.surfaceContainerHighest,
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: Slider(
            value: value,
            onChanged: enabled ? onChanged : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundOptions(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_backgroundOptions.length, (index) {
          final option = _backgroundOptions[index];
          final selected = _selectedBackground == index;
          return Padding(
            padding: EdgeInsets.only(
                right: index == _backgroundOptions.length - 1 ? 0 : 12),
            child: _BackgroundChip(
              option: option,
              selected: selected,
              onTap: () {
                setState(() {
                  _selectedBackground = index;
                });
              },
              theme: theme,
            ),
          );
        }),
      ),
    );
  }
}

class _SelectableIconTile extends StatelessWidget {
  const _SelectableIconTile({
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
    required this.theme,
  });

  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final disabledColor = theme.colorScheme.onSurface.withValues(alpha: 0.2);
    final foregroundColor = !enabled
        ? disabledColor
        : selected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withValues(alpha: 0.5);
    return Material(
      color: !enabled
          ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.8)
          : selected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Icon(
            icon,
            color: foregroundColor,
            size: 28,
          ),
        ),
      ),
    );
  }
}

class _BackgroundChip extends StatelessWidget {
  const _BackgroundChip({
    required this.option,
    required this.selected,
    required this.onTap,
    required this.theme,
  });

  final _BackgroundOption option;
  final bool selected;
  final VoidCallback onTap;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final borderColor =
        selected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: borderColor, width: 2),
                color: option.color,
                gradient: option.gradient,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 70,
          child: Text(
            option.label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}

class _BackgroundOption {
  const _BackgroundOption({
    required this.label,
    this.color,
    this.gradient,
  });

  final String label;
  final Color? color;
  final Gradient? gradient;
}
