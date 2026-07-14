import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'driver agency registration.dart';
import 'driver own registration.dart';
import 'driver_registration_data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DriverRegistrationPage(),
    );
  }
}

/// FIRST screen of the registration flow. This page does NOT talk to
/// Supabase at all — there is no auth session yet, so nothing can be
/// written to driver_profiles here. It only collects the driver's
/// personal details and documents into a DriverRegistrationData object
/// and passes that forward to the own/agency vehicle screen. The actual
/// signup (OTP verification + document upload + driver_profiles write)
/// happens at the very end, in DriverOtpVerificationPage.
class DriverRegistrationPage extends StatefulWidget {
  const DriverRegistrationPage({super.key});

  @override
  State<DriverRegistrationPage> createState() =>
      _DriverRegistrationPageState();
}

class _DriverRegistrationPageState extends State<DriverRegistrationPage> {
  /// CONTROLLERS
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final phone = TextEditingController();
  final emergencyContact = TextEditingController();
  final address1 = TextEditingController();
  final city = TextEditingController();
  final pin = TextEditingController();

  /// VEHICLE SELECTION
  String? selectedVehicle;

  /// AMBULANCE TYPE — must match what the User App sends when booking
  /// (BLS / ALS / Bike / Neonatal), so the server's nearest-driver
  /// matching can find this driver.
  String? selectedAmbulanceType;

  /// DOCUMENT PHOTOS — driver's own photo, driving license, Aadhaar
  /// card. These are only uploaded to Supabase Storage once the OTP
  /// step succeeds and we have a real signed-in user id.
  File? profilePhoto;
  File? licensePhoto;
  File? aadharPhoto;

  Future<void> pickImage(String which) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() {
      switch (which) {
        case "profile":
          profilePhoto = File(picked.path);
          break;
        case "license":
          licensePhoto = File(picked.path);
          break;
        case "aadhar":
          aadharPhoto = File(picked.path);
          break;
      }
    });
  }

  /// VALIDATION
  bool isFormValid() {
    return firstName.text.isNotEmpty &&
        lastName.text.isNotEmpty &&
        phone.text.isNotEmpty &&
        emergencyContact.text.isNotEmpty &&
        address1.text.isNotEmpty &&
        city.text.isNotEmpty &&
        pin.text.isNotEmpty &&
        selectedAmbulanceType != null &&
        profilePhoto != null &&
        licensePhoto != null &&
        aadharPhoto != null;
  }

  /// VEHICLE CLICK — no Supabase call here anymore. Just builds the
  /// shared data object and moves on to the own/agency screen.
  void onVehicleTick(String type) {
    if (!isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and upload all 3 documents"),
        ),
      );
      return;
    }

    setState(() {
      selectedVehicle = type;
    });

    final data = DriverRegistrationData()
      ..firstName = firstName.text.trim()
      ..lastName = lastName.text.trim()
      ..phone = phone.text.trim()
      ..emergencyContact = emergencyContact.text.trim()
      ..address1 = address1.text.trim()
      ..city = city.text.trim()
      ..pin = pin.text.trim()
      ..ambulanceType = selectedAmbulanceType
      ..profilePhoto = profilePhoto
      ..licensePhoto = licensePhoto
      ..aadharPhoto = aadharPhoto;

    if (type == "own") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VehicleRegistrationPage(data: data),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AgencyFormPage(data: data),
        ),
      );
    }
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                /// LOGO
                CircleAvatar(
                  radius: 45,
                  backgroundColor: Colors.transparent,
                  child: Image.asset('assets/logo.png'),
                ),

                const SizedBox(height: 20),

                /// FORM
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD8B4B4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildLabel("First Name"),
                      buildTextField("Enter Your First Name", firstName),

                      buildLabel("Last Name"),
                      buildTextField("Enter Your Last Name", lastName),

                      buildLabel("Phone Number"),
                      buildTextField("Enter Phone Number", phone),

                      buildLabel("Emergency Contact"),
                      buildTextField(
                          "Enter Emergency Contact", emergencyContact),

                      buildLabel("Current Address"),
                      buildTextField("House / Street", address1),
                      buildTextField("City", city),
                      buildTextField("Pin Code", pin),

                      const SizedBox(height: 20),

                      /// AMBULANCE TYPE
                      buildLabel("AMBULANCE TYPE"),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: ["BLS", "ALS", "Bike", "Neonatal"]
                            .map(
                              (type) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedAmbulanceType = type;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selectedAmbulanceType == type
                                        ? const Color(0xFF8E2B2B)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: const Color(0xFF8E2B2B),
                                    ),
                                  ),
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      color: selectedAmbulanceType == type
                                          ? Colors.white
                                          : const Color(0xFF8E2B2B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),

                      const SizedBox(height: 20),

                      /// DOCUMENT UPLOADS
                      buildLabel("DOCUMENTS"),

                      buildUploadTile(
                        label: "Your Photo",
                        file: profilePhoto,
                        onTap: () => pickImage("profile"),
                      ),
                      buildUploadTile(
                        label: "Driving License",
                        file: licensePhoto,
                        onTap: () => pickImage("license"),
                      ),
                      buildUploadTile(
                        label: "Aadhaar Card",
                        file: aadharPhoto,
                        onTap: () => pickImage("aadhar"),
                      ),

                      const SizedBox(height: 20),

                      /// VEHICLE TICK BOXES
                      buildLabel("VEHICLE"),

                      Row(
                        children: [
                          /// OWN
                          GestureDetector(
                            onTap: () => onVehicleTick("own"),
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    color: selectedVehicle == "own"
                                        ? Colors.green
                                        : Colors.white,
                                  ),
                                  child: selectedVehicle == "own"
                                      ? const Icon(Icons.check,
                                          size: 14, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 6),
                                const Text("OWN"),
                              ],
                            ),
                          ),

                          const SizedBox(width: 30),

                          /// AGENCY
                          GestureDetector(
                            onTap: () => onVehicleTick("agency"),
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    color: selectedVehicle == "agency"
                                        ? Colors.green
                                        : Colors.white,
                                  ),
                                  child: selectedVehicle == "agency"
                                      ? const Icon(Icons.check,
                                          size: 14, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 6),
                                const Text("AGENCY"),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
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

  /// LABEL
  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }

  /// UPLOAD TILE
  Widget buildUploadTile({
    required String label,
    required File? file,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: file != null ? Colors.green : Colors.grey.shade400,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: file != null
                  ? Image.file(file, width: 48, height: 48, fit: BoxFit.cover)
                  : Container(
                      width: 48,
                      height: 48,
                      color: Colors.grey[300],
                      child:
                          const Icon(Icons.upload_file, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                file != null ? "$label — selected" : "Upload $label",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: file != null ? Colors.green[800] : Colors.black87,
                ),
              ),
            ),
            Icon(
              file != null ? Icons.check_circle : Icons.add_a_photo_outlined,
              color: file != null ? Colors.green : const Color(0xFF8E2B2B),
            ),
          ],
        ),
      ),
    );
  }

  /// TEXT FIELD
  Widget buildTextField(String hint, TextEditingController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[300],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
