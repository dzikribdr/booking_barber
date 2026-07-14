import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/booking_provider.dart';

class BarberReviewsPage extends StatefulWidget {
  final Map<String, dynamic> barberData;

  const BarberReviewsPage({super.key, required this.barberData});

  @override
  State<BarberReviewsPage> createState() => _BarberReviewsPageState();
}

class _BarberReviewsPageState extends State<BarberReviewsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final barberId = widget.barberData['id'];
      if (barberId != null) {
        context.read<BookingProvider?>()?.fetchBarberReviews(barberId.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final barberName = widget.barberData['name'] ?? 'Barber';
    final averageRating = (widget.barberData['rating'] ?? 0.0).toDouble();
    final totalReviews = widget.barberData['reviews_count'] ?? 0;
    
    final bookingProvider = context.watch<BookingProvider?>();
    final isLoading = bookingProvider?.isLoadingReviews ?? true;
    final reviews = bookingProvider?.barberReviews ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background.withValues(alpha: 0.8),
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
        title: const Text('Barber Reviews', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        centerTitle: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(24.0),
              margin: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.charcoalGray,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.matteBlack,
                    child: Icon(Icons.person, size: 40, color: AppColors.onSurfaceVariantFull),
                  ),
                  const SizedBox(height: 16),
                  Text(barberName, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '($totalReviews Reviews)',
                        style: const TextStyle(color: AppColors.onSurfaceVariantFull, fontSize: 16),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          if (isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (reviews.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No reviews yet for this barber.', style: TextStyle(color: AppColors.onSurfaceVariantFull)),
                    const SizedBox(height: 16),
                    if (bookingProvider?.lastReviewError != null) ...[
                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
                      const SizedBox(height: 8),
                      const Text('Terjadi error saat mengambil data:', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('${bookingProvider?.lastReviewError}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                      ),
                    ] else ...[
                      Text('Debug ID: ${widget.barberData['id']}', style: const TextStyle(color: Colors.white24, fontSize: 10)),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        child: Text('Jika seharusnya ada review tapi kosong, berarti Anda belum menjalankan perintah SQL RLS di Supabase!', textAlign: TextAlign.center, style: TextStyle(color: Colors.redAccent, fontSize: 12)),
                      )
                    ]
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final review = reviews[index];
                    final rating = (review['rating'] ?? 0.0).toDouble();
                    final reviewText = review['review_text'] as String?;
                    final dateStr = review['created_at'] as String?;
                    
                    // Supabase returns related profile inside 'profiles' key
                    final profiles = review['profiles'] as Map<String, dynamic>?;
                    final customerName = profiles?['full_name'] ?? 'Anonymous Customer';

                    String displayDate = '';
                    if (dateStr != null) {
                      final dt = DateTime.tryParse(dateStr);
                      if (dt != null) {
                        displayDate = '${dt.day}/${dt.month}/${dt.year}';
                      }
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.charcoalGray,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(customerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              if (displayDate.isNotEmpty)
                                Text(displayDate, style: const TextStyle(color: AppColors.onSurfaceVariantFull, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: List.generate(5, (starIndex) {
                              return Icon(
                                starIndex < rating ? Icons.star : Icons.star_border,
                                color: AppColors.primary,
                                size: 16,
                              );
                            }),
                          ),
                          if (reviewText != null && reviewText.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              '"$reviewText"',
                              style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, height: 1.5),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                  childCount: reviews.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
