import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/booking_provider.dart';

class RateBarberDialog extends StatefulWidget {
  final String bookingId;
  final String barberId;
  final String barberName;

  const RateBarberDialog({
    super.key,
    required this.bookingId,
    required this.barberId,
    required this.barberName,
  });

  @override
  State<RateBarberDialog> createState() => _RateBarberDialogState();
}

class _RateBarberDialogState extends State<RateBarberDialog> {
  double _rating = 0;
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a rating first')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final provider = context.read<BookingProvider?>();
    final errorMsg = await provider?.submitBarberRating(
      widget.bookingId,
      widget.barberId,
      _rating,
      _reviewController.text.trim(),
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (errorMsg == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rating submitted successfully!')),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $errorMsg'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.charcoalGray,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Rate ${widget.barberName}', style: const TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('How was your haircut?', style: TextStyle(color: AppColors.onSurfaceVariantFull)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: AppColors.primary,
                  size: 32,
                ),
                onPressed: () {
                  setState(() {
                    _rating = index + 1.0;
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reviewController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Leave a review (optional)',
              hintStyle: const TextStyle(color: AppColors.onSurfaceVariantFull),
              filled: true,
              fillColor: AppColors.matteBlack,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancel', style: TextStyle(color: AppColors.onSurfaceVariantFull)),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitRating,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.matteBlack,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: _isSubmitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Submit'),
        ),
      ],
    );
  }
}
