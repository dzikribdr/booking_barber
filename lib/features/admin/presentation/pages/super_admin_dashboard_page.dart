import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/admin_provider.dart';
import 'staff_management_page.dart';
import 'service_management_page.dart';
import '../../../booking/presentation/widgets/walk_in_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/export_utils.dart';

class SuperAdminDashboardPage extends StatefulWidget {
  const SuperAdminDashboardPage({super.key});

  @override
  State<SuperAdminDashboardPage> createState() => _SuperAdminDashboardPageState();
}

class _SuperAdminDashboardPageState extends State<SuperAdminDashboardPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().fetchAllData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const _DashboardTab(),
      const StaffManagementPage(),
      const ServiceManagementPage(),
      const _BookingManagementTab(),
      const _ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.charcoalGray,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.onSurfaceVariantFull),
          onPressed: () {},
        ),
        title: const Text(
          'BARBER 69',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
            ),
          ),
        ],
      ),
      body: Consumer<AdminProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.barbers.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          return pages[_currentIndex];
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: AppColors.matteBlack,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariantFull,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Staff'),
          BottomNavigationBarItem(icon: Icon(Icons.cut), label: 'Services'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ==========================================
// 1. DASHBOARD TAB
// ==========================================
class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  String _selectedFilter = 'Today';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text('Overview', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Today\'s metrics and recent activity across all locations.', style: TextStyle(color: AppColors.onSurfaceVariantFull)),
          const SizedBox(height: 16),
          
          // Time Filter Toggle & Export
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
            decoration: BoxDecoration(
              color: AppColors.charcoalGray,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: ['Today', '7D', '30D'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.surfaceBright : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.onSurfaceVariantFull,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                ),
                onPressed: () => _showExportDialog(context, provider),
                icon: const Icon(Icons.download, size: 18),
                label: const Text('Export', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Metrics Stack
          _MetricCard(
            title: 'TOTAL REVENUE',
            value: 'Rp ${provider.getRevenue(_selectedFilter).toStringAsFixed(0)}',
            trendLabel: '+ 0%',
            trendIsPositive: true,
            isNeutral: true,
            icon: Icons.payments_outlined,
          ),
          const SizedBox(height: 16),
          _MetricCard(
            title: 'BOOKINGS',
            value: '${provider.getBookingsCount(_selectedFilter)}',
            trendLabel: '+ 0%',
            trendIsPositive: true,
            isNeutral: true,
            icon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 16),
          _MetricCard(
            title: 'AVG TICKET',
            value: 'Rp ${provider.getBookingsCount(_selectedFilter) > 0 ? (provider.getRevenue(_selectedFilter) / provider.getBookingsCount(_selectedFilter)).toStringAsFixed(0) : '0'}',
            trendLabel: '- 0%',
            trendIsPositive: false,
            isNeutral: true,
            icon: Icons.receipt_long_outlined,
          ),
          const SizedBox(height: 16),
          
          // Active Staff Metric
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.charcoalGray,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ACTIVE STAFF', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1)),
                    const Icon(Icons.people_alt_outlined, color: AppColors.primary, size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${provider.activeStaff}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6.0),
                      child: Text('/24', style: TextStyle(color: AppColors.onSurfaceVariantFull, fontSize: 16)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: provider.activeStaff / 24.0,
                    backgroundColor: AppColors.surfaceBright,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Revenue Trend Placeholder
          const Text('Revenue Trend', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.charcoalGray,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.show_chart, color: AppColors.primary, size: 48),
                  const SizedBox(height: 8),
                  Text('Chart Data Placeholder', style: TextStyle(color: AppColors.primary.withValues(alpha: 0.5))),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Live Queue
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Live Queue', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
              )
            ],
          ),
          const SizedBox(height: 16),
          _LiveQueueList(provider),
          const SizedBox(height: 24),

          // Quick Actions
          const Text('Quick Actions', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _QuickActionCard(
                icon: Icons.edit_calendar, 
                label: 'New Booking', 
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const WalkInDialog(),
                  ).then((success) {
                    if (!context.mounted) return;
                    if (success == true) {
                      context.read<AdminProvider>().fetchAllData(); // refresh data
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Berhasil menambahkan pesanan!'), backgroundColor: Colors.green),
                      );
                    }
                  });
                }
              ),
              _QuickActionCard(
                icon: Icons.badge_outlined, 
                label: 'Manage Staff', 
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffManagementPage()));
                }
              ),
              _QuickActionCard(
                icon: Icons.inventory_2_outlined, 
                label: 'Services', 
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceManagementPage()));
                }
              ),
              _QuickActionCard(icon: Icons.tune, label: 'System Config', onTap: () {}),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, AdminProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.charcoalGray,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Export as PDF', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _exportData(context, provider, isPdf: true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text('Export as Excel', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _exportData(context, provider, isPdf: false);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _exportData(BuildContext context, AdminProvider provider, {required bool isPdf}) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Generating report...')));
      
      final now = DateTime.now();
      DateTime startDate;
      if (_selectedFilter == '7D') {
        startDate = now.subtract(const Duration(days: 7));
      } else if (_selectedFilter == '30D') {
        startDate = now.subtract(const Duration(days: 30));
      } else {
        startDate = DateTime(now.year, now.month, now.day);
      }
      
      final filteredBookings = provider.bookings.where((b) {
        if (b.status == 'cancelled') return false;
        if (_selectedFilter == 'Today') {
          return b.bookingDate.year == now.year &&
                 b.bookingDate.month == now.month &&
                 b.bookingDate.day == now.day;
        }
        return b.bookingDate.isAfter(startDate) || b.bookingDate.isAtSameMomentAs(startDate);
      }).toList();

      if (isPdf) {
        await ExportUtils.exportToPdf(filteredBookings, _selectedFilter);
      } else {
        await ExportUtils.exportToExcel(filteredBookings, _selectedFilter);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e'), backgroundColor: Colors.red));
      }
    }
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String trendLabel;
  final bool trendIsPositive;
  final bool isNeutral;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.trendLabel,
    required this.trendIsPositive,
    this.isNeutral = false,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.charcoalGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: AppColors.onSurfaceVariantFull, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1)),
              Icon(icon, color: AppColors.primary, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isNeutral ? AppColors.surfaceBright : (trendIsPositive ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    if (!isNeutral) Icon(trendIsPositive ? Icons.trending_up : Icons.trending_down, 
                      color: trendIsPositive ? Colors.green : Colors.red, size: 14),
                    if (!isNeutral) const SizedBox(width: 4),
                    Text(trendLabel, style: TextStyle(
                      color: isNeutral ? AppColors.onSurfaceVariantFull : (trendIsPositive ? Colors.green : Colors.red), 
                      fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Text('vs yesterday', style: TextStyle(color: AppColors.onSurfaceVariantFull, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveQueueList extends StatelessWidget {
  final AdminProvider provider;
  const _LiveQueueList(this.provider);

  @override
  Widget build(BuildContext context) {
    // Filter bookings for today that are not completed or cancelled
    final today = DateTime.now();
    final liveBookings = provider.bookings.where((b) => 
      b.status != 'completed' && b.status != 'cancelled' &&
      b.bookingDate.year == today.year &&
      b.bookingDate.month == today.month &&
      b.bookingDate.day == today.day
    ).toList();

    // Sort by time
    liveBookings.sort((a, b) => a.bookingDate.compareTo(b.bookingDate));

    if (liveBookings.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No active queue for today.', style: TextStyle(color: AppColors.onSurfaceVariantFull)),
        )
      );
    }

    return Column(
      children: liveBookings.map((b) {
        final name = b.customerName ?? 'Walk-in';
        final initials = name.split(' ').take(2).map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').join();
        final serviceName = b.service?.name ?? 'Service';
        final barberName = b.barber?.name ?? 'Any Barber';
        final timeLabel = '${b.bookingDate.hour.toString().padLeft(2, '0')}:${b.bookingDate.minute.toString().padLeft(2, '0')}';
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: _QueueItem(
            initials: initials.isNotEmpty ? initials : 'WI',
            name: name,
            service: '$serviceName w/ $barberName',
            status: b.status == 'on_going' ? 'In Chair' : (b.status == 'confirmed' ? 'Next' : 'Waiting'),
            timeLabel: timeLabel,
            isActive: b.status == 'on_going',
          ),
        );
      }).toList(),
    );
  }
}

class _QueueItem extends StatelessWidget {
  final String initials;
  final String name;
  final String service;
  final String status;
  final String timeLabel;
  final bool isActive;

  const _QueueItem({
    required this.initials,
    required this.name,
    required this.service,
    required this.status,
    required this.timeLabel,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.charcoalGray,
        borderRadius: BorderRadius.circular(12),
        border: isActive ? const Border(left: BorderSide(color: AppColors.primary, width: 3)) : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceBright,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Center(child: Text(initials, style: const TextStyle(color: AppColors.onSurfaceVariantFull, fontWeight: FontWeight.bold))),
        ),
        title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(service, style: const TextStyle(color: AppColors.onSurfaceVariantFull, fontSize: 12)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(status, style: TextStyle(color: isActive ? AppColors.primary : Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(timeLabel, style: const TextStyle(color: AppColors.onSurfaceVariantFull, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.charcoalGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineVariant),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.onSurfaceVariantFull, size: 28),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 4. BOOKING MANAGEMENT TAB
// ==========================================
class _BookingManagementTab extends StatelessWidget {
  const _BookingManagementTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: provider.bookings.length,
      itemBuilder: (context, index) {
        final booking = provider.bookings[index];
        return Card(
          color: AppColors.charcoalGray,
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text('Booking #${booking.id.substring(0, 8)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('Status: ${booking.status.toUpperCase()} | Date: ${booking.bookingDate.toLocal().toString().split(' ')[0]}', 
              style: TextStyle(color: _getStatusColor(booking.status))
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatusButton(context, provider, booking.id, 'confirmed', 'Confirm'),
                    _buildStatusButton(context, provider, booking.id, 'on_going', 'On Going'),
                    _buildStatusButton(context, provider, booking.id, 'completed', 'Complete'),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusButton(BuildContext context, AdminProvider provider, String bookingId, String status, String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.matteBlack,
        side: const BorderSide(color: AppColors.primary),
      ),
      onPressed: () => provider.updateBookingStatus(bookingId, status),
      child: Text(label, style: const TextStyle(color: AppColors.primary)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'confirmed': return Colors.blue;
      case 'on_going': return Colors.purple;
      case 'completed': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return AppColors.onSurfaceVariantFull;
    }
  }
}

// ==========================================
// 5. PROFILE TAB
// ==========================================
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 48),
          const CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
          ),
          const SizedBox(height: 24),
          Text(
            authProvider.fullName ?? 'Admin',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            authProvider.user?.email ?? 'admin@barber69.com',
            style: const TextStyle(color: AppColors.onSurfaceVariantFull),
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                await authProvider.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Log Out',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

