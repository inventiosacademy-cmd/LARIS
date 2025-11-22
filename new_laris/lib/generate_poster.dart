import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'app_colors.dart';
import 'services/ai_generate_poster_service.dart';

class GeneratePosterPage extends StatefulWidget {
  const GeneratePosterPage({super.key});

  @override
  State<GeneratePosterPage> createState() => _GeneratePosterPageState();
}

class _GeneratePosterPageState extends State<GeneratePosterPage> {
  static const int _maxPhotos = 5;

  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _promoController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  final List<_PosterPhoto> _photos = [];
  final AiGeneratePosterService _posterService = AiGeneratePosterService();

  bool _isGeneratingPoster = false;
  bool _isDownloadingPoster = false;
  AiPosterResult? _posterResult;

  @override
  void dispose() {
    _brandController.dispose();
    _descriptionController.dispose();
    _promoController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _contactController.dispose();
    _posterService.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String? _optionalValue(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _openPickerSheet() async {
    if (_photos.length >= _maxPhotos) {
      _showSnack('Maksimal $_maxPhotos foto telah tercapai.');
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Ambil dari Kamera'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Pilih dari Galeri'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickFromGallery();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickFromCamera() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        maxHeight: 2000,
        maxWidth: 2000,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photos.add(_PosterPhoto(bytes: bytes, label: picked.name));
      });
    } catch (error) {
      _showSnack('Kamera tidak dapat dibuka: $error');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final remaining = _maxPhotos - _photos.length;
      if (remaining <= 0) {
        _showSnack('Maksimal $_maxPhotos foto telah tercapai.');
        return;
      }
      final files = await _picker.pickMultiImage(
        imageQuality: 90,
        maxHeight: 2000,
        maxWidth: 2000,
      );
      if (files.isEmpty) return;
      final allowedFiles = files.take(remaining);
      final List<_PosterPhoto> newPhotos = [];
      for (final file in allowedFiles) {
        final bytes = await file.readAsBytes();
        newPhotos.add(_PosterPhoto(bytes: bytes, label: file.name));
      }
      if (!mounted) return;
      setState(() {
        _photos.addAll(newPhotos);
      });
    } catch (error) {
      _showSnack('Gagal memilih foto: $error');
    }
  }

  void _removePhoto(_PosterPhoto photo) {
    setState(() {
      _photos.remove(photo);
    });
  }

  Future<void> _generatePoster() async {
    if (_photos.isEmpty) {
      _showSnack('Unggah minimal satu foto produk terlebih dahulu.');
      return;
    }
    final brand = _brandController.text.trim();
    if (brand.isEmpty) {
      _showSnack('Nama Brand/Usaha wajib diisi.');
      return;
    }
    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      _showSnack('Keterangan Jasa/Produk wajib diisi.');
      return;
    }

    setState(() {
      _isGeneratingPoster = true;
      _posterResult = null;
    });

    try {
      final result = await _posterService.generatePoster(
        photos: _photos.map((photo) => photo.bytes).toList(),
        brandName: brand,
        productDescription: description,
        price: _optionalValue(_priceController.text),
        promo: _optionalValue(_promoController.text),
        location: _optionalValue(_locationController.text),
        contact: _optionalValue(_contactController.text),
      );
      if (!mounted) return;
      setState(() {
        _posterResult = result;
      });
      _showSnack('Poster berhasil dibuat. Tekan "Unduh" untuk menyimpannya.');
    } on AiGeneratePosterServiceException catch (error) {
      if (!mounted) return;
      _showSnack(error.message);
    } catch (error) {
      if (!mounted) return;
      _showSnack('Gagal membuat poster: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPoster = false;
        });
      }
    }
  }

  Future<void> _downloadPoster() async {
    final result = _posterResult;
    if (result == null || _isDownloadingPoster) {
      _showSnack('Belum ada poster untuk diunduh.');
      return;
    }
    setState(() {
      _isDownloadingPoster = true;
    });
    try {
      final baseName = _optionalValue(_brandController.text) ?? 'laris_poster';
      final safeName =
          baseName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_').toLowerCase();
      final fileName =
          '${safeName}_${DateTime.now().millisecondsSinceEpoch}.${result.suggestedExtension}';
      final path = await _posterService.downloadPoster(
        result.bytes,
        fileName: fileName,
      );
      if (!mounted) return;
      _showSnack('Poster tersimpan di $path');
    } catch (error) {
      if (!mounted) return;
      _showSnack('Gagal mengunduh poster: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingPoster = false;
        });
      }
    }
  }

  void _requestAnotherDesign() {
    if (_posterResult == null) return;
    setState(() {
      _posterResult = null;
    });
    _showSnack('Silakan atur ulang detail dan buat desain baru.');
  }

  Future<void> _showFullPoster(Uint8List bytes) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.86),
      builder: (dialogContext) {
        return GestureDetector(
          onTap: () => Navigator.of(dialogContext).pop(),
          child: Stack(
            children: [
              Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Image.memory(
                      bytes,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 24,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.neutral95,
      appBar: AppBar(
        backgroundColor: AppColors.neutral95,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'AI Pembuat Poster Grafis',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Unggah Foto Produk Anda',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pilih hingga $_maxPhotos foto terbaik untuk poster Anda.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              _UploadPlaceholder(
                onTap: _openPickerSheet,
                isDisabled: _photos.length >= _maxPhotos,
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Foto dipilih: ${_photos.length}/$_maxPhotos',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ),
              if (_photos.isNotEmpty) ...[
                const SizedBox(height: 12),
                _PhotoGrid(
                  photos: _photos,
                  onRemove: _removePhoto,
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Lengkapi Detail Informasi',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              _PosterTextField(
                controller: _brandController,
                label: 'Nama Brand/Usaha',
                hint: 'Contoh: Kopi Senja',
              ),
              _PosterTextField(
                controller: _descriptionController,
                label: 'Keterangan Jasa/Produk',
                hint: 'Contoh: Kopi susu gula aren terbaik di kota',
                maxLines: 3,
              ),
              _PosterTextField(
                controller: _promoController,
                label: 'Info Promo (Opsional)',
                hint: 'Contoh: Diskon 50%',
              ),
              _PosterTextField(
                controller: _priceController,
                label: 'Harga (Opsional)',
                hint: 'Contoh: Rp 20.000',
                keyboardType: TextInputType.number,
              ),
              _PosterTextField(
                controller: _locationController,
                label: 'Lokasi (Opsional)',
                hint: 'Contoh: Jakarta Barat',
              ),
              _PosterTextField(
                controller: _contactController,
                label: 'Info Kontak',
                hint: 'Contoh: No. WA, Instagram, dll',
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isGeneratingPoster ? null : _generatePoster,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isGeneratingPoster
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('AI sedang membuat poster...'),
                          ],
                        )
                      : const Text('Buat Desain Poster'),
                ),
              ),
              const SizedBox(height: 20),
              _PosterResultCard(
                result: _posterResult,
                isLoading: _isGeneratingPoster,
                onPreview: _posterResult != null
                    ? () => _showFullPoster(_posterResult!.bytes)
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (_isDownloadingPoster || _posterResult == null)
                          ? null
                          : _downloadPoster,
                      icon: _isDownloadingPoster
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.download_outlined),
                      label: Text(
                        _isDownloadingPoster ? 'Menyiapkan...' : 'Unduh',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFCFD8FF),
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed:
                          _posterResult != null ? _requestAnotherDesign : null,
                      icon: const Icon(Icons.autorenew_rounded),
                      label: const Text('Coba Desain Lain'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        foregroundColor: Colors.black87,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                        side: const BorderSide(color: Colors.black12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadPlaceholder extends StatelessWidget {
  const _UploadPlaceholder({
    required this.onTap,
    this.isDisabled = false,
  });

  final VoidCallback onTap;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final color = isDisabled ? Colors.grey.shade300 : AppColors.primary;
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              color: color,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Tambah dari Kamera atau Galeri',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Klik untuk mulai mengunggah foto.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: isDisabled ? Colors.grey.shade200 : AppColors.primary10,
                borderRadius: BorderRadius.circular(30),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
              child: Text(
                isDisabled ? 'Batas Tercapai' : 'Pilih Foto',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isDisabled ? Colors.black45 : AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({
    required this.photos,
    required this.onRemove,
  });

  final List<_PosterPhoto> photos;
  final ValueChanged<_PosterPhoto> onRemove;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: photos
          .map(
            (photo) => Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.memory(
                    photo.bytes,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () => onRemove(photo),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black87,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}

class _PosterTextField extends StatelessWidget {
  const _PosterTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterResultCard extends StatelessWidget {
  const _PosterResultCard({
    required this.result,
    required this.isLoading,
    this.onPreview,
  });

  final AiPosterResult? result;
  final bool isLoading;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPoster = result != null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ini Dia Desain Poster Anda!',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            hasPoster
                ? 'Poster siap diunduh. Sentuh gambar untuk memperbesar.'
                : 'Buat desain terlebih dahulu untuk melihat hasil di sini.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1D7C8),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(20),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        2,
                        (_) => Container(
                          width: 24,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: hasPoster
                          ? GestureDetector(
                              key: const ValueKey('poster-result'),
                              onTap: onPreview,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.memory(
                                  result!.bytes,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          : _PosterPlaceholder(
                              key: const ValueKey('poster-placeholder'),
                              isLoading: isLoading,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder({super.key, required this.isLoading});

  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFF8EBDD),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: AppColors.primary,
              size: 44,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada desain',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Klik tombol "Buat Desain Poster" untuk memulai.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.black54,
            ),
          ),
          if (isLoading) ...[
            const SizedBox(height: 16),
            const CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PosterPhoto {
  const _PosterPhoto({required this.bytes, required this.label});

  final Uint8List bytes;
  final String label;
}
