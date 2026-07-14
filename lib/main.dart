import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/services/supabase_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/services/presentation/providers/service_provider.dart';
import 'features/booking/presentation/providers/booking_provider.dart';
import 'features/queue/presentation/providers/queue_provider.dart';
import 'features/admin/presentation/providers/admin_provider.dart';

import 'features/profile/presentation/providers/profile_provider.dart';
import 'features/profile/presentation/providers/style_vault_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables securely
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Failed to load .env file: \$e");
  }

  // Initialize Supabase
  final supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  bool isSupabaseInitialized = false;
  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty && supabaseUrl.startsWith('http')) {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      isSupabaseInitialized = true;
    } catch (e) {
      debugPrint("Supabase Initialization Error: \$e");
    }
  } else {
    debugPrint("⚠️ Skipping Supabase initialization: Missing or invalid credentials in .env");
  }

  runApp(
    MultiProvider(
      providers: [
        // Provide the SupabaseService
        Provider<SupabaseService?>(
          create: (_) => isSupabaseInitialized ? SupabaseService(Supabase.instance.client) : null,
        ),
        // Auth Provider
        ChangeNotifierProxyProvider<SupabaseService?, AuthProvider?>(
          create: (_) => null,
          update: (_, supabase, __) => supabase != null ? AuthProvider(supabase) : null,
        ),
        // Service Provider
        ChangeNotifierProxyProvider<SupabaseService?, ServiceProvider?>(
          create: (_) => null,
          update: (_, supabase, __) => supabase != null ? ServiceProvider(supabase) : null,
        ),
        // Booking Provider
        ChangeNotifierProxyProvider<SupabaseService?, BookingProvider?>(
          create: (_) => null,
          update: (_, supabase, __) => supabase != null ? BookingProvider(supabase) : null,
        ),
        // Queue Provider
        ChangeNotifierProxyProvider<SupabaseService?, QueueProvider?>(
          create: (_) => null,
          update: (_, supabase, __) => supabase != null ? QueueProvider(supabase) : null,
        ),
        // Admin Provider
        ChangeNotifierProvider<AdminProvider>(
          create: (_) => AdminProvider(),
        ),
        // Profile Provider
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(),
        ),
        // Style Vault Provider
        ChangeNotifierProvider<StyleVaultProvider>(
          create: (_) => StyleVaultProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Barber 96',
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
