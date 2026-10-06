import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../data/inventory_data.dart';
import '../../../core/format/format.dart';
import '../data/inventory_ai.dart';
import '../data/product_icons.dart';
import 'product_icon_image.dart';
import '../data/inventory_repository.dart';

/// Bottom sheet to add an item manually or fill it from a photo with AI.
/// Pops with a [NewItem] for the caller to save.
class AddItemSheet extends StatefulWidget {
  const AddItemSheet({super.key, required this.userId});

  final int userId;

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();
  String _category = 'Roti';
  String _iconKey = 'bakery';
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
      final draft = await InventoryAi().analyzePhoto(widget.userId, bytes);
      if (!mounted) return;

      setState(() {
        _nameController.text = draft.name;
        _category = draft.category;
        _iconKey = _iconKeyFor(draft.category);
        _stockController.text = '${draft.stock}';
        _priceController.text = rupiah(draft.priceIdr);
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

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final digits = _priceController.text.replaceAll(RegExp(r'[^0-9]'), '');
    Navigator.of(context).pop(
      NewItem(
        name: _nameController.text.trim(),
        category: _category,
        stock: int.tryParse(_stockController.text.trim()) ?? 0,
        priceIdr: int.tryParse(digits) ?? 0,
        iconKey: _iconKey,
      ),
    );
  }

  String _iconKeyFor(String category) {
    switch (category) {
      case 'Bahan':
        return 'grain';
      case 'Kemasan':
        return 'box';
      default:
        return 'bakery';
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
                      onSelected: (_) => setState(() {
                        _category = c;
                        _iconKey = _iconKeyFor(c);
                      }),
                      selectedColor: AppColors.mint,
                      backgroundColor: AppColors.background,
                      side: BorderSide.none,
                      showCheckmark: false,
                    ),
                ],
              ),
              Text(
                'Jenis produk',
                style: textTheme.labelMedium?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 64,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final icon in productIcons)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => setState(() => _iconKey = icon.key),
                          child: Container(
                            width: 60,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _iconKey == icon.key
                                  ? AppColors.mintSoft
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: _iconKey == icon.key
                                    ? AppColors.ink
                                    : Colors.transparent,
                              ),
                            ),
                            child:
                                ProductIconImage(iconKey: icon.key, size: 36),
                          ),
                        ),
                      ),
                  ],
                ),
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
