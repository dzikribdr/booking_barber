import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/booking_provider.dart';

class BookingSelectionPage extends StatefulWidget {
  const BookingSelectionPage({super.key});

  @override
  State<BookingSelectionPage> createState() => _BookingSelectionPageState();
}

class _BookingSelectionPageState extends State<BookingSelectionPage> {
  int _selectedDateIndex = 0; 
  String _selectedTime = ''; 

  late final List<Map<String, String>> _dates;

  @override
  void initState() {
    super.initState();
    _generateDates();
  }

  void _generateDates() {
    _dates = [];
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      _dates.add({
        'day': DateFormat('E').format(date).toUpperCase(),
        'date': DateFormat('dd').format(date),
        'fullDate': DateFormat('yyyy-MM-dd').format(date),
      });
    }
  }
  
  final List<Map<String, dynamic>> _morningSlots = [
    {'time': '09:00', 'isBooked': true},
    {'time': '09:30', 'isBooked': false},
    {'time': '10:00', 'isBooked': false},
    {'time': '10:30', 'isBooked': true},
    {'time': '11:00', 'isBooked': false},
    {'time': '11:30', 'isBooked': false},
  ];

  final List<Map<String, dynamic>> _afternoonSlots = [
    {'time': '12:00', 'isBooked': false},
    {'time': '12:30', 'isBooked': false},
    {'time': '13:00', 'isBooked': true},
    {'time': '13:30', 'isBooked': false},
    {'time': '14:00', 'isBooked': false},
    {'time': '14:30', 'isBooked': false},
    {'time': '15:00', 'isBooked': false},
    {'time': '15:30', 'isBooked': false},
  ];

  Future<void> _handleBooking() async {
    final bookingProvider = context.read<BookingProvider?>();
    if (bookingProvider == null) return;

    final selectedService = bookingProvider.selectedService;
    if (selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a service from the Home page first.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    final dateStr = _dates[_selectedDateIndex]['fullDate']!;
    final serviceId = selectedService.id;
    final price = selectedService.price;

    final errorMsg = await bookingProvider.createBooking(
      serviceId: serviceId,
      bookingDate: dateStr,
      bookingTime: '$_selectedTime:00',
      totalAmount: price,
    );

    if (errorMsg == null && mounted) {
      context.push('/payment');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: $errorMsg'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider?>();
    final isLoading = bookingProvider?.isLoading ?? false;
    final selectedService = bookingProvider?.selectedService;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariantFull),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go('/home');
            }
          },
        ),
        title: Text(
          'BARBER 69',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
        ),
        centerTitle: true,
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://i.pravatar.cc/100?img=11'),
              backgroundColor: AppColors.charcoalGray,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main Scrollable Content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120, top: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Date & Time',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      const Icon(Icons.content_cut, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        selectedService != null ? selectedService.name : 'Executive Haircut & Beard Trim',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 16, color: AppColors.onSurfaceVariantFull),
                      const SizedBox(width: 8),
                      Text(
                        'with ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariantFull,
                            ),
                      ),
                      Text(
                        'Marcus',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _dates.length,
                      itemBuilder: (context, index) {
                        final isSelected = _selectedDateIndex == index;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: InkWell(
                            onTap: () => setState(() {
                              _selectedDateIndex = index;
                            }),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              width: 70,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.primary : AppColors.charcoalGray,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _dates[index]['day']!,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: isSelected ? Colors.black87 : AppColors.onSurfaceVariantFull,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _dates[index]['date']!,
                                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: isSelected ? Colors.black : Colors.white70,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text(
                    'MORNING',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildTimeGrid(_morningSlots),
                  
                  const SizedBox(height: 32),

                  Text(
                    'AFTERNOON',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildTimeGrid(_afternoonSlots),
                ],
              ),
            ),
          ),
          
          // Sticky Bottom Button
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (_selectedTime.isNotEmpty && !isLoading) ? _handleBooking : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: AppColors.surfaceContainerHighest,
                  disabledForegroundColor: AppColors.onSurfaceVariantFull,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'CONTINUE TO PAYMENT',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeGrid(List<Map<String, dynamic>> slots) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        final time = slot['time'] as String;
        final isBooked = slot['isBooked'] as bool;
        final isSelected = _selectedTime == time;

        return InkWell(
          onTap: isBooked ? null : () => setState(() => _selectedTime = time),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.charcoalGray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              time,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isBooked ? Colors.white24 : (isSelected ? AppColors.primary : Colors.white70),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    decoration: isBooked ? TextDecoration.lineThrough : null,
                  ),
            ),
          ),
        );
      },
    );
  }
}

