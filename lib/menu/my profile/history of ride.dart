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
      home: HistoryPage(),
    );
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

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

            /// 🟡 MAIN CONTAINER
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 228, 228),
                borderRadius: BorderRadius.circular(18),
              ),

              child: Column(
                children: [

                  const SizedBox(height: 15),

                  /// 🔙 HEADER
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
                        "HISTORY",
                        style: TextStyle(
                          letterSpacing: 4,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color:  Color.fromARGB(255, 111, 0, 0),
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(width: 40),
                    ],
                  ),

                  const SizedBox(height: 15),

                  /// 📦 CONTENT
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(15),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 244, 244),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 5)
                        ],
                      ),

                      child: Column(
                        children: [

                          /// TITLE
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 228, 228),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Text(
                              "HISTORY OF RIDE",
                              style: TextStyle(
                                letterSpacing: 3,
                                color: Color(0xFF8F2E2E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          /// 🔴 RED BACKGROUND (FIX ADDED)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFDFD), // RED layer
                                borderRadius: BorderRadius.circular(15),
                              ),

                              /// LIST INSIDE RED BOX
                              child: ListView.separated(
                                itemCount: 4,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(255, 255, 228, 228),
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [

                                        /// LEFT
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: const [
                                              Text("HOSPITAL-LOCATION"),
                                              SizedBox(height: 5),
                                              Text(
                                                "dd/mm/yyyy",
                                                style:
                                                    TextStyle(fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),

                                        /// RIGHT
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: const [
                                            Text("₹ XXXX"),
                                            SizedBox(height: 5),
                                            Text(
                                              "XX:XX",
                                              style:
                                                  TextStyle(fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
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
}