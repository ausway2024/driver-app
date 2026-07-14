import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'driver home page.dart';
import 'driver_registration_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

// ==========================================================
// LOGIN PAGE — for drivers who have ALREADY registered.
//
// This screen only ever does one thing: take the phone number typed
// into the box above the LOGIN button, check whether it exists in
// driver_profiles, and either:
//   - it exists  -> send the OTP and reveal the 6 OTP boxes here, or
//   - it doesn't -> tell the driver they aren't registered yet and to
//                   use Sign up instead (no OTP is sent).
//
// The "Sign up" link at the bottom is NOT wired to this screen's login
// state in any way (no shared phone controller, no shared OTP boxes,
// no shared matchedProfile). Tapping it goes straight to the
// registration page — no phone entry, no OTP, nothing in between.
// ==========================================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showOtpField = false;
  bool isLoading = false;

  final TextEditingController phoneController = TextEditingController();

  final List<TextEditingController> otpControllers =
      List.generate(6, (index) => TextEditingController());

  final List<FocusNode> focusNodes =
      List.generate(6, (index) => FocusNode());

  // The driver_profiles row found for the entered phone number. Only
  // ever set once we've confirmed the phone is already registered.
  Map<String, dynamic>? matchedProfile;

  // ==========================================================
  // RESEND COOLDOWN — now that Twilio is wired up in Supabase, every
  // OTP send is a real, billed SMS. Without this, a driver tapping
  // LOGIN repeatedly (impatience, accidental double-tap) would fire
  // off a fresh text each time. 30s matches Supabase's own default
  // phone-OTP rate limit, so this also avoids hitting Supabase's
  // "For security purposes, you can only request this after ..."
  // error in the first place.
  // ==========================================================
  static const int _resendCooldownSeconds = 30;
  int _resendSecondsLeft = 0;
  Timer? _resendTimer;

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendSecondsLeft = _resendCooldownSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSecondsLeft <= 1) {
        timer.cancel();
        setState(() => _resendSecondsLeft = 0);
      } else {
        setState(() => _resendSecondsLeft -= 1);
      }
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    for (final controller in otpControllers) {
      controller.dispose();
    }
    for (final node in focusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  // ==========================================================
  // LOGIN — SEND OTP
  // The phone MUST already exist in driver_profiles. If it doesn't,
  // we stop right here with a message telling the driver to sign up —
  // no OTP is sent, and the OTP boxes never appear.
  // ==========================================================
  Future<void> sendOTP() async {
    final rawPhone = phoneController.text.trim();

    if (rawPhone.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter valid phone number'),
        ),
      );
      return;
    }

    // Real SMS now goes out via Twilio on every one of these — don't let
    // a double-tap (or an impatient driver) trigger a second text before
    // the last one could even arrive.
    if (_resendSecondsLeft > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please wait ${_resendSecondsLeft}s before resending the OTP'),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      // IMPORTANT: this used to be a plain
      //   .from("driver_profiles").select().eq("phone", rawPhone)
      // which — because Row Level Security only allows a row's owner
      // (auth.uid() = id) to read it — silently returned nothing for
      // every phone number, registered or not, since at this point in
      // the flow nobody is signed in yet. That's why "Send OTP" could
      // never reliably tell registered drivers apart from new ones.
      // check_driver_phone() is a security-definer function made for
      // exactly this pre-login check (see supabase_schema.sql) and is
      // safe to call while unauthenticated.
      final rows = await Supabase.instance.client
          .rpc("check_driver_phone", params: {"p_phone": rawPhone});
      final profile =
          (rows as List).isNotEmpty ? rows.first as Map<String, dynamic> : null;

      if (profile == null) {
        setState(() {
          isLoading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "You haven't registered yet. Please tap Sign up below.",
            ),
          ),
        );
        return;
      }

      matchedProfile = profile;

      final phone = "+91$rawPhone";

      await Supabase.instance.client.auth.signInWithOtp(
        phone: phone,
        shouldCreateUser: true,
      );

      if (!mounted) return;
      setState(() {
        isLoading = false;
        showOtpField = true;
      });
      _startResendCooldown();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('OTP sent to your phone'),
        ),
      );
    } on AuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      // Supabase returns a 429 "For security purposes, you can only
      // request this after Ns" style message if it thinks a resend
      // came too fast — surface that plainly instead of a raw dump.
      final message = e.message.toLowerCase().contains('security purposes')
          ? "Please wait a moment before requesting another OTP."
          : e.message;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // ==========================================================
  // LOGIN — VERIFY OTP
  // Confirms the SMS code via Supabase Auth, then goes straight to
  // HomePage using the profile we already matched above.
  // ==========================================================
  Future<void> verifyOTP() async {
    final otp = otpControllers.map((controller) => controller.text).join();
    if (otp.length != 6) {
      return;
    }

    if (matchedProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please tap LOGIN again before entering the code.'),
        ),
      );
      return;
    }

    final rawPhoneForClaim = phoneController.text.trim();
    final phone = "+91$rawPhoneForClaim";

    try {
      setState(() {
        isLoading = true;
      });

      await Supabase.instance.client.auth.verifyOTP(
        phone: phone,
        token: otp,
        type: OtpType.sms,
      );

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      // Sign-up no longer authenticates by phone (it's OTP-less now — see
      // "driver login number entry.dart"'s goToSignUp / driver_reg.dart),
      // so the profile row this driver originally created may carry a
      // different id than the uid this phone login just verified. Move
      // the row onto this session's uid — this is the ONLY place that's
      // allowed to happen, and only because Supabase Auth just proved
      // real ownership of this phone number via the SMS OTP above.
      final newAuthId = Supabase.instance.client.auth.currentUser!.id;
      final claimRows = await Supabase.instance.client.rpc(
        "claim_driver_profile",
        params: {"p_phone": rawPhoneForClaim, "p_new_id": newAuthId},
      );
      final claimed = (claimRows as List).isNotEmpty
          ? claimRows.first as Map<String, dynamic>
          : null;

      final driverId = (claimed?["id"] as String?) ?? newAuthId;
      final ambulanceType = (claimed?["ambulance_type"] as String?) ??
          (matchedProfile!["ambulance_type"] as String?) ??
          "BLS";

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(
            driverId: driverId,
            ambulanceType: ambulanceType,
          ),
        ),
      );
    } on AuthException catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
      for (final c in otpControllers) {
        c.clear();
      }
      focusNodes[0].requestFocus();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  // ==========================================================
  // GO TO SIGN UP — no OTP, no phone entry here at all: tapping this
  // goes straight to the registration page, as requested. There's
  // still one thing happening invisibly: an anonymous Supabase Auth
  // sign-in, purely so the driver has a real uid to write their
  // driver_profiles row under (RLS requires auth.uid() = id — without
  // some session, the insert on the registration page would just be
  // rejected by the database). The driver never sees this; there's no
  // OTP box, no phone box, no waiting. Their real phone number is
  // still collected — it's the very first field on the registration
  // form — and gets saved there like everything else.
  //
  // This has zero connection to the login form above: no shared
  // phoneController, no shared otpControllers, no shared matchedProfile.
  // ==========================================================
  bool isSigningUp = false;

  Future<void> goToSignUp() async {
    if (isSigningUp) return;
    setState(() => isSigningUp = true);

    try {
      final session = Supabase.instance.client.auth.currentSession;
      final driverId = session?.user.id ??
          (await Supabase.instance.client.auth.signInAnonymously())
              .session!
              .user
              .id;

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DriverRegistrationPage(),
        ),
      );
    } on AuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => isSigningUp = false);
    }
  }

  Widget buildOtpBox(int index) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.12,
      child: TextField(
        controller: otpControllers[index],
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFFEFE6E6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && index < focusNodes.length - 1) {
            FocusScope.of(context).requestFocus(focusNodes[index + 1]);
          }
          if (value.isEmpty && index > 0) {
            FocusScope.of(context).requestFocus(focusNodes[index - 1]);
          }

          final otp = otpControllers.map((controller) => controller.text).join();
          if (otp.length == 6) {
            verifyOTP();
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF8B2C2C),
              Color(0xFF9E3535),
              Color(0xFFC14444),
              Color(0xFFD94B4B),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: screenHeight),
              child: Column(
                children: [
                  if (isLoading) const LinearProgressIndicator(),
                  SizedBox(height: screenHeight * 0.05),
                  SizedBox(
                    height: screenHeight * 0.12,
                    child: Image.asset('assets/logo.png'),
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6CACA),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Enter Phone no. to log in'),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFE6E6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('+91'),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFE6E6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: TextField(
                                  controller: phoneController,
                                  keyboardType: TextInputType.number,
                                  maxLength: 10,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    counterText: '',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        Center(
                          child: GestureDetector(
                            onTap: _resendSecondsLeft > 0 ? null : sendOTP,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 35,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: _resendSecondsLeft > 0
                                    ? const Color(0xFF8B2C2C).withOpacity(0.5)
                                    : const Color(0xFF8B2C2C),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Text(
                                _resendSecondsLeft > 0
                                    ? 'RESEND IN ${_resendSecondsLeft}s'
                                    : (showOtpField ? 'RESEND OTP' : 'LOGIN'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        if (showOtpField) ...[
                          const Center(
                            child: Text(
                              'Enter OTP',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              6,
                              (index) => buildOtpBox(index),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  const Text(
                    'Don\u2019t have an account?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: goToSignUp,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 60),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 30,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6CACA),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Center(
                        child: Text(
                          'Sign up',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}