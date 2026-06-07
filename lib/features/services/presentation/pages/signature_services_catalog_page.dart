import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/service_provider.dart';
import '../../domain/entities/service_item.dart';
import 'package:booking_barber/features/booking/presentation/providers/booking_provider.dart';
class SignatureServicesCatalogPage extends StatefulWidget {
  const SignatureServicesCatalogPage({super.key});

  @override
  State<SignatureServicesCatalogPage> createState() => _SignatureServicesCatalogPageState();
}

class _SignatureServicesCatalogPageState extends State<SignatureServicesCatalogPage> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = ['All', 'Haircut', 'Shave', 'Beard Trim', 'Treatment'];

  @override
  Widget build(BuildContext context) {
    final serviceProvider = context.watch<ServiceProvider?>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // 1. Sleek Top App Bar with Glassmorphism
          SliverAppBar(
            backgroundColor: AppColors.background.withOpacity(0.9),
            pinned: true,
            elevation: 0,
            flexibleSpace: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),
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
              'Signature Services',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            centerTitle: true,
          ),

          // 2. Horizontally Scrolling Category Filter Bar
          SliverToBoxAdapter(
            child: SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final isSelected = _selectedCategoryIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: InkWell(
                      onTap: () => setState(() => _selectedCategoryIndex = index),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.charcoalGray,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : AppColors.outlineVariant,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _categories[index],
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: isSelected ? Colors.black : Colors.white70,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 3. Dynamic Service List
          if (serviceProvider == null || serviceProvider.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else
            Builder(
              builder: (context) {
                final filteredServices = serviceProvider.services.where((s) {
                  if (_categories[_selectedCategoryIndex] == 'All') return true;
                  return s.category == _categories[_selectedCategoryIndex];
                }).toList();

                if (filteredServices.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No services found.',
                        style: TextStyle(color: AppColors.onSurfaceVariantFull),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final service = filteredServices[index];
                        return _buildServiceCard(context, service);
                      },
                      childCount: filteredServices.length,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, ServiceItem service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.charcoalGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image / Header area (Placeholder)
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.matteBlack,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1599351431202-1e0f0137899a?auto=format&fit=crop&q=80'),
                fit: BoxFit.cover,
                opacity: 0.5,
              ),
            ),
            padding: const EdgeInsets.all(16),
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                service.category,
                style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          
          // Content Area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      service.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '\$${service.price.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  service.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariantFull,
                        height: 1.5,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: AppColors.onSurfaceVariantFull),
                    const SizedBox(width: 4),
                    Text(
                      '${service.durationMinutes} mins',
                      style: const TextStyle(color: AppColors.onSurfaceVariantFull, fontSize: 14),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          // Save selected service
                          context.read<BookingProvider?>()?.setService(service);
                          
                          // Show Pop Up
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppColors.charcoalGray,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: AppColors.primary),
                                  SizedBox(width: 8),
                                  Text('Berhasil', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              content: const Text(
                                'Treatment berhasil ditambahkan, silahkan lanjut pilih jadwal booking.',
                                style: TextStyle(color: AppColors.onSurfaceVariantFull),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Close dialog
                                    context.go('/booking'); // Go to booking
                                  },
                                  child: const Text('Lanjut', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        child: const Text('Book', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
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
