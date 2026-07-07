import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../../queue/presentation/providers/queue_provider.dart';
import '../../../../features/profile/presentation/providers/profile_provider.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Checkout',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 120.0, top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _InvoiceSummaryCard(),
                  SizedBox(height: 24),
                  _CountdownTimer(),
                  SizedBox(height: 40),
                  _PaymentMethodsList(),
                ],
              ),
            ),
          ),
          
          // Sticky Solid Gold Pay Now Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: AppColors.charcoalGray.withValues(alpha: 0.8),
                    border: const Border(top: BorderSide(color: Colors.white10)),
                  ),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement actual payment logic here
                          context.read<QueueProvider?>()?.fetchQueue();
                          context.go('/queue');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.matteBlack,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'PAY Rp 65.000 NOW',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvoiceSummaryCard extends StatelessWidget {
  const _InvoiceSummaryCard();

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider?>();
    final isSilentMode = profileProvider?.profile?.isSilentMode ?? false;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.charcoalGray,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Invoice Summary', style: Theme.of(context).textTheme.headlineMedium),
              const Icon(Icons.receipt_long, color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 24),
          _buildInvoiceLine(context, 'Signature Shave', 'Rp 35.000'),
          const SizedBox(height: 12),
          _buildInvoiceLine(context, 'Haircut (Skin Fade)', 'Rp 30.000'),
          
          if (isSilentMode) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.volume_off, color: AppColors.primary, size: 16),
                  const SizedBox(width: 8),
                  Text('Silent Mode Requested', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary)),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          Container(height: 1, color: AppColors.outlineVariant),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount', style: Theme.of(context).textTheme.headlineMedium),
              Text('Rp 65.000', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceLine(BuildContext context, String description, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariantFull)),
        Text(price, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _CountdownTimer extends StatelessWidget {
  const _CountdownTimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            'Complete payment within ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary),
          ),
          Text(
            '14:59',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodsList extends StatefulWidget {
  const _PaymentMethodsList();

  @override
  State<_PaymentMethodsList> createState() => _PaymentMethodsListState();
}

class _PaymentMethodsListState extends State<_PaymentMethodsList> {
  String _selectedMethod = 'qris';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Payment Method', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        _buildPaymentOption('qris', 'QRIS', 'Scan from any E-Wallet or Mobile Banking', Icons.qr_code_2),
        _buildPaymentOption('gopay', 'GoPay', 'Pay seamlessly with Gojek', Icons.account_balance_wallet),
        _buildPaymentOption('ovo', 'OVO', 'Instant payment via OVO app', Icons.account_balance_wallet),
        _buildPaymentOption('bca', 'BCA Virtual Account', 'Automatic verification', Icons.account_balance),
        _buildPaymentOption('cash', 'Bayar di Tempat', 'Pay with cash at the barbershop', Icons.payments),
      ],
    );
  }

  Widget _buildPaymentOption(String id, String title, String subtitle, IconData fallbackIcon) {
    final isSelected = _selectedMethod == id;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => setState(() => _selectedMethod = id),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.charcoalGray,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.matteBlack,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(fallbackIcon, color: AppColors.onSurface, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.labelMedium),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.onSurfaceVariantFull),
                    ),
                  ],
                ),
              ),
              if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
