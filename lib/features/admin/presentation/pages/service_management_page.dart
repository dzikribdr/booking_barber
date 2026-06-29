import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_provider.dart';
import '../widgets/service_dialog.dart';

class ServiceManagementPage extends StatelessWidget {
  const ServiceManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Services', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariantFull),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ServiceDialog.show(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.matteBlack),
        label: const Text('Add Service', style: TextStyle(color: AppColors.matteBlack, fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: provider.services.length,
        itemBuilder: (context, index) {
          final service = provider.services[index];
          return Card(
            color: AppColors.charcoalGray,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                child: Icon(Icons.cut, color: AppColors.matteBlack),
              ),
              title: Text(service.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text('${service.durationMinutes} mins | \$${service.price}', style: const TextStyle(color: AppColors.onSurfaceVariantFull)),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primary),
                onPressed: () {
                  ServiceDialog.show(context, service: service);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
