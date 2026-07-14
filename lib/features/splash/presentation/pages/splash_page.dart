import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..forward();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final authProvider = context.read<AuthProvider>();
        if (authProvider.isAuthenticated) {
          if (authProvider.role == 'admin' || authProvider.role == 'super_admin') {
            context.go('/admin-dashboard');
          } else {
            context.go('/home');
          }
        } else {
          context.go('/login');
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Placeholder for Minimalist Logo
              Icon(
                Icons.content_cut,
                size: 80,
                color: AppColors.primary,
                shadows: [
                  Shadow(
                    blurRadius: 15.0,
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'BARBER 96',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 4.0,
                  shadows: [
                    Shadow(
                      blurRadius: 15.0,
                      color: AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
