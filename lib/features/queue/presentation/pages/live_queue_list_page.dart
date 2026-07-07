import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/queue_provider.dart';

class LiveQueueListPage extends StatelessWidget {
  const LiveQueueListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final queueProvider = context.watch<QueueProvider?>();
    final globalQueue = queueProvider?.globalQueue ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Daftar Antrean',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: true,
      ),
      body: globalQueue.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 80, color: AppColors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada antrean.',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.onSurfaceVariantFull),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              backgroundColor: AppColors.charcoalGray,
              onRefresh: () async {
                await queueProvider?.fetchQueue();
              },
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                itemCount: globalQueue.length,
                itemBuilder: (context, index) {
                  final booking = globalQueue[index];
                  
                  final barberName = booking['barbers']?['name'] ?? '-';
                  final serviceName = booking['services']?['name'] ?? '-';
                  final status = booking['status'] ?? '-';
                  
                  return Card(
                    color: AppColors.charcoalGray,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: status == 'in-progress' ? Colors.green.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.2),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: status == 'in-progress' ? Colors.green : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        'Kustomer #${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Barber: $barberName', style: const TextStyle(color: AppColors.onSurfaceVariantFull)),
                            Text('Layanan: $serviceName', style: const TextStyle(color: AppColors.onSurfaceVariantFull)),
                            if (status == 'in-progress')
                               Padding(
                                 padding: const EdgeInsets.only(top: 8.0),
                                 child: Text('SEDANG DILAYANI', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                               )
                          ],
                        ),
                      ),
                      trailing: const Icon(Icons.people, color: AppColors.onSurfaceVariantFull, size: 20),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
