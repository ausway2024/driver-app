import 'package:flutter/material.dart';
import 'history of ride.dart';
import 'earning.dart';
import 'edit profile.dart';
import 'document.dart';
import 'package:driver_modual/menu/menu.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ProfilePage(),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFD8B4B4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [

                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "My Profile",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 40,
                        child: Image.asset("assets/logo.png"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50),
                  ),

                  const SizedBox(height: 20),

                  const Text("Ausway ID - XXXXXXXX"),

                  const SizedBox(height: 20),

                  /// STATS BOX
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6DADA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceAround,
                      children: const [
                        Column(
                          children: [
                            Row(
                              children: [
                                Text("-- "),
                                Icon(Icons.star, color: Colors.orange),
                              ],
                            ),
                            Text("Rating"),
                          ],
                        ),
                        Column(
                          children: [
                            Text("0"),
                            Text("No. of Patients attended"),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// BUTTONS
                  buildMenu(context, "Profile Info", const EditProfilePage()),
                  buildMenu(context, "Documents", const DocumentsPage()),
                  buildMenu(context, "Earning history", const EarningsPage()),
                  buildMenu(context, "History of ride", const HistoryPage()),

                  const Spacer(),

                  /// SAVE BUTTON
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Saved Successfully")),
                      );
                      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const Menu(), // 👈 change this
        ),
      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8E2B2B),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: const Text(
                        "Save",
                        style: TextStyle(color: Colors.white),
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

  /// MENU BUTTON
  Widget buildMenu(
      BuildContext context, String text, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFFE6B8B8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(child: Text(text)),
      ),
    );
  }
}

/// 🔽 DUMMY PAGES (YOU CAN EDIT LATER)
