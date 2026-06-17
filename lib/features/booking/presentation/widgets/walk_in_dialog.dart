import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/booking_provider.dart';
import 'package:intl/intl.dart';

class WalkInDialog extends StatefulWidget {
  const WalkInDialog({super.key});

  @override
  State<WalkInDialog> createState() => _WalkInDialogState();
}

class _WalkInDialogState extends State<WalkInDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController(text: '30'); // Default price
  bool _isLoading = false;
  String? _selectedBarberId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider?>()?.fetchActiveBarbers();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitWalkIn() async {
    final name = _nameController.text.trim();
    final priceStr = _priceController.text.trim();
    
    if (name.isEmpty || priceStr.isEmpty || _selectedBarberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi nama, harga, dan pilih Barber')),
      );
      return;
    }

    final price = double.tryParse(priceStr);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harga tidak valid')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final bookingProvider = context.read<BookingProvider?>();
    
    // For walk-in, we use current date and time as the starting time
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy-MM-dd').format(now);
    final timeStr = DateFormat('HH:mm:ss').format(now); // exact time now

    // We assume there's a generic "Walk-In Service" ID or we just pass the first service ID
    // Ideally admin selects a service, but for simplicity we use a dummy or first available service
    final serviceId = bookingProvider?.selectedService?.id ?? '00000000-0000-0000-0000-000000000000'; 

    final errorMsg = await bookingProvider?.createBooking(
      serviceId: serviceId,
      barberId: _selectedBarberId!,
      bookingDate: dateStr,
      bookingTime: timeStr,
      totalAmount: price,
      walkInName: name,
    );

    setState(() => _isLoading = false);

    if (errorMsg == null && mounted) {
      Navigator.pop(context, true); // Return true on success
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: $errorMsg')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.charcoalGray,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Input Pelanggan Walk-In', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Otomatis menempati slot saat ini agar antrean online tidak bentrok.', 
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariantFull)),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nama Pelanggan',
                labelStyle: const TextStyle(color: AppColors.onSurfaceVariantFull),
                filled: true,
                fillColor: AppColors.matteBlack,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Estimasi Harga (\$)',
                labelStyle: const TextStyle(color: AppColors.onSurfaceVariantFull),
                filled: true,
                fillColor: AppColors.matteBlack,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),
            Consumer<BookingProvider?>(
              builder: (context, provider, child) {
                if (provider == null || provider.activeBarbers.isEmpty) {
                  return const Text('Loading barbers...', style: TextStyle(color: AppColors.onSurfaceVariantFull));
                }
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.matteBlack,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedBarberId,
                      hint: const Text('Pilih Barber', style: TextStyle(color: AppColors.onSurfaceVariantFull)),
                      dropdownColor: AppColors.charcoalGray,
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                      items: provider.activeBarbers.map((barber) {
                        return DropdownMenuItem<String>(
                          value: barber['id'] as String,
                          child: Text(
                            barber['name'] ?? 'Unknown',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedBarberId = value;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: AppColors.onSurfaceVariantFull)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitWalkIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.black,
                  ),
                  child: _isLoading 
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Text('Tambah Antrean'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
