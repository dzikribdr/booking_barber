import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/service_provider.dart';
import '../../domain/entities/service_item.dart';
import 'package:booking_barber/features/booking/presentation/providers/booking_provider.dart';

class BeardTrimPage extends StatelessWidget {
  const BeardTrimPage({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceProvider = context.watch<ServiceProvider?>();
    final services = serviceProvider?.services.where((s) => s.category == 'Beard Trim').toList() ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withOpacity(0.8),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Beard Trim', style: Theme.of(context).textTheme.headlineMedium),
        centerTitle: true,
      ),
      body: services.isEmpty
          ? const Center(child: Text('No beard trim services available', style: TextStyle(color: Colors.white)))
          : ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: services.length,
              itemBuilder: (context, index) {
                return _BeardServiceCard(
                  service: services[index],
                );
              },
            ),
    );
  }
}

class _BeardServiceCard extends StatelessWidget {
  final ServiceItem service;

  const _BeardServiceCard({
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.charcoalGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.charcoalGray.withOpacity(0.3), AppColors.matteBlack],
              ),
            ),
            child: const Center(child: Icon(Icons.face, size: 50, color: Colors.white12)),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 20)),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariantFull, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${service.durationMinutes} Min', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariantFull)),
                        const SizedBox(height: 4),
                        Text('\$${service.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary, fontSize: 20)),
                      ],
                    ),
                    OutlinedButton(
                      onPressed: () {
                        context.read<BookingProvider?>()?.setService(service);
                        context.go('/booking');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Select'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
