import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class BarberDashboardPage extends StatelessWidget {
  const BarberDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Active Session',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                letterSpacing: 2,
                color: AppColors.onSurfaceVariantFull,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.primary),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              // Main Scrollable Content
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 140, top: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const [
                      _ActiveCustomerHeader(),
                      SizedBox(height: 48),
                      _PreferencesCard(),
                      SizedBox(height: 32),
                      _InstructionsCard(),
                    ],
                  ),
                ),
              ),
              
              // Absolute Bottom Slide-to-Complete Button Area
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(32.0),
                      decoration: BoxDecoration(
                        color: AppColors.background.withOpacity(0.8),
                        border: const Border(top: BorderSide(color: Colors.white10)),
                      ),
                      child: SafeArea(
                        child: const _SlideToCompleteButton(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ActiveCustomerHeader extends StatelessWidget {
  const _ActiveCustomerHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.charcoalGray,
          child: Icon(Icons.person, size: 50, color: AppColors.onSurfaceVariantFull),
        ),
        const SizedBox(height: 24),
        Text(
          'Alexander Smith',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
                height: 1.1,
              ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Signature Shave + Haircut',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ],
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.charcoalGray,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.favorite, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'CUSTOMER PREFERENCES',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariantFull,
                      letterSpacing: 2,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildPreferenceItem(context, 'Hair Length', 'Medium-Short'),
          const SizedBox(height: 16),
          _buildPreferenceItem(context, 'Fade Type', 'Mid Skin Fade'),
          const SizedBox(height: 16),
          _buildPreferenceItem(context, 'Product', 'Matte Pomade, Low Shine'),
        ],
      ),
    );
  }

  Widget _buildPreferenceItem(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.onSurfaceVariantFull)),
        Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _InstructionsCard extends StatelessWidget {
  const _InstructionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.matteBlack,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notes, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                'SPECIAL NOTES',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariantFull,
                      letterSpacing: 2,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"Please keep the top textured and avoid taking too much off the front fringe. Skin fade on the sides and a hot towel finish."',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.6,
                  fontStyle: FontStyle.italic,
                  color: AppColors.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}

class _SlideToCompleteButton extends StatefulWidget {
  const _SlideToCompleteButton();

  @override
  State<_SlideToCompleteButton> createState() => _SlideToCompleteButtonState();
}

class _SlideToCompleteButtonState extends State<_SlideToCompleteButton> {
  double _dragPosition = 0;
  final double _buttonWidth = 320;
  final double _sliderWidth = 80;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _buttonWidth,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.charcoalGray,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              'SLIDE TO COMPLETE',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
            ),
          ),
          Positioned(
            left: _dragPosition,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _dragPosition += details.delta.dx;
                  if (_dragPosition < 0) _dragPosition = 0;
                  if (_dragPosition > _buttonWidth - _sliderWidth) {
                    _dragPosition = _buttonWidth - _sliderWidth;
                  }
                });
              },
              onHorizontalDragEnd: (details) {
                if (_dragPosition > (_buttonWidth - _sliderWidth) * 0.8) {
                  setState(() {
                    _dragPosition = _buttonWidth - _sliderWidth;
                    // Trigger completion logic here
                  });
                } else {
                  setState(() {
                    _dragPosition = 0;
                  });
                }
              },
              child: Container(
                width: _sliderWidth,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(38),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: const Icon(Icons.check, color: AppColors.matteBlack, size: 36),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
