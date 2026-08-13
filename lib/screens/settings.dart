import 'package:flutter/material.dart';
import '../storage/profile_storage.dart';

class Settings extends StatefulWidget {
  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController sleepController = TextEditingController();

  String selectedGender = "Man";
  bool isPregnant = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    weightController.dispose();
    sleepController.dispose();
    super.dispose();
  }

  String normalizeGender(String gender) {
    if (gender == "Male") return "Man";
    if (gender == "Female") return "Woman";
    if (gender == "Man") return "Man";
    if (gender == "Woman") return "Woman";
    return "Other";
  }

  void loadProfile() async {
    var profile = await ProfileStorage.getProfile();

    setState(() {
      nameController.text = profile["name"];
      ageController.text = profile["age"].toString();
      weightController.text = profile["weight"].toString();
      sleepController.text = profile["sleep"];

      selectedGender = normalizeGender(profile["gender"]);
      isPregnant = profile["isPregnant"];

      if (selectedGender != "Woman") {
        isPregnant = false;
      }
    });
  }

  void saveProfile() async {
    int age = int.tryParse(ageController.text.trim()) ?? 20;
    double weight = double.tryParse(weightController.text.trim()) ?? 70;

    String name = nameController.text.trim();
    String sleep = sleepController.text.trim();

    if (name.isEmpty) {
      name = "User";
    }

    if (sleep.isEmpty) {
      sleep = "23:00";
    }

    if (selectedGender != "Woman") {
      isPregnant = false;
    }

    await ProfileStorage.saveProfile(
      name,
      age,
      weight,
      sleep,
      selectedGender,
      isPregnant,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profile Saved")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade200, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: "Name"),
            ),

            SizedBox(height: 10),

            TextField(
              controller: ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Age"),
            ),

            SizedBox(height: 10),

            TextField(
              controller: weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Weight (kg)"),
            ),

            SizedBox(height: 10),

            TextField(
              controller: sleepController,
              decoration: InputDecoration(labelText: "Sleep Time (HH:mm)"),
            ),

            SizedBox(height: 20),

            DropdownButtonFormField<String>(
              value: selectedGender,
              decoration: InputDecoration(
                labelText: "Gender",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: "Man",
                  child: Text("Man"),
                ),
                DropdownMenuItem(
                  value: "Woman",
                  child: Text("Woman"),
                ),
                DropdownMenuItem(
                  value: "Other",
                  child: Text("Other"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedGender = value ?? "Man";

                  if (selectedGender != "Woman") {
                    isPregnant = false;
                  }
                });
              },
            ),

            if (selectedGender == "Woman") ...[
              SizedBox(height: 15),

              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: Text("Are you pregnant?"),
                  subtitle: Text(
                    isPregnant
                        ? "Pregnancy hydration goal will be added"
                        : "Standard woman hydration goal will be used",
                  ),
                  value: isPregnant,
                  onChanged: (value) {
                    setState(() {
                      isPregnant = value;
                    });
                  },
                ),
              ),
            ],

            SizedBox(height: 25),

            ElevatedButton(
              onPressed: saveProfile,
              child: Text("Save Profile"),
            ),
          ],
        ),
      ),
    );
  }
}