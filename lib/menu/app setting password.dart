import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PasswordPage(),
    );
  }
}

class PasswordPage extends StatefulWidget {
  const PasswordPage({super.key});

  @override
  State<PasswordPage> createState() => _PasswordPageState();
}

class _PasswordPageState extends State<PasswordPage> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool obscureNew = true;
  bool obscureConfirm = true;

  String errorText = "";

  void validatePassword() {
    String newPass = newPasswordController.text;
    String confirmPass = confirmPasswordController.text;

    if (newPass.length < 8) {
      setState(() {
        errorText = "Password must be at least 8 characters";
      });
    } else if (newPass != confirmPass) {
      setState(() {
        errorText = "Passwords do not match";
      });
    } else {
      setState(() {
        errorText = "";
      });
      debugPrint("Password Saved");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        /// 🔴 BACKGROUND
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF993535), Color(0xFFDA4F4F), Color(0xFF993535)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),

            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 228, 228),
                borderRadius: BorderRadius.circular(18),
              ),

              child: Column(
                children: [

                  const SizedBox(height: 15),

                  /// HEADER
                  Row(
                    children: [
                      const SizedBox(width: 15),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back,
                            color: Color(0xFF8F2E2E), size: 28),
                      ),
                      const Spacer(),
                      const Text(
                        "PASSWORD",
                        style: TextStyle(
                          letterSpacing: 4,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8F2E2E),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// 🔴 MISSING CONTAINER (ADDED)
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4F4), // dark inner bg
                        borderRadius: BorderRadius.circular(15),
                      ),

                      /// CENTER FIX
                      child: Center(
                        child: Container(
                          width: 300,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 253, 253),

                            borderRadius: BorderRadius.circular(15),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 5)
                            ],
                          ),

                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              /// NEW PASSWORD
                              const Text("New Password"),
                              const SizedBox(height: 8),

                              Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 255, 228, 228)
,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: newPasswordController,
                                  obscureText: obscureNew,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        const EdgeInsets.symmetric(horizontal: 12),
                                    hintText: "xxxxxxxxxxxx",
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        obscureNew
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          obscureNew = !obscureNew;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              const Text(
                                "Password Strength:\nUse at least 8 characters.Don’t use a password from another site",
                                style: TextStyle(fontSize: 12),
                              ),

                              const SizedBox(height: 15),

                              /// CONFIRM PASSWORD
                              const Text("Confirm New Password"),
                              const SizedBox(height: 8),

                              Container(
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 255, 228, 228),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: confirmPasswordController,
                                  obscureText: obscureConfirm,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding:
                                        const EdgeInsets.symmetric(horizontal: 12),
                                    hintText: "xxxxxxxxxxxx",
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        obscureConfirm
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          obscureConfirm = !obscureConfirm;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 10),

                              if (errorText.isNotEmpty)
                                Text(
                                  errorText,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 12),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// SAVE BUTTON
                  GestureDetector(
                    onTap: validatePassword,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 30),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8F2E2E),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Text(
                        "Save Password",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
