import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/style_vault_provider.dart';
import 'package:intl/intl.dart';

class StyleVaultPage extends StatefulWidget {
  const StyleVaultPage({super.key});

  @override
  State<StyleVaultPage> createState() => _StyleVaultPageState();
}

class _StyleVaultPageState extends State<StyleVaultPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StyleVaultProvider>().fetchStyles();
    });
  }

  void _showAddPhotoDialog() {
    final TextEditingController notesController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.charcoalGray,
        title: const Text('Tambah Gaya Rambut', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: notesController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Cth: Potongan rapi sisi pendek',
            hintStyle: TextStyle(color: AppColors.onSurfaceVariantFull),
            filled: true,
            fillColor: AppColors.matteBlack,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.onSurfaceVariantFull)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _uploadPhoto(notesController.text.trim());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.black),
            child: const Text('Pilih Foto & Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _uploadPhoto(String notes) async {
    final provider = context.read<StyleVaultProvider>();
    final success = await provider.uploadStyleImage(notes);
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto berhasil diunggah!'), backgroundColor: Colors.green));
      } else if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${provider.error}'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StyleVaultProvider>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Style Vault', style: TextStyle(letterSpacing: 1.5)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo, color: AppColors.primary),
            onPressed: _showAddPhotoDialog,
          ),
        ],
      ),
      body: provider.isLoading && provider.styles.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : provider.styles.isEmpty
              ? _buildEmptyState(context)
              : _buildGallery(context, provider),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.photo_library_outlined, size: 80, color: AppColors.onSurfaceVariantFull),
          const SizedBox(height: 24),
          Text(
            'Galeri Kosong',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'Simpan foto referensi potongan rambut favorit Anda\nagar mudah ditunjukkan ke kapster nanti.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariantFull),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showAddPhotoDialog,
            icon: const Icon(Icons.add),
            label: const Text('Tambah Foto Baru'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGallery(BuildContext context, StyleVaultProvider provider) {
    return Stack(
      children: [
        GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.75,
          ),
          itemCount: provider.styles.length,
          itemBuilder: (context, index) {
            final style = provider.styles[index];
            return Container(
              decoration: BoxDecoration(
                color: AppColors.charcoalGray,
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    style.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    },
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black87, Colors.transparent],
                        )
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (style.notes != null && style.notes!.isNotEmpty)
                            Text(
                              style.notes!,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (style.createdAt != null)
                            Text(
                              DateFormat('dd MMM yyyy').format(style.createdAt!),
                              style: const TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8, right: 8,
                    child: GestureDetector(
                      onTap: () {
                        // Confirm deletion
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.charcoalGray,
                            title: const Text('Hapus Foto?', style: TextStyle(color: Colors.white)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Batal', style: TextStyle(color: AppColors.onSurfaceVariantFull)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  provider.deleteStyle(style.id);
                                },
                                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          )
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.white, size: 18),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
        if (provider.isLoading)
          const Positioned(
            top: 16, right: 16,
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
      ],
    );
  }
}
