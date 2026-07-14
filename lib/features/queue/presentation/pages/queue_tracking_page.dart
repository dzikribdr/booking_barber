import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/queue_provider.dart';
import '../../../booking/presentation/widgets/rate_barber_dialog.dart';

class QueueTrackingPage extends StatefulWidget {
  const QueueTrackingPage({super.key});

  @override
  State<QueueTrackingPage> createState() => _QueueTrackingPageState();
}

class _QueueTrackingPageState extends State<QueueTrackingPage> {
  QueueProvider? _queueProvider;
  int? _previousQueueNumber;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueProvider = context.read<QueueProvider?>();
      if (_queueProvider != null) {
        _previousQueueNumber = _queueProvider!.currentQueue?['queue_number'] as int?;
        _queueProvider!.addListener(_onQueueChanged);
      }
    });
  }

  void _onQueueChanged() {
    if (!mounted) return;
    final currentQueueNumber = _queueProvider?.currentQueue?['queue_number'] as int?;
    
    if (_previousQueueNumber != null && currentQueueNumber != null) {
      if (currentQueueNumber < _previousQueueNumber!) {
        if (_queueProvider!.lastEventWasCancel) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Antrean anda mundur dari $_previousQueueNumber menjadi $currentQueueNumber karena ada pembatalan.',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Antrean anda mundur dari $_previousQueueNumber menjadi $currentQueueNumber. Giliran Anda semakin dekat!',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    }
    _previousQueueNumber = currentQueueNumber;
  }

  @override
  void dispose() {
    _queueProvider?.removeListener(_onQueueChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final queueProvider = context.watch<QueueProvider?>();
    
    // Determine if there is an active queue
    final hasBooking = queueProvider?.hasActiveQueue ?? false;
    final currentQueue = queueProvider?.currentQueue;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Live Queue Status',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: hasBooking && currentQueue != null 
                      ? _buildActiveQueueUI(currentQueue) 
                      : _buildEmptyStateUI(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyStateUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 60),
        Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: AppColors.charcoalGray,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.hourglass_empty,
            size: 80,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 40),
        Text(
          'Tidak Ada Antrean',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Anda belum memesan layanan apapun hari ini. Silakan booking layanan untuk mendapatkan nomor antrean.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.onSurfaceVariantFull,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => context.push('/services'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Text(
              'SILAHKAN BOOKING TERLEBIH DAHULU',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveQueueUI(Map<String, dynamic> queueData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _CircularProgressTimer(
          createdAt: queueData['created_at'] as String?,
          estimatedWaitMinutes: queueData['estimated_wait_minutes'] as int? ?? 15,
          bookingId: queueData['booking_id'] as String?,
          barberId: queueData['barber_id'] as String?,
          barberName: queueData['barber_name'] as String?,
        ),
        const SizedBox(height: 48),
        _CurrentServingStatus(
          queueNumber: queueData['queue_number'] as int? ?? 0,
          currentlyServing: queueData['currently_serving'] as int? ?? 0,
        ),
        const SizedBox(height: 48),
        _GlassBookingDetailsCard(
          barberName: queueData['barber_name'] as String? ?? 'Unknown Barber',
          serviceName: queueData['service_name'] as String? ?? 'Unknown Service',
        ),
        const SizedBox(height: 40),
        _CancelButton(onCancel: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.charcoalGray,
              title: const Text('Batalkan Antrean?', style: TextStyle(color: Colors.white)),
              content: const Text('Apakah Anda yakin ingin membatalkan antrean ini? Tindakan ini tidak dapat dibatalkan.', style: TextStyle(color: AppColors.onSurfaceVariantFull)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Tidak', style: TextStyle(color: Colors.white70)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
          
          if (!mounted) return;

          if (confirm == true) {
            final provider = context.read<QueueProvider?>();
            if (provider != null) {
              await provider.cancelQueue();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Antrean berhasil dibatalkan'), backgroundColor: Colors.green),
                );
              }
            }
          }
        }),
      ],
    );
  }
}

class _CircularProgressTimer extends StatefulWidget {
  final String? createdAt;
  final int estimatedWaitMinutes;
  final String? bookingId;
  final String? barberId;
  final String? barberName;
  const _CircularProgressTimer({
    required this.createdAt, 
    required this.estimatedWaitMinutes,
    this.bookingId,
    this.barberId,
    this.barberName,
  });

  @override
  State<_CircularProgressTimer> createState() => _CircularProgressTimerState();
}

class _CircularProgressTimerState extends State<_CircularProgressTimer> {
  int _minutesLeft = 0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    // In a real app you'd use a Timer to update this periodically,
    // but for simplicity we calculate it on build or we can do a delayed loop
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _calculateTimeLeft();
        });
        _startTimer();
      }
    });
  }

  int _lastKnownProviderWait = -1;
  DateTime? _lastSyncTime;

  void _calculateTimeLeft() {
    if (widget.estimatedWaitMinutes != _lastKnownProviderWait) {
      // Provider gave us a new exact wait time based on queue changes
      _lastKnownProviderWait = widget.estimatedWaitMinutes;
      _lastSyncTime = DateTime.now();
      _minutesLeft = widget.estimatedWaitMinutes;
    } else if (_lastSyncTime != null) {
      // Tick down locally based on elapsed time since last sync
      final elapsedMinutes = DateTime.now().difference(_lastSyncTime!).inMinutes;
      _minutesLeft = widget.estimatedWaitMinutes - elapsedMinutes;
    }

    if (_minutesLeft < 0) _minutesLeft = 0;

    if (_minutesLeft <= 0 && !_isFinished) {
      _isFinished = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFinishedDialog();
      });
    }
  }

  void _showFinishedDialog() {
    final provider = context.read<QueueProvider?>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.charcoalGray,
        title: const Text('Selesai', style: TextStyle(color: Colors.white)),
        content: const Text('Antrean Anda sudah selesai. Terima kasih!', style: TextStyle(color: AppColors.onSurfaceVariantFull)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              provider?.completeQueue();
              if (widget.bookingId != null && widget.barberId != null && widget.barberName != null) {
                showDialog(
                  context: context,
                  builder: (_) => RateBarberDialog(
                    bookingId: widget.bookingId!,
                    barberId: widget.barberId!,
                    barberName: widget.barberName!,
                  ),
                );
              }
            },
            child: const Text('OK', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Assuming max wait time is 60 mins for the progress circle
    final progress = _minutesLeft > 0 ? _minutesLeft / 60.0 : 0.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 280,
          height: 280,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            backgroundColor: AppColors.charcoalGray,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            strokeCap: StrokeCap.round,
          ),
        ),
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.matteBlack,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 50,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'YOUR TURN IN',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.onSurfaceVariantFull,
                      letterSpacing: 2.5,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '$_minutesLeft',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 84,
                      height: 1.0,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              Text(
                'MINUTES',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.onSurfaceVariantFull,
                      letterSpacing: 2,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CurrentServingStatus extends StatelessWidget {
  final int queueNumber;
  final int currentlyServing;
  const _CurrentServingStatus({required this.queueNumber, required this.currentlyServing});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'CURRENTLY SERVING',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariantFull,
                letterSpacing: 2,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '#',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.onSurfaceVariantFull,
                    fontSize: 24,
                  ),
            ),
            Text(
              '$currentlyServing', 
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: AppColors.onSurface,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.charcoalGray,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Your Queue Number: #$queueNumber',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}

class _GlassBookingDetailsCard extends StatelessWidget {
  final String barberName;
  final String serviceName;

  const _GlassBookingDetailsCard({
    required this.barberName,
    required this.serviceName,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.charcoalGray.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDetailItem(context, 'Barber', barberName, Icons.person),
              Container(width: 1, height: 40, color: AppColors.outlineVariant),
              _buildDetailItem(context, 'Service', serviceName, Icons.content_cut),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariantFull)),
          ],
        ),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _CancelButton extends StatelessWidget {
  final VoidCallback onCancel;
  
  const _CancelButton({required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onCancel,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.onSurfaceVariantFull,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: const Text(
        'Cancel Booking',
        style: TextStyle(
          decoration: TextDecoration.underline,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
