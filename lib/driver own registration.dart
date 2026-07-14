import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'driver_registration_data.dart';
import 'driver_otp_verification.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VehicleRegistrationPage(data: DriverRegistrationData()),
    );
  }
}

/// SECOND screen for drivers who chose "own vehicle". Still no Supabase
/// calls here — this just fills in the vehicle fields on the shared
/// DriverRegistrationData object and hands off to the OTP verification
/// page, which is where the account actually gets created and saved.
class VehicleRegistrationPage extends StatefulWidget {
  final DriverRegistrationData data;

  const VehicleRegistrationPage({super.key, required this.data});

  @override
  State<VehicleRegistrationPage> createState() =>
      _VehicleRegistrationPageState();
}

class _VehicleRegistrationPageState extends State<VehicleRegistrationPage> {
  /// CONTROLLERS
  final vehicleNo = TextEditingController();
  final chassisNo = TextEditingController();
  final ownerName = TextEditingController();
  final vehicleClass = TextEditingController();
  final maker = TextEditingController();
  final insuranceNo = TextEditingController();

  String? fuelType;

  /// FILES
  String? rtoFile;
  String? insuranceFile;
  String? pucFile;

  /// PICK FILE
  Future<void> pickFile(Function(String) onPicked) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      onPicked(result.files.single.name);
    }
  }

  /// VALIDATION
  bool isValid() {
    return vehicleNo.text.isNotEmpty &&
        chassisNo.text.isNotEmpty &&
        ownerName.text.isNotEmpty &&
        vehicleClass.text.isNotEmpty &&
        maker.text.isNotEmpty &&
        insuranceNo.text.isNotEmpty &&
        fuelType != null &&
        rtoFile != null &&
        insuranceFile != null &&
        pucFile != null;
  }

  /// CONFIRM — no Supabase call here anymore. Fills in the vehicle
  /// fields on the shared data object and moves on to OTP verification,
  /// where the driver_profiles row is finally created.
  void onConfirm() {
    if (!isValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    widget.data
      ..registrationType = "own"
      ..vehicleNo = vehicleNo.text.trim();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DriverOtpVerificationPage(data: widget.data),
      ),
    );
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
                SizedBox(
                  height: 90,
                  child: Image.asset("assets/logo.png"),
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
                      buildLabel("Vehicle No."),
                      buildField("Enter Vehicle No.", vehicleNo),

                      buildLabel("Chassis No."),
                      buildField("Enter Vehicle Chassis No.", chassisNo),

                      buildLabel("Fuel"),
                      Row(
                        children: [
                          fuelBox("Diesel"),
                          fuelBox("Petrol"),
                          fuelBox("Others"),
                        ],
                      ),

                      buildLabel("Owner Name"),
                      buildField("Enter Owner Name", ownerName),

                      buildLabel("Vehicle Class"),
                      buildField("Enter Vehicle Class", vehicleClass),

                      buildLabel("Maker / Model"),
                      buildField("Enter Maker / Model", maker),

                      buildLabel("Insurance Number"),
                      buildField("Enter Insurance Number", insuranceNo),

                      buildLabel("RTO certificate"),
                      uploadBox("Upload RTO certificate", rtoFile,
                          (val) => setState(() => rtoFile = val)),

                      buildLabel("Insurance"),
                      uploadBox("Upload Insurance", insuranceFile,
                          (val) => setState(() => insuranceFile = val)),

                      buildLabel("PUC"),
                      uploadBox("Upload PUC", pucFile,
                          (val) => setState(() => pucFile = val)),

                      const SizedBox(height: 30),

                      /// CONFIRM BUTTON
                      Center(
                        child: GestureDetector(
                          onTap: onConfirm,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8E2B2B),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Text(
                              "CONFIRM",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
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
      child:
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  /// TEXT FIELD
  Widget buildField(String hint, TextEditingController controller) {
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

  /// FUEL BOX
  Widget fuelBox(String type) {
    return GestureDetector(
      onTap: () {
        setState(() => fuelType = type);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                color: fuelType == type ? Colors.green : Colors.white,
              ),
              child: fuelType == type
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 6),
            Text(type.toUpperCase()),
          ],
        ),
      ),
    );
  }

  /// UPLOAD BOX
  Widget uploadBox(
      String text, String? fileName, Function(String) onPicked) {
    return GestureDetector(
      onTap: () => pickFile(onPicked),
      child: Container(
        height: 45,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.upload_file_outlined),
              const SizedBox(width: 8),
              Text(fileName ?? text),
            ],
          ),
        ),
      ),
    );
  }
}
