import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';
import '../BOOKED(Notification).dart';
import '../menu/menu.dart';

void main() {
  runApp(const MyApp());
}

/// ROOT
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

/// HOME PAGE
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showRide = true;
  bool isOnline = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void acceptRide() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BookingSuccessScreen()),
    );
  }

  void rejectRide() {
    setState(() {
      showRide = false;
    });
  }

  void toggleOnline() {
    setState(() {
      isOnline = !isOnline;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,

      drawer: Drawer(
        child: ListView(
          children: const [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF8E2A2A)),
              child: Text(
                "MENU",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            ListTile(title: Text("Profile")),
            ListTile(title: Text("History")),
            ListTile(title: Text("Logout")),
          ],
        ),
      ),

      body: Stack(
        children: [
          Container(color: Colors.grey[300]),

          /// SEARCH BAR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (_, __, ___) => const Menu(),
                            transitionsBuilder: (_, animation, __, child) {
                              return SlideTransition(
                                position: Tween(
                                  begin: const Offset(-1, 0),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              );
                            },
                          ),
                        );
                      },
                      child: const Icon(Icons.menu),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.search),
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
          ),

          /// BOTTOM PANEL
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 330,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFE6CACA),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 80, 16, 16),
                child: Column(
                  children: [
                    showRide
                        ? Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFE6E6),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "L GUGAN",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "K K Nagar",
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: rejectRide,
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                GestureDetector(
                                  onTap: acceptRide,
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox(),

                    const SizedBox(height: 20),

                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFE6E6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(child: Text("ADVERTISEMENTS")),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// 🔥 FINAL BUTTON
          Positioned(
            bottom: 270,
            left: MediaQuery.of(context).size.width / 2 - 75,
            child: CircularToggleButton(
              isOnline: isOnline,
              onTap: toggleOnline,
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔥 BUTTON
class CircularToggleButton extends StatefulWidget {
  final bool isOnline;
  final VoidCallback onTap;

  const CircularToggleButton({
    super.key,
    required this.isOnline,
    required this.onTap,
  });

  @override
  State<CircularToggleButton> createState() => _CircularToggleButtonState();
}

class _CircularToggleButtonState extends State<CircularToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> angleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    angleAnimation = AlwaysStoppedAnimation(widget.isOnline ? -pi / 2 : pi / 2);
  }

  @override
  void didUpdateWidget(covariant CircularToggleButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    double begin = angleAnimation.value;
    double end = widget.isOnline ? -pi / 2 : pi / 2;

    angleAnimation = Tween<double>(
      begin: begin,
      end: end,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward(from: 0);
  }

  bool isNearTopOrBottom(double angle) {
    return (angle - (-pi / 2)).abs() < 0.2 || (angle - (pi / 2)).abs() < 0.2;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 150,
        height: 150,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFEFE6E6),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            /// GLOW
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (widget.isOnline ? Colors.green : Colors.red)
                        .withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
            ),

            /// RING
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: 115,
              height: 115,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isOnline ? Colors.green : Colors.red,
                  width: 10,
                ),
              ),
            ),

            /// TEXT LOGIC
            AnimatedBuilder(
              animation: angleAnimation,
              builder: (context, child) {
                double angle = angleAnimation.value;
                double radius = 45;

                double x = radius * cos(angle);
                double y = radius * sin(angle);

                if (isNearTopOrBottom(angle)) {
                  return Transform.translate(
                    offset: Offset(x, y),
                    child: Text(
                      widget.isOnline ? "ONLINE" : "OFFLINE",
                      style: const TextStyle(
                        color: Color.fromARGB(255, 196, 191, 191),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                return CustomPaint(
                  size: const Size(150, 150),
                  painter: CurvedTextPainter(
                    text: widget.isOnline ? "ONLINE" : "OFFLINE",
                    angle: angle,
                  ),
                );
              },
            ),

            /// CENTER
            const Text(
              "START",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// CURVED TEXT
class CurvedTextPainter extends CustomPainter {
  final String text;
  final double angle;

  CurvedTextPainter({required this.text, required this.angle});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = 50.0;
    final center = Offset(size.width / 2, size.height / 2);

    final style = const TextStyle(
      color: Colors.white,
      fontSize: 10,
      fontWeight: FontWeight.bold,
    );

    double totalAngle = 0;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      final painter = TextPainter(
        text: TextSpan(text: char, style: style),
        textDirection: TextDirection.ltr,
      )..layout();

      final charAngle = painter.width / radius;
      final currentAngle = angle - totalAngle - charAngle / 2;

      final x = center.dx + radius * cos(currentAngle);
      final y = center.dy + radius * sin(currentAngle);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(currentAngle + pi / 2);

      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));

      canvas.restore();

      totalAngle += charAngle;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}