import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'my profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DocumentsPage(),
    );
  }
}

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {

  String? aadhaar, licence, rto, insurance, puc;

  /// PICK FILE (PDF / IMAGE ONLY)
  Future<void> pickFile(Function(String) onPicked) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'jpeg'],
    );

    if (result != null) {
      onPicked(result.files.single.name);
    }
  }

  /// VALIDATION
  bool isValid() {
    return aadhaar != null &&
        licence != null &&
        rto != null &&
        insurance != null &&
        puc != null;
  }

  /// SAVE
  void onSave() {
    if (!isValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload all documents")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Documents Saved Successfully")),
    );

    
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfilePage(), // 👈 change this
        ),
      );
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(

        /// 🔴 BACKGROUND
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                /// HEADER
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back,
                          color: Color.fromARGB(255, 223, 33, 33)),
                    ),
                    const SizedBox(width: 20),
                    const Text(
                      "DOCUMENTS",
                      style: TextStyle(
                        fontSize: 20,
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// CARD
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6DADA),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),

                    child: SingleChildScrollView(
                      child: Column(
                        children: [

                          buildUpload("Aadhaar", aadhaar,
                              (v) => setState(() => aadhaar = v)),

                          buildUpload("Licence", licence,
                              (v) => setState(() => licence = v)),

                          buildUpload("RTO Certificate", rto,
                              (v) => setState(() => rto = v)),

                          buildUpload("Insurance", insurance,
                              (v) => setState(() => insurance = v)),

                          buildUpload("PUC", puc,
                              (v) => setState(() => puc = v)),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// SAVE BUTTON (ANIMATED)
                GestureDetector(
                  onTap: onSave,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8E2B2B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        "Save Changes",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
    );
  }

  /// UPLOAD FIELD (PERFECT UI)
  Widget buildUpload(
      String title, String? fileName, Function(String) onPicked) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),

        GestureDetector(
          onTap: () => pickFile(onPicked),
          child: Container(
            margin: const EdgeInsets.only(bottom: 18),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFE6B8B8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.upload_file, size: 20),
                const SizedBox(width: 10),

                /// FILE NAME (NO OVERFLOW)
                Expanded(
                  child: Text(
                    fileName ?? "File name...",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: fileName == null
                          ? Colors.black54
                          : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}