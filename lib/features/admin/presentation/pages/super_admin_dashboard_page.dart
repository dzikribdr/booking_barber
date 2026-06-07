import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SuperAdminDashboardPage extends StatelessWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Operations Center',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        actions: [
          const CircleAvatar(
            backgroundColor: AppColors.primaryContainer,
            child: Icon(Icons.admin_panel_settings, color: AppColors.matteBlack),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth >= 768;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(context, isTablet),
                const SizedBox(height: 40),
                Text('Monthly Revenue Trends', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                const _RevenueTrendChart(),
                const SizedBox(height: 40),
                Text('Quick Actions', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 16),
                _buildQuickActionsGrid(context, isTablet),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, bool isTablet) {
    if (isTablet) {
      return Row(
        children: const [
          Expanded(child: _SummaryCard(title: 'Daily Revenue', value: '\$4,250.00', trend: '+12.5%', isPositive: true)),
          SizedBox(width: 24),
          Expanded(child: _SummaryCard(title: 'Completed Bookings', value: '184', trend: '+5.2%', isPositive: true)),
        ],
      );
    }
    return Column(
      children: const [
        _SummaryCard(title: 'Daily Revenue', value: '\$4,250.00', trend: '+12.5%', isPositive: true),
        SizedBox(height: 16),
        _SummaryCard(title: 'Completed Bookings', value: '184', trend: '+5.2%', isPositive: true),
      ],
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context, bool isTablet) {
    return GridView.count(
      crossAxisCount: isTablet ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: const [
        _ActionShortcut(title: 'Manage Staff', icon: Icons.people_outline),
        _ActionShortcut(title: 'Services & Pricing', icon: Icons.cut_outlined),
        _ActionShortcut(title: 'Financial Reports', icon: Icons.analytics_outlined),
        _ActionShortcut(title: 'Operational Settings', icon: Icons.settings_outlined),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final bool isPositive;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.charcoalGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.onSurfaceVariantFull)),
          const SizedBox(height: 16),
          Text(value, style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? Colors.green : AppColors.error,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                trend,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: isPositive ? Colors.green : AppColors.error,
                    ),
              ),
              const SizedBox(width: 8),
              Text('vs last week', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariantFull)),
            ],
          ),
        ],
      ),
    );
  }
}

class _RevenueTrendChart extends StatelessWidget {
  const _RevenueTrendChart();

  @override
  Widget build(BuildContext context) {
    // Custom simulated trend chart using vertical bars for a clean, dependency-free visualization
    final List<double> dataPoints = [0.3, 0.5, 0.4, 0.7, 0.6, 0.9, 0.8];
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      height: 250,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.charcoalGray,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(dataPoints.length, (index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 24,
                height: 150 * dataPoints[index],
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                days[index],
                style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.onSurfaceVariantFull),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _ActionShortcut extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ActionShortcut({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.matteBlack,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.charcoalGray,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}
