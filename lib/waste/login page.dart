import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../driver home page.dart';
import '../driver_registration_page.dart';

import '../services/api_service.dart';
import '../services/token_service.dart';

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

  @override
  void dispose() {
    phoneController.dispose();
    for (final controller in otpControllers) {
      controller.dispose();
    }
    for (final node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> sendOTP() async {
    final phone = "+91${phoneController.text.trim()}";

    if (phoneController.text.trim().length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter valid phone number'),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final response = await ApiService.sendOTP(phone);
      setState(() {
        isLoading = false;
      });

      final json = jsonDecode(response.body);
      if (json['success'] == true) {
        setState(() {
          showOtpField = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP Sent Successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(json['message'] ?? 'Failed to send OTP'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Future<void> verifyOTP() async {
    final otp = otpControllers.map((controller) => controller.text).join();
    if (otp.length != 6) {
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      final response = await ApiService.verifyOTP(
        phone: "+91${phoneController.text.trim()}",
        otp: otp,
      );
      setState(() {
        isLoading = false;
      });

      final json = jsonDecode(response.body);
      if (json['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(json['message'] ?? 'OTP verification failed'),
          ),
        );
        return;
      }

      if (json['newDriver'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const DriverRegistrationPage(),
          ),
        );
        return;
      }

      await TokenService.saveToken(json['token']);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomePage(),
        ),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
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
                        const Text('Enter Phone no.'),
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
                            onTap: sendOTP,
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
                                'SEND OTP',
                                style: TextStyle(
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
                    'Don’t have an account?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DriverRegistrationPage(),
                        ),
                      );
                    },
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

