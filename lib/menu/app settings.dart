import 'package:flutter/material.dart';
import 'app setting password.dart';
import 'package:driver_modual/driver login number entry.dart'; // Login Page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SettingsPage(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notifications = false;
  bool darkTheme = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF8B2C2C),
              Color(0xFFA94442),
              Color(0xFF8B2C2C),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE6D6D6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // 🔙 HEADER
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.arrow_back,
                            color: Color(0xFF8B2C2C)),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            "APP SETTINGS",
                            style: TextStyle(
                              color: Color(0xFF8B2C2C),
                              fontSize: 22,
                              letterSpacing: 4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 24),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // 📦 MAIN CARD
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD8C9C9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            buildSectionCard(
                              title: "App Preferences",
                              children: [
                                buildToggleTile(
                                  icon: Icons.notifications_none,
                                  text: "Notifications",
                                  value: notifications,
                                  onChanged: (val) {
                                    setState(() {
                                      notifications = val;
                                    });
                                  },
                                ),
                                buildToggleTile(
                                  icon: Icons.dark_mode_outlined,
                                  text: "Dark Theme",
                                  value: darkTheme,
                                  onChanged: (val) {
                                    setState(() {
                                      darkTheme = val;
                                    });
                                  },
                                ),
                                buildArrowTile(
                                  icon: Icons.language,
                                  text: "Language",
                                  trailing: "English",
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text("Language clicked")),
                                    );
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            buildSectionCard(
                              title: "Security",
                              children: [
                                buildArrowTile(
                                  icon: Icons.lock_outline,
                                  text: "Change Password",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PasswordPage(),
                                      ),
                                    );
                                  },
                                ),
                                buildArrowTile(
                                  icon: Icons.shield_outlined,
                                  text: "Privacy Policy",
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PrivacyPolicyPage(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 🔴 LOGOUT BUTTON
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginPage()),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      width: 160,
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B2C2C),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Center(
                        child: Text(
                          "Log Out",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
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
      ),
    );
  }

  // 🔹 SECTION CARD
  Widget buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFE6E6),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(fontSize: 14, color: Colors.black87)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  // 🔹 TOGGLE TILE
  Widget buildToggleTile({
    required IconData icon,
    required String text,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFE7CFCF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 50,
              height: 26,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: value
                    ? const Color(0xFF8B2C2C)
                    : Colors.grey.shade400,
              ),
              child: Align(
                alignment: value
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 CLICKABLE TILE
  Widget buildArrowTile({
    required IconData icon,
    required String text,
    String? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFE7CFCF),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black54),
              const SizedBox(width: 12),
              Expanded(child: Text(text)),
              if (trailing != null)
                Text(trailing,
                    style: const TextStyle(color: Colors.black54)),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward_ios, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}


// 🔥 CHANGE PASSWORD PAGE
class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: const Center(child: Text("Change Password Page")),
    );
  }
}

// 🔥 PRIVACY POLICY PAGE
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: const Center(child: Text("Privacy Policy Page")),
    );
  }
}