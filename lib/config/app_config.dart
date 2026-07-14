/// =====================================================================
/// AUSWAY — CENTRAL APP CONFIG (Driver App)
/// =====================================================================
/// This is the ONLY file you should need to edit when your server's
/// address changes (new WiFi, deployed to Railway/Render, etc).
/// MUST use the SAME SERVER_IP as the User App's config so both apps
/// talk to the same AUSWAY_SERVER instance.
///
/// HOW TO SET SERVER_IP:
///  - Testing on a REAL PHONE over WiFi: set this to your computer's
///    LAN IP (run `ipconfig` on Windows / `ifconfig` or `ip addr` on
///    Mac/Linux, look for something like 192.168.x.x). Your phone and
///    computer must be on the SAME WiFi network.
///  - Testing on the ANDROID EMULATOR only: use "10.0.2.2"
///  - Server deployed online (Railway/Render/etc): use that https:// URL
///    instead (see BASE_URL below — set USE_HTTPS = true and put the
///    host in SERVER_IP without the port).
/// =====================================================================

class AppConfig {
  // ---- EDIT THIS (must match User App's app_config.dart) ----
  static const String SERVER_IP = "10.211.8.146"; // <-- put your computer's LAN IP here
  static const int SERVER_PORT = 3000;
  static const bool USE_HTTPS = false; // set true if server has https:// (e.g. Railway)

  // ---- Derived — leave as-is ----
  static String get _scheme => USE_HTTPS ? "https" : "http";
  static String get _hostAndPort =>
      USE_HTTPS ? SERVER_IP : "$SERVER_IP:$SERVER_PORT";

  /// Base REST URL, e.g. http://192.168.1.5:3000/api
  static String get baseUrl => "$_scheme://$_hostAndPort/api";

  /// Base Socket.IO URL, e.g. http://192.168.1.5:3000
  static String get socketUrl => "$_scheme://$_hostAndPort";

  // ---- Supabase (must match AUSWAY_SERVER's .env project) ----
  static const String SUPABASE_URL =
      "https://nxzdjklanoianbgbmeej.supabase.co";
  static const String SUPABASE_ANON_KEY =
      "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im54emRqa2xhbm9pYW5iZ2JtZWVqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMwNzQ2ODIsImV4cCI6MjA5ODY1MDY4Mn0.Gx1ExAr4PqSGh-4sucRltXTsuJ1rGNkavbjpbHalCYk";
}
