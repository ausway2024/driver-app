import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      home: AgencyFormPage(data: DriverRegistrationData()),
    );
  }
}

/// SECOND screen for drivers who chose "agency". Still no Supabase calls
/// here — this just fills in the agency fields on the shared
/// DriverRegistrationData object and hands off to the OTP verification
/// page, which is where the account actually gets created and saved.
class AgencyFormPage extends StatefulWidget {
  final DriverRegistrationData data;

  const AgencyFormPage({super.key, required this.data});

  @override
  State<AgencyFormPage> createState() => _AgencyFormPageState();
}

class _AgencyFormPageState extends State<AgencyFormPage> {
  /// CONTROLLERS
  final agencyName = TextEditingController();
  final agencyNumber = TextEditingController();
  final address1 = TextEditingController();
  final city = TextEditingController();
  final pin = TextEditingController();
  final vehicles = TextEditingController();
  final drivers = TextEditingController();

  /// VALIDATION
  bool isFormValid() {
    return agencyName.text.isNotEmpty &&
        agencyNumber.text.isNotEmpty &&
        address1.text.isNotEmpty &&
        city.text.isNotEmpty &&
        pin.text.isNotEmpty &&
        vehicles.text.isNotEmpty &&
        drivers.text.isNotEmpty;
  }

  /// CONFIRM BUTTON ACTION — no Supabase call here anymore. Fills in
  /// the agency fields on the shared data object and moves on to OTP
  /// verification, where the driver_profiles row is finally created
  /// with everything collected across both screens.
  void onConfirm() {
    if (!isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );
      return;
    }

    widget.data
      ..registrationType = "agency"
      ..agencyName = agencyName.text.trim()
      ..agencyNumber = agencyNumber.text.trim()
      ..agencyAddress = address1.text.trim()
      ..agencyCity = city.text.trim()
      ..agencyPincode = pin.text.trim()
      ..agencyVehicleCount = vehicles.text.trim()
      ..agencyDriverCount = drivers.text.trim();

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
        /// 🔴 BACKGROUND
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
          child: Column(
            children: [
              const SizedBox(height: 30),

              /// LOGO
              SizedBox(
                height: 90,
                width: 90,
                child: Image.asset("assets/logo.png", fit: BoxFit.contain),
              ),

              const SizedBox(height: 20),

              /// FORM CARD
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6CACA),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// AGENCY NAME
                        buildLabel("Agency Name"),
                        buildInputField(
                          hint: "Enter Agency Name",
                          controller: agencyName,
                          formatter: FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z ]'),
                          ),
                        ),

                        /// AGENCY NUMBER
                        buildLabel("Agency Number"),
                        buildInputField(
                          hint: "Enter Agency Number",
                          controller: agencyNumber,
                          keyboard: TextInputType.number,
                          formatter: FilteringTextInputFormatter.digitsOnly,
                        ),

                        /// ADDRESS
                        buildLabel("Agency Address"),
                        buildInputField(
                          hint:
                              "Enter your House or Building No. / Street Name",
                          controller: address1,
                        ),
                        buildInputField(
                          hint: "Enter your Area / City",
                          controller: city,
                        ),
                        buildInputField(
                          hint: "Enter Pin Code",
                          controller: pin,
                          keyboard: TextInputType.number,
                          formatter: FilteringTextInputFormatter.digitsOnly,
                        ),

                        /// VEHICLES
                        buildLabel("Total Number of Vehicals"),
                        buildInputField(
                          hint: "Enter Total Number Of Vehicals",
                          controller: vehicles,
                          keyboard: TextInputType.number,
                          formatter: FilteringTextInputFormatter.digitsOnly,
                        ),

                        /// DRIVERS
                        buildLabel("Total Number of Drivers"),
                        buildInputField(
                          hint: "Enter Total Number of Drivers",
                          controller: drivers,
                          keyboard: TextInputType.number,
                          formatter: FilteringTextInputFormatter.digitsOnly,
                        ),

                        const SizedBox(height: 40),

                        /// CONFIRM BUTTON
                        Center(
                          child: GestureDetector(
                            onTap: onConfirm,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 35,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF8B2C2C),
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
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// LABEL
  Widget buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  /// INPUT FIELD
  Widget buildInputField({
    required String hint,
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
    TextInputFormatter? formatter,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFEFE6E6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        inputFormatters: formatter != null ? [formatter] : [],
        decoration: const InputDecoration(
          border: InputBorder.none,
        ),
      ),
    );
  }
}
