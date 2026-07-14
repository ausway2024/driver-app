import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'driver login number entry.dart';
import 'driver home page.dart';
import 'driver_registration_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), _routeNext);
  }

  // ==========================================================
  // SESSION-AWARE ROUTING
  // ==========================================================
  // Supabase persists the auth session on-device automatically, so if
  // this driver already verified OTP before, `currentSession` is
  // already populated here — no need to log in again every time the
  // app opens.
  //
  // IMPORTANT: driver_profiles.id is now ALWAYS the Supabase Auth uid
  // (session.user.id) — both sign-up and login write/read it that way
  // (see "driver login number entry.dart" and driver_reg.dart). This
  // used to be inconsistent: sign-up wrote a random self-generated id,
  // so this lookup by session.user.id always came back empty and sent
  // every returning driver back to the registration form. That's fixed
  // now that both sides agree on the same id.
  // ==========================================================
  Future<void> _routeNext() async {
    if (!mounted) return;

    final session = Supabase.instance.client.auth.currentSession;

    if (session == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    final driverId = session.user.id;

    try {
      final profile = await Supabase.instance.client
          .from("driver_profiles")
          .select()
          .eq("id", driverId)
          .maybeSingle();

      if (!mounted) return;

      final driverName = profile?["driver_name"] as String?;
      final ambulanceType = profile?["ambulance_type"] as String?;

      if (profile == null || driverName == null || driverName.isEmpty ||
          ambulanceType == null || ambulanceType.isEmpty) {
        // Signed in, but never finished (or never started) the
        // registration form.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DriverRegistrationPage(),
          ),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(
            driverId: driverId,
            ambulanceType: ambulanceType,
          ),
        ),
      );
    } catch (_) {
      // Couldn't reach Supabase — fall back to login rather than
      // getting stuck on the splash screen.
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        /// RADIAL GRADIENT (LIGHT AT LOGO → DARK OUTWARD)
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4D0A0A), // Top dark
              Color(0xFF993535), // Middle
              Color(0xFF4D0A0A), // Bottom lighter
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),

        /// LOGO (POSITION & SIZE UNCHANGED)
        child: Center(
          child: Image.asset(
            'assets/logo.png',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
