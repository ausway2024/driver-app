import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'driver_registration_data.dart';
import 'driver home page.dart';

/// Runs LAST in the registration flow — after personal details and
/// own/agency vehicle details have already been collected in memory
/// (DriverRegistrationData). This page:
///
///   1. Sends an OTP to the phone number collected earlier.
///   2. Verifies the OTP, which creates the real Supabase Auth session
///      and gives us auth.currentUser.id.
///   3. Only then uploads the 3 document photos to the "driver-documents"
///      storage bucket and writes the full profile to driver_profiles.
///
/// Nothing touches Supabase before verifyOTP() succeeds, so there is no
/// window where an unauthenticated ("anon" role) request can hit
/// driver_profiles or storage.
class DriverOtpVerificationPage extends StatefulWidget {
  final DriverRegistrationData data;

  const DriverOtpVerificationPage({super.key, required this.data});

  @override
  State<DriverOtpVerificationPage> createState() =>
      _DriverOtpVerificationPageState();
}

class _DriverOtpVerificationPageState
    extends State<DriverOtpVerificationPage> {
  final otpController = TextEditingController();

  bool otpSent = false;
  bool isSendingOtp = false;
  bool isVerifying = false;
  String? errorText;

  /// Adjust the country code if you support drivers outside India, or
  /// collect the country code separately on the personal details page.
  String get _e164Phone {
    final raw = widget.data.phone.trim();
    return raw.startsWith('+') ? raw : '+91$raw';
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> sendOtp() async {
    setState(() {
      isSendingOtp = true;
      errorText = null;
    });
    try {
      await Supabase.instance.client.auth.signInWithOtp(phone: _e164Phone);
      if (!mounted) return;
      setState(() => otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("OTP sent to $_e164Phone")),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => errorText = "Could not send OTP: $e");
    } finally {
      if (mounted) setState(() => isSendingOtp = false);
    }
  }

  Future<void> verifyOtpAndSave() async {
    if (otpController.text.trim().isEmpty) {
      setState(() => errorText = "Enter the OTP sent to your phone");
      return;
    }

    setState(() {
      isVerifying = true;
      errorText = null;
    });

    try {
      final response = await Supabase.instance.client.auth.verifyOTP(
        type: OtpType.sms,
        phone: _e164Phone,
        token: otpController.text.trim(),
      );

      final user = response.user;
      if (user == null) {
        throw Exception("Verification did not return a signed-in user");
      }

      await _uploadDocumentsAndSaveProfile(user.id);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(
            driverId: user.id,
            ambulanceType: widget.data.ambulanceType ?? "BLS",
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => errorText = "Verification failed: $e");
    } finally {
      if (mounted) setState(() => isVerifying = false);
    }
  }

  /// Uploads under "{uid}/{folder}/..." so the storage RLS policy
  /// (owner-only insert, checking foldername[1] = auth.uid()) matches,
  /// and so the "public read profile_image" policy (foldername[2] ==
  /// 'profile_image') lines up with folder names used here.
  Future<String?> _uploadDocument(
      String uid, File file, String folder) async {
    final path = "$uid/$folder/${DateTime.now().millisecondsSinceEpoch}.jpg";
    await Supabase.instance.client.storage
        .from("driver-documents")
        .upload(path, file);
    return Supabase.instance.client.storage
        .from("driver-documents")
        .getPublicUrl(path);
  }

  Future<void> _uploadDocumentsAndSaveProfile(String uid) async {
    final data = widget.data;

    String? profileUrl;
    String? licenseUrl;
    String? aadharUrl;

    if (data.profilePhoto != null) {
      profileUrl =
          await _uploadDocument(uid, data.profilePhoto!, "profile_image");
    }
    if (data.licensePhoto != null) {
      licenseUrl =
          await _uploadDocument(uid, data.licensePhoto!, "driving_license");
    }
    if (data.aadharPhoto != null) {
      aadharUrl =
          await _uploadDocument(uid, data.aadharPhoto!, "aadhar_card");
    }

    final payload = <String, dynamic>{
      "id": uid,
      "phone": data.phone.trim(),
      "driver_name":
          "${data.firstName.trim()} ${data.lastName.trim()}".trim(),
      "emergency_contact": data.emergencyContact.trim(),
      "address": data.address1.trim(),
      "city": data.city.trim(),
      "pincode": data.pin.trim(),
      "ambulance_type": data.ambulanceType,
      "profile_image": profileUrl,
      "driving_license": licenseUrl,
      "aadhar_card": aadharUrl,
      "registration_type": data.registrationType,
      "profile_completed": true,
    };

    if (data.registrationType == "own") {
      payload["vehicle_number"] = data.vehicleNo;
    } else if (data.registrationType == "agency") {
      payload["agency_name"] = data.agencyName;
      payload["agency_number"] = data.agencyNumber;
      payload["agency_address"] = data.agencyAddress;
      payload["agency_city"] = data.agencyCity;
      payload["agency_pincode"] = data.agencyPincode;
      payload["agency_vehicle_count"] =
          int.tryParse(data.agencyVehicleCount ?? '');
      payload["agency_driver_count"] =
          int.tryParse(data.agencyDriverCount ?? '');
    }

    await Supabase.instance.client.from("driver_profiles").upsert(payload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF8E2B2B),
              Color(0xFFB33939),
              Color(0xFF8E2B2B),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset('assets/logo.png', height: 90),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8B4B4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Verify your phone number",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(_e164Phone),
                      const SizedBox(height: 20),
                      if (!otpSent)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isSendingOtp ? null : sendOtp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8E2B2B),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              isSendingOtp ? "Sending..." : "Send OTP",
                            ),
                          ),
                        ),
                      if (otpSent) ...[
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: TextField(
                            controller: otpController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: "Enter OTP",
                              filled: true,
                              fillColor: Colors.grey[300],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: isVerifying ? null : verifyOtpAndSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8E2B2B),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Text(
                              isVerifying
                                  ? "Verifying..."
                                  : "Verify & Complete Registration",
                            ),
                          ),
                        ),
                        Center(
                          child: TextButton(
                            onPressed: isSendingOtp ? null : sendOtp,
                            child: const Text("Resend OTP"),
                          ),
                        ),
                      ],
                      if (errorText != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          errorText!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
