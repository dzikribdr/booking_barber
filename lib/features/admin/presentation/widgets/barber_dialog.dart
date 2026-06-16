import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/barber_model.dart';
import '../providers/admin_provider.dart';

class BarberDialog extends StatefulWidget {
  final BarberModel? barber;

  const BarberDialog({super.key, this.barber});

  static void show(BuildContext context, {BarberModel? barber}) {
    showDialog(
      context: context,
      builder: (context) => BarberDialog(barber: barber),
    );
  }

  @override
  State<BarberDialog> createState() => _BarberDialogState();
}

class _BarberDialogState extends State<BarberDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _photoUrlController;
  late TextEditingController _startTimeController;
  late TextEditingController _endTimeController;
  String _status = 'active';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.barber?.name ?? '');
    _phoneController = TextEditingController(text: widget.barber?.phone ?? '');
    _photoUrlController = TextEditingController(text: widget.barber?.photoUrl ?? '');
    _startTimeController = TextEditingController(text: widget.barber?.startTime ?? '09:00:00');
    _endTimeController = TextEditingController(text: widget.barber?.endTime ?? '21:00:00');
    _status = widget.barber?.status ?? 'active';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _photoUrlController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final newBarber = BarberModel(
        id: widget.barber?.id ?? '', // empty id for new
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        photoUrl: _photoUrlController.text.trim().isEmpty ? null : _photoUrlController.text.trim(),
        startTime: _startTimeController.text.trim(),
        endTime: _endTimeController.text.trim(),
        status: _status,
      );

      final provider = context.read<AdminProvider>();
      if (widget.barber == null) {
        provider.addBarber(newBarber);
      } else {
        provider.updateBarber(newBarber);
      }
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.charcoalGray,
      title: Text(widget.barber == null ? 'Add Staff' : 'Edit Staff', style: const TextStyle(color: Colors.white)),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: AppColors.onSurfaceVariantFull)),
                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _phoneController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Phone', labelStyle: TextStyle(color: AppColors.onSurfaceVariantFull)),
              ),
              TextFormField(
                controller: _photoUrlController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Photo URL', labelStyle: TextStyle(color: AppColors.onSurfaceVariantFull)),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _startTimeController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'Start Time (HH:MM:SS)', labelStyle: TextStyle(color: AppColors.onSurfaceVariantFull)),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _endTimeController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(labelText: 'End Time (HH:MM:SS)', labelStyle: TextStyle(color: AppColors.onSurfaceVariantFull)),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                dropdownColor: AppColors.charcoalGray,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(labelText: 'Status', labelStyle: TextStyle(color: AppColors.onSurfaceVariantFull)),
                items: const [
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                  DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _status = val);
                },
              )
            ],
          ),
        ),
      ),
      actions: [
        if (widget.barber != null)
          TextButton(
            onPressed: () {
              context.read<AdminProvider>().deleteBarber(widget.barber!.id);
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
