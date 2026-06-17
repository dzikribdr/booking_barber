import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/booking_provider.dart';

class BookingHistoryPage extends StatefulWidget {
  final String? statusFilter;
  const BookingHistoryPage({super.key, this.statusFilter});

  @override
  State<BookingHistoryPage> createState() => _BookingHistoryPageState();
}

class _BookingHistoryPageState extends State<BookingHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingProvider?>()?.fetchBookingHistory(statusFilter: widget.statusFilter);
    });
  }

  String _getAppbarTitle() {
    switch (widget.statusFilter) {
      case 'ongoing':
        return 'Booking Berlangsung';
      case 'cancelled':
        return 'Booking Dibatalkan';
      case 'transaction':
        return 'Riwayat Transaksi';
      case 'completed':
        return 'Riwayat Selesai';
      default:
        return 'Riwayat Booking';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider?>();
    final history = provider?.bookingHistory ?? [];
    final isLoading = provider?.isLoading ?? false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _getAppbarTitle(),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 768;
          
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isTablet ? 800 : 500),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : history.isEmpty
                      ? Center(
                          child: Text(
                            'Tidak ada data booking',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariantFull),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(24.0),
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            final booking = history[index];
                            final service = booking['services'] as Map<String, dynamic>?;
                            
                            final serviceName = service?['name'] ?? 'Unknown Service';
                            final price = service?['price'] ?? 0;
                            final status = booking['status'] ?? 'unknown';
                            final isTransactionView = widget.statusFilter == 'transaction';
                            final paymentMethod = booking['payment_method'] ?? 'Cash/QRIS';
                            
                            // Format date
                            final bookingTimeStr = booking['booking_time'] as String?;
                            String dateStr = '-';
                            String timeStr = '-';
                            if (bookingTimeStr != null) {
                              try {
                                final dateTime = DateTime.parse(bookingTimeStr).toLocal();
                                dateStr = DateFormat('MMM dd, yyyy').format(dateTime);
                                timeStr = DateFormat('hh:mm a').format(dateTime);
                              } catch (e) {
                                // ignore
                              }
                            }

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: _HistoryCard(
                                service: serviceName,
                                barber: 'Any Barber', // Placeholder as barber_id is not yet implemented
                                date: dateStr,
                                time: timeStr,
                                price: '\$${price.toStringAsFixed(2)}',
                                status: status.toString().toUpperCase(),
                                paymentMethod: paymentMethod,
                                isTransactionView: isTransactionView,
                              ),
                            );
                          },
                        ),
            ),
          );
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String service;
  final String barber;
  final String date;
  final String time;
  final String price;
  final String status;
  final String paymentMethod;
  final bool isTransactionView;

  const _HistoryCard({
    required this.service,
    required this.barber,
    required this.date,
    required this.time,
    required this.price,
    required this.status,
    this.paymentMethod = 'Cash/QRIS',
    this.isTransactionView = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUpcoming = status == 'PENDING' || status == 'CONFIRMED';
    final isCancelled = status == 'CANCELLED';
    
    Color statusColor = AppColors.onSurfaceVariantFull;
    if (isUpcoming) statusColor = AppColors.primary;
    if (isCancelled) statusColor = Colors.redAccent;
    if (status == 'COMPLETED') statusColor = Colors.green;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurfaceVariantFull,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: statusColor,
                    ),
                  ),
                  child: Text(
                    status,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(service, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.person, size: 16, color: AppColors.onSurfaceVariantFull),
                const SizedBox(width: 8),
                Text('Barber: $barber', style: Theme.of(context).textTheme.bodyMedium),
                const Spacer(),
                const Icon(Icons.access_time, size: 16, color: AppColors.onSurfaceVariantFull),
                const SizedBox(width: 8),
                Text(time, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(color: AppColors.outlineVariant, height: 1),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Harga Total', style: Theme.of(context).textTheme.bodyMedium),
                Text(price, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 18, color: AppColors.primary)),
              ],
            ),
            if (isTransactionView) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Metode Pembayaran', style: Theme.of(context).textTheme.bodyMedium),
                  Text(paymentMethod, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariantFull)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
