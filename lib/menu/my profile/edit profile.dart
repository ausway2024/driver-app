import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
      home: EditProfilePage(),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {

  /// CONTROLLERS
  final name = TextEditingController(text: "GUGAN");
  final email = TextEditingController(text: "gugan123@gmail.com");
  final phone = TextEditingController(text: "123456789");
  final dob = TextEditingController();

  String? gender;
  File? image;

  /// IMAGE PICKER
  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  /// DATE PICKER
  Future<void> pickDate() async {
    DateTime? selected = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      dob.text =
          "${selected.day}/${selected.month}/${selected.year}";
      setState(() {});
    }
  }

  /// SAVE
  void onSave() {
    if (name.text.isEmpty ||
        email.text.isEmpty ||
        phone.text.isEmpty ||
        dob.text.isEmpty ||
        gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Updated")),
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
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back),
                      ),
                      const SizedBox(width: 20),
                      const Text(
                        "EDIT PROFILE",
                        style: TextStyle(
                          fontSize: 18,
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6DADA),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 5)
                      ],
                    ),

                    child: Column(
                      children: [

                        /// PROFILE IMAGE
                        GestureDetector(
                          onTap: pickImage,
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundColor: Colors.white,
                                backgroundImage:
                                    image != null ? FileImage(image!) : null,
                                child: image == null
                                    ? const Icon(Icons.person,
                                        size: 40, color: Colors.red)
                                    : null,
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                "Change Profile Photo",
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        buildField("Full Name", name),
                        buildField("Email Address", email),
                        buildField("Phone Number", phone),

                        /// DATE
                        buildDateField(),

                        /// GENDER
                        buildDropdown(),

                      ],
                    ),
                  ),

                  const Spacer(),

                  /// SAVE BUTTON
                  GestureDetector(
                    onTap: onSave,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8E2B2B),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          "Save Changes",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
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

  /// TEXT FIELD
  Widget buildField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE6B8B8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }

  /// DATE FIELD
  Widget buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Date Of Birth"),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: pickDate,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFE6B8B8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dob.text.isEmpty ? "DD/MM/YYYY" : dob.text),
                const Icon(Icons.calendar_today, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// DROPDOWN
  Widget buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Gender"),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFE6B8B8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: gender,
            isExpanded: true,
            underline: const SizedBox(),
            hint: const Text("Select Gender"),
            items: ["Male", "Female", "Others"]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {
              setState(() => gender = val);
            },
          ),
        ),
      ],
    );
  }
}