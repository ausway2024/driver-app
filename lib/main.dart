import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'SScreen.dart';
import 'config/app_config.dart';

// Global accessor, same pattern as the User App:
//   supabase.from('driver_profiles').select()...
final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: AppConfig.SUPABASE_URL,
    anonKey: AppConfig.SUPABASE_ANON_KEY,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'AUSWAY Driver',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}