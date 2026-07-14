import 'package:flutter/material.dart';
import 'package:driver_modual/driver login number entry.dart';
import 'my profile/my profile.dart';
import 'app settings.dart';
import 'notification.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Menu(),
    );
  }
}

class Menu extends StatelessWidget {
  const Menu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF8E2A2A),
              Color(0xFFB63A3A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // TITLE
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "PROFILE",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // PROFILE CARD
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3C7C7),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.person, size: 50, color: Color(0xFF6A1B1B)),
                    SizedBox(width: 20),
                    Text(
                      "L GUGAN",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A1B1B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // MENU CONTAINER
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3C7C7),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    children: [
                      menuItem(context, Icons.person_outline, "MY PROFILE", const ProfilePage()),
                      menuItem(context, Icons.notifications_none, "NOTIFICATIONS", const NotificationsPage()),
                      menuItem(context, Icons.info_outline, "APP INFO", const DummyPage(title: "App Info")),
                      menuItem(context, Icons.help_outline, "HELP", const DummyPage(title: "Help")),
                      menuItem(context, Icons.settings, "APP SETTINGS", const SettingsPage()),
                      menuItem(context, Icons.logout, "LOGOUT", const LoginPage()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 BUTTON STYLE MENU ITEM
  Widget menuItem(BuildContext context, IconData icon, String title, Widget page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Material(
        color: const Color(0xFFE8CECE),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.brown.withValues(alpha: 0.2),
          highlightColor: Colors.brown.withValues(alpha: 0.1),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF6A1B1B)),
                const SizedBox(width: 15),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6A1B1B),
                    fontWeight: FontWeight.w500,
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

//////////////////////////////////////////////////////////////
// 🔹 DUMMY PAGE (FOR NAVIGATION TESTING)
//////////////////////////////////////////////////////////////

class DummyPage extends StatelessWidget {
  final String title;

  const DummyPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF8E2A2A),
        title: Text(title),
      ),
      body: Center(
        child: Text(
          title,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}