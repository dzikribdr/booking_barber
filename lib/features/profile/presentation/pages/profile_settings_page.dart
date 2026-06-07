import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:booking_barber/features/auth/presentation/providers/auth_provider.dart';

class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider?>();
    final user = authProvider?.user;
    
    // Real data from Supabase
    final email = user?.email ?? '-';
    final fullName = authProvider?.fullName ?? 'Guest User';
    
    // Derive a simple username from email if available
    final username = user != null ? '@${email.split('@')[0]}' : '-';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Profile & Settings',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              // Profile Header
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.primaryContainer,
                          child: Icon(Icons.person, size: 50, color: AppColors.matteBlack),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.charcoalGray,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, size: 16, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              _buildSectionTitle(context, 'Informasi Akun'),
              _buildInfoTile(context, 'Nama Lengkap', fullName, Icons.person_outline),
              _buildInfoTile(context, 'Username', username, Icons.alternate_email),
              _buildInfoTile(context, 'Email', email, Icons.email_outlined),
              
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Aktivitas'),
              _buildSettingsTile(context, 'Riwayat Booking', Icons.history, onTap: () => context.push('/history?status=all')),
              _buildSettingsTile(context, 'Booking Berlangsung', Icons.pending_actions, onTap: () => context.push('/history?status=ongoing')),
              _buildSettingsTile(context, 'Booking Dibatalkan', Icons.cancel_outlined, onTap: () => context.push('/history?status=cancelled')),
              _buildSettingsTile(context, 'Riwayat Transaksi', Icons.receipt_long_outlined, onTap: () => context.push('/history?status=completed')),
              
              const SizedBox(height: 40),
              
              // Logout Button
              OutlinedButton(
                onPressed: () {
                  context.go('/login');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('LOG OUT'),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.onSurfaceVariantFull,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String title, String value, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: AppColors.charcoalGray,
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariantFull)),
        subtitle: Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: Colors.white)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, String title, IconData icon, {VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: AppColors.charcoalGray,
      child: ListTile(
        onTap: onTap ?? () {},
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariantFull),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
