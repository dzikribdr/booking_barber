import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/booking_provider.dart';
import '../../../queue/presentation/providers/queue_provider.dart';

class BookingSelectionPage extends StatefulWidget {
  const BookingSelectionPage({super.key});

  @override
  State<BookingSelectionPage> createState() => _BookingSelectionPageState();
}

class _BookingSelectionPageState extends State<BookingSelectionPage> {
  int _selectedDateIndex = 0; 
  String _selectedTime = ''; 
  String? _selectedBarberId;
  bool _isForOther = false;
  final TextEditingController _guestNameController = TextEditingController();

  late final List<Map<String, String>> _dates;

  @override
  void initState() {
    super.initState();
    _generateDates();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider?>()?.fetchActiveBarbers();
    });
  }

  @override
  void dispose() {
    _guestNameController.dispose();
    super.dispose();
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
  
  final List<String> _morningSlots = [
    '09:00', '09:30', '10:00', '10:30', '11:00', '11:30'
  ];

  final List<String> _afternoonSlots = [
    '12:00', '12:30', '13:00', '13:30', '14:00', '14:30',
    '15:00', '15:30', '16:00', '16:30', '17:00', '17:30'
  ];

  final List<String> _eveningSlots = [
    '18:00', '18:30', '19:00', '19:30', '20:00', '20:30', '21:00'
  ];

  void _fetchBookedTimesIfNeeded() {
    if (_selectedBarberId != null) {
      final dateStr = _dates[_selectedDateIndex]['fullDate']!;
      context.read<BookingProvider?>()?.fetchBookedTimes(dateStr, _selectedBarberId!);
      setState(() {
        _selectedTime = '';
      });
    }
  }

  Future<void> _handleBooking() async {
    final bookingProvider = context.read<BookingProvider?>();
    final queueProvider = context.read<QueueProvider?>();
    
    if (bookingProvider == null) return;

    if (queueProvider != null && queueProvider.hasActiveQueue) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.charcoalGray,
          title: const Text('Peringatan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: const Text(
            'Anda sudah melakukan booking. Selesaikan atau batalkan antrean Anda saat ini terlebih dahulu.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

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

    if (_selectedBarberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a Barber.'),
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
      barberId: _selectedBarberId!,
      bookingDate: dateStr,
      bookingTime: '$_selectedTime:00',
      totalAmount: price,
      isForOther: _isForOther,
      guestName: _isForOther ? _guestNameController.text.trim() : null,
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
    final queueProvider = context.watch<QueueProvider?>();
    
    final isLoading = bookingProvider?.isLoading ?? false;
    final selectedService = bookingProvider?.selectedService;
    final globalQueue = queueProvider?.globalQueue ?? [];
    final bookedTimes = bookingProvider?.bookedTimes ?? [];

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
          'BARBER 96',
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
                      if (bookingProvider != null && bookingProvider.activeBarbers.isNotEmpty)
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedBarberId,
                              hint: Text('Select Barber', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariantFull)),
                              dropdownColor: AppColors.charcoalGray,
                              icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                              isDense: true,
                              items: bookingProvider.activeBarbers.map((barber) {
                                final barberId = barber['id'].toString();
                                final barberName = barber['name'] ?? 'Unknown';
                                final isBusy = globalQueue.any((b) => 
                                    b['barber_id'].toString() == barberId && 
                                    (b['status'] == 'in-progress' || b['status'] == 'confirmed'));
                                final displayName = isBusy ? '$barberName (Sedang Cukur)' : barberName;
                                
                                return DropdownMenuItem<String>(
                                  value: barberId,
                                  child: Text(
                                    displayName,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: isBusy ? Colors.orangeAccent : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedBarberId = value;
                                });
                                _fetchBookedTimesIfNeeded();
                              },
                            ),
                          ),
                        )
                      else
                        Text('Loading barbers...', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariantFull)),
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
                            onTap: () {
                              setState(() {
                                _selectedDateIndex = index;
                              });
                              _fetchBookedTimesIfNeeded();
                            },
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
                  _buildTimeGrid(_morningSlots, bookedTimes),
                  
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
                  _buildTimeGrid(_afternoonSlots, bookedTimes),
                  
                  const SizedBox(height: 32),

                  Text(
                    'EVENING',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildTimeGrid(_eveningSlots, bookedTimes),
                  
                  const SizedBox(height: 32),
                  
                  // Booking for Someone Else Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.charcoalGray,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _isForOther ? AppColors.primary : Colors.transparent),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CheckboxListTile(
                          title: Text(
                            'Booking untuk orang lain?',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          subtitle: Text(
                            'Pilih ini jika Anda memesan untuk teman atau anak Anda.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.onSurfaceVariantFull,
                                ),
                          ),
                          value: _isForOther,
                          activeColor: AppColors.primary,
                          checkColor: Colors.black,
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          onChanged: (value) {
                            setState(() {
                              _isForOther = value ?? false;
                            });
                          },
                        ),
                        if (_isForOther) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _guestNameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Nama Pelanggan (Tamu)',
                              labelStyle: const TextStyle(color: AppColors.onSurfaceVariantFull),
                              filled: true,
                              fillColor: AppColors.matteBlack,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AppColors.primary),
                              ),
                              prefixIcon: const Icon(Icons.person, color: AppColors.onSurfaceVariantFull),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
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
                onPressed: (_selectedTime.isNotEmpty && _selectedBarberId != null && !isLoading) ? _handleBooking : null,
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

  Widget _buildTimeGrid(List<String> slots, List<String> bookedTimes) {
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
        final time = slots[index];
        
        // Cek apakah waktu sudah lewat untuk hari ini
        bool isPastTime = false;
        final dateStr = _dates[_selectedDateIndex]['fullDate']!;
        final now = DateTime.now();
        final todayStr = DateFormat('yyyy-MM-dd').format(now);
        
        if (dateStr == todayStr) {
          final parts = time.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          if (hour < now.hour || (hour == now.hour && minute < now.minute)) {
            isPastTime = true;
          }
        }
        
        final isBooked = bookedTimes.contains(time) || isPastTime;
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

