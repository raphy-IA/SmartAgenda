import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/app_colors.dart';
import 'features/events/presentation/screens/dashboard_screen.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  
  // Init Services
  final notifService = NotificationService();
  await notifService.init();
  await notifService.requestPermissions(); // Ask early (or do it in Dashboard)

  // Init Supabase (Prod)
  await Supabase.initialize(
    url: 'https://bcimjeknpqajeshlhhuw.supabase.co',
    anonKey: 'sb_publishable_hlDxVrwvPZ-og8f-ia72sA_JvFpLscP',
  );
  
  runApp(
    const ProviderScope(
      child: SmartAgendaApp(),
    ),
  );
}

class SmartAgendaApp extends StatelessWidget {
  const SmartAgendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Agenda',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const DashboardScreen(),
    );
  }
}
