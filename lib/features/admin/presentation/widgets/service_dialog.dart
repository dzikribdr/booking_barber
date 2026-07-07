import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/service_model.dart';
import '../providers/admin_provider.dart';

class ServiceDialog extends StatefulWidget {
  final ServiceModel? service;

  const ServiceDialog({super.key, this.service});

  static void show(BuildContext context, {ServiceModel? service}) {
    showDialog(
      context: context,
      builder: (context) => ServiceDialog(service: service),
    );
  }

  @override
  State<ServiceDialog> createState() => _ServiceDialogState();
}

class _ServiceDialogState extends State<ServiceDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _durationController;
  late TextEditingController _priceController;
  
  final List<String> _categories = ['Haircut', 'Shave', 'Beard Trim', 'Treatment', 'Signature'];
  late String _selectedCategory;
  
  Uint8List? _selectedImageBytes;
  String? _selectedImageExt;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final ext = pickedFile.name.contains('.') ? pickedFile.name.split('.').last : 'jpg';
      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageExt = ext;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.service?.name ?? '');
    _descriptionController = TextEditingController(text: widget.service?.description ?? '');
    _durationController = TextEditingController(text: widget.service?.durationMinutes.toString() ?? '30');
    _priceController = TextEditingController(text: widget.service?.price.toString() ?? '0.0');
    _selectedCategory = widget.service?.category ?? 'Haircut';
    if (!_categories.contains(_selectedCategory)) {
      _categories.add(_selectedCategory);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      final duration = int.tryParse(_durationController.text.trim()) ?? 30;
      final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      
      final newService = ServiceModel(
        id: widget.service?.id ?? '', // empty id for new
        category: _selectedCategory,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        durationMinutes: duration,
        price: price,
        imageUrl: widget.service?.imageUrl, // preserve existing imageurl if any
      );

      final provider = context.read<AdminProvider>();
      String? error;
      
      if (widget.service == null) {
        error = await provider.addService(newService, imageBytes: _selectedImageBytes, imageExt: _selectedImageExt);
      } else {
        error = await provider.updateService(newService, imageBytes: _selectedImageBytes, imageExt: _selectedImageExt);
      }
      
      if (mounted) {
        if (error == null) {
          Navigator.of(context).pop(); // Close ServiceDialog
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Sukses', style: TextStyle(color: Colors.white)),
              content: const Text('Service saved successfully!', style: TextStyle(color: Colors.white70)),
              backgroundColor: AppColors.charcoalGray,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Gagal', style: TextStyle(color: Colors.red)),
              content: Text(error!, style: const TextStyle(color: Colors.white70)),
              backgroundColor: AppColors.charcoalGray,
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('OK', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.charcoalGray,
      title: Text(widget.service == null ? 'Add Service' : 'Edit Service', style: const TextStyle(color: Colors.white)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.matteBlack,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: _selectedImageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
                        )
                      : (widget.service?.imageUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(widget.service!.imageUrl!, fit: BoxFit.cover),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate, size: 40, color: AppColors.onSurfaceVariantFull),
                                SizedBox(height: 8),
                                Text('Upload Photo', style: TextStyle(color: AppColors.onSurfaceVariantFull)),
                              ],
                            )),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                dropdownColor: AppColors.charcoalGray,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Category', labelStyle: TextStyle(color: AppColors.onSurfaceVariantFull)),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: AppColors.onSurfaceVariantFull)),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Description', labelStyle: TextStyle(color: AppColors.onSurfaceVariantFull)),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Duration (mins)', labelStyle: TextStyle(color: AppColors.onSurfaceVariantFull)),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        if (int.tryParse(val) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Price (Rp)', labelStyle: TextStyle(color: AppColors.onSurfaceVariantFull)),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        if (double.tryParse(val) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (widget.service != null)
          TextButton(
            onPressed: () {
              context.read<AdminProvider>().deleteService(widget.service!.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariantFull)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: _save,
          child: const Text('Save', style: TextStyle(color: Colors.black)),
        ),
      ],
    );
  }
}
