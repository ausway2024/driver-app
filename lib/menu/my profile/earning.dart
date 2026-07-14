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
      home: EarningsPage(),
    );
  }
}

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  String selectedTab = "earnings";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,

      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF993535),
              Color(0xFFDA4F4F),
              Color(0xFF993535),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4E4),
              borderRadius: BorderRadius.circular(20),
            ),

            child: Column(
              children: [

                /// TOP CONTAINER
                Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 15),
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 207, 207),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),

                  child: Column(
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Image.asset(
                              "assets/AUSWAY LOGO 1.png",
                              height: 70,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [

                          /// ALL EARNINGS
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTab = "earnings";
                              });
                            },
                            child: Column(
                              children: [
                                Text(
                                  "All Earnings",
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: selectedTab == "earnings"
                                        ? const Color(0xFF6F0000)
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  height: 4,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: selectedTab == "earnings"
                                        ? const Color(0xFF6F0000)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// WALLET
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedTab = "wallet";
                              });
                            },
                            child: Column(
                              children: [
                                Text(
                                  "Wallet",
                                  style: TextStyle(
                                    fontSize: 19,
                                    fontWeight: FontWeight.bold,
                                    color: selectedTab == "wallet"
                                        ? const Color(0xFF6F0000)
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  height: 4,
                                  width: 80,
                                  decoration: BoxDecoration(
                                    color: selectedTab == "wallet"
                                        ? const Color(0xFF6F0000)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// MAIN CONTENT
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),

                    child: Column(
                      children: [

                        Row(
                          children: [

                            Expanded(
                              child: Container(
                                height: 130,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 255, 211, 211),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text("Today’s Earnings"),
                                    SizedBox(height: 10),
                                    Text(
                                      "0₹",
                                      style: TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Column(
                              children: [
                                smallBox("Today’s Order\nOrder history and\norder earning"),
                                const SizedBox(height: 10),
                                smallBox("Last Order Details\nDEC 29 2025\n4:24"),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        box("VIEW RATE CARD"),
                        const SizedBox(height: 15),
                        box("Earning comparison"),
                        const SizedBox(height: 15),
                        box("Choose your earning plan"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget smallBox(String text) {
    return Container(
      height: 65,
      width: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFFFD3D3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10),
        ),
      ),
    );
  }

  Widget box(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD3D3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}