import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../data/inventory_data.dart';

/// Result of reading a photo: the fields the form fills in.
class ItemDraft {
  const ItemDraft({
    required this.name,
    required this.category,
    required this.stock,
    required this.price,
  });

  final String name;
  final String category;
  final String stock;
  final String price;
}

/// Bottom sheet to add an item manually or fill it from a photo with AI.
class AddItemSheet extends StatefulWidget {
  const AddItemSheet({super.key});

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();
  String _category = 'Roti';
  bool _scanning = false;

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _scanWithCamera() async {
    setState(() => _scanning = true);
    try {
      final image = await ImagePicker().pickImage(
        source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (image == null) return;

      final bytes = await image.readAsBytes();
      final draft = await _analyzePhoto(bytes);
      if (!mounted) return;

      setState(() {
        _nameController.text = draft.name;
        _category = draft.category;
        _stockController.text = draft.stock;
        _priceController.text = draft.price;
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kamera tidak bisa dibuka: ${e.message}')),
      );
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  /// TODO: send the photo to the Gemini API and parse its JSON reply.
  /// Returns a fixed draft for now so the form flow can be tested.
  Future<ItemDraft> _analyzePhoto(Uint8List bytes) async {
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    return const ItemDraft(
      name: 'Sisa Adonan Croissant',
      category: 'Bahan',
      stock: '2',
      price: 'Rp 6.000',
    );
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      InventoryItem(
        name: _nameController.text.trim(),
        category: _category,
        price: _priceController.text.trim().isEmpty
            ? 'Rp 0'
            : _priceController.text.trim(),
        stock: int.tryParse(_stockController.text.trim()) ?? 0,
        unit: 'pcs',
        icon: _iconFor(_category),
        sold30d: 0,
      ),
    );
  }

  IconData _iconFor(String category) {
    switch (category) {
      case 'Bahan':
        return Icons.grain;
      case 'Kemasan':
        return Icons.inventory_2_outlined;
      default:
        return Icons.bakery_dining_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final categories = InventoryData.categories.where((c) => c != 'Semua');

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tambah barang',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Ketik manual atau foto sisa bahan. AI akan mengisi form.',
                style: textTheme.bodySmall?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Nama barang wajib diisi'
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Nama barang / deskripsi',
                        prefixIcon: Icon(Icons.edit_outlined),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _AiCameraButton(
                    scanning: _scanning,
                    onTap: _scanning ? null : _scanWithCamera,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Kategori',
                style: textTheme.labelMedium?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final c in categories)
                    ChoiceChip(
                      label: Text(c),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                      selectedColor: AppColors.mint,
                      backgroundColor: AppColors.background,
                      side: BorderSide.none,
                      showCheckmark: false,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Stok',
                        prefixIcon: Icon(Icons.numbers_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Estimasi harga beli',
                        prefixIcon: Icon(Icons.sell_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Simpan ke Inventory'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AiCameraButton extends StatelessWidget {
  const _AiCameraButton({required this.scanning, required this.onTap});

  final bool scanning;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.purple,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 56,
          height: 56,
          child: scanning
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.photo_camera_rounded, color: Colors.white),
        ),
      ),
    );
  }
}
