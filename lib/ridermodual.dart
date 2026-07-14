import 'package:flutter/material.dart';
import 'menu/menu.dart'; // ✅ your menu page

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RiderScreen(),
    );
  }
}

class RiderScreen extends StatelessWidget {
  const RiderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6BDBD),

      /// 🔥 DRAWER (MENU PAGE)
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF8E2A2A)),
              child: Text(
                "MENU",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),

            /// 🔹 SETTINGS BUTTON WORKING
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Menu(),
                  ),
                );
              },
            ),

            /// 🔹 LOGOUT
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Logout"),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          /// 🔹 MAP AREA
          Container(
            height: MediaQuery.of(context).size.height * 0.75,
            width: double.infinity,
            color: Colors.grey[300],
          ),

          /// 🔹 TOP SEARCH BAR
          Positioned(
            top: 50,
            left: 15,
            right: 15,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  /// 🔥 MENU BUTTON WITH SLIDE ANIMATION
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const Menu(),
                            transitionsBuilder:
                                (_, animation, __, child) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(-1, 0), // FROM LEFT
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: const Icon(Icons.menu,
                          color: Colors.grey),
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Type in your location...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// 🔻 CUSTOMER STRIP + AVATAR
          Positioned(
            bottom: -10,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 80,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    left: 70,
                    right: 0,
                    top: 15,
                    child: Container(
                      height: 55,
                      padding: const EdgeInsets.only(
                          left: 30, right: 15),
                      decoration: const BoxDecoration(
                        color: Color(0xFF8E2A2A),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(100),
                          bottomLeft: Radius.circular(100),
                        ),
                      ),
                      child: const Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            "NAME OF CUSTOMER",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "PHONE NUMBER",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9DCDC),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF8E2A2A),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      /// 🔻 BOTTOM NAV BAR (ALL WORKING)
      bottomNavigationBar: Container(
        height: 65,
        color: const Color(0xFF8E2A2A),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                print("Link clicked");
              },
              child: const Icon(Icons.link, color: Colors.white),
            ),
            GestureDetector(
              onTap: () {
                print("Add clicked");
              },
              child:
                  const Icon(Icons.add_box, color: Colors.white),
            ),
            GestureDetector(
              onTap: () {
                print("Badge clicked");
              },
              child:
                  const Icon(Icons.badge, color: Colors.white),
            ),
            GestureDetector(
              onTap: () {
                print("Shield clicked");
              },
              child:
                  const Icon(Icons.shield, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}