import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notifications',
      theme: ThemeData(useMaterial3: true),
      home: const NotificationsPage(),
    );
  }
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String selectedFilter = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        /// 🔴 LAYER 1 — BACKGROUND
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8F2E2E), Color(0xFFB43C3C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),

            /// 🟡 LAYER 2 — MAIN BOX
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE6D5D5),
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
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF8F2E2E),
                          size: 28,
                        ),
                      ),

                      const Spacer(),

                      const Text(
                        "NOTIFICATIONS",
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

                  const SizedBox(height: 15),

                  /// FILTER CHIPS (CLICKABLE)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      chip("All"),
                      chip("Payments"),
                      chip("Updates"),
                      chip("Promotions"),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// ⚪ LAYER 3 — GREY BOX
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(15),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 6),
                        ],
                      ),

                      /// 🟢 LAYER 4 — MISSING INNER BOX (FIXED)
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEDED),
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: ListView(
                          children: [
                            buildCard(
                              "Payments",
                              Icons.payment,
                              "Payment Successful",
                              "Your payment of ₹ 499 for pre...",
                            ),

                            buildCard(
                              "Updates",
                              Icons.calendar_today,
                              "Subscription Remainder",
                              "Your subscription will be renew...",
                            ),

                            buildCard(
                              "Promotions",
                              Icons.card_giftcard,
                              "Special offer",
                              "get 20% off on your next pur...",
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
        ),
      ),
    );
  }

  /// 🔘 CHIP (CLICKABLE)
  Widget chip(String text) {
    final isSelected = selectedFilter == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF8F2E2E) : const Color(0xFFE3CACA),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  /// 🔔 CARD (CLICKABLE + FILTERED)
  Widget buildCard(String type, IconData icon, String title, String subtitle) {
    if (selectedFilter != "All" && selectedFilter != type) {
      return const SizedBox();
    }

    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFE6CFCF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black26)],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.black54),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text(
                  "dd/mm/yyyy",
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
                SizedBox(height: 4),
                Text(
                  "XX:XX",
                  style: TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
