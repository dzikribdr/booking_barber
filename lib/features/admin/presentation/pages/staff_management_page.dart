import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_provider.dart';
import '../widgets/barber_dialog.dart';

class StaffManagementPage extends StatelessWidget {
  const StaffManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Staff', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariantFull),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => BarberDialog.show(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: AppColors.matteBlack),
        label: const Text('Add Staff', style: TextStyle(color: AppColors.matteBlack, fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: provider.barbers.length,
        itemBuilder: (context, index) {
          final barber = provider.barbers[index];
          return Card(
            color: AppColors.charcoalGray,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryContainer,
                backgroundImage: barber.photoUrl != null ? NetworkImage(barber.photoUrl!) : null,
                child: barber.photoUrl == null ? const Icon(Icons.person, color: AppColors.matteBlack) : null,
              ),
              title: Text(barber.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: Text('${barber.startTime} - ${barber.endTime} | ${barber.status}', style: const TextStyle(color: AppColors.onSurfaceVariantFull)),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primary),
                onPressed: () {
                  BarberDialog.show(context, barber: barber);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
