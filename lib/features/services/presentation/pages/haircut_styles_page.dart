import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/service_provider.dart';
import '../../domain/entities/service_item.dart';
import 'package:booking_barber/features/booking/presentation/providers/booking_provider.dart';

class HaircutStylesPage extends StatelessWidget {
  const HaircutStylesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final serviceProvider = context.watch<ServiceProvider?>();
    final services = serviceProvider?.services.where((s) => s.category == 'Haircut').toList() ?? [];

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
        title: Text('Haircut', style: Theme.of(context).textTheme.headlineMedium),
        centerTitle: true,
      ),
      body: services.isEmpty
          ? const Center(child: Text('No haircut services available', style: TextStyle(color: Colors.white)))
          : ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: services.length,
              itemBuilder: (context, index) {
                return _FullWidthServiceCard(
                  service: services[index],
                );
              },
            ),
    );
  }
}

class _FullWidthServiceCard extends StatelessWidget {
  final ServiceItem service;

  const _FullWidthServiceCard({
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.charcoalGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          // Cinematic Image
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.matteBlack, AppColors.charcoalGray],
              ),
            ),
            child: const Center(child: Icon(Icons.image, size: 60, color: Colors.white12)),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(service.name, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.onSurfaceVariantFull, height: 1.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${service.durationMinutes} Min', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariantFull)),
                        const SizedBox(height: 4),
                        Text('\$${service.price.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        context.read<BookingProvider?>()?.setService(service);
                        context.go('/booking');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: AppColors.matteBlack,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: AppColors.primary, width: 1),
                        ),
                      ),
                      child: const Text('Book This Style', style: TextStyle(fontWeight: FontWeight.bold)),
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
