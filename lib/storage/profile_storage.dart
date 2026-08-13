import 'package:shared_preferences/shared_preferences.dart';

class ProfileStorage {
  static Future<void> saveProfile(
      String name,
      int age,
      double weight,
      String sleep,
      String gender,
      bool isPregnant,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("name", name);
    await prefs.setInt("age", age);
    await prefs.setDouble("weight", weight);
    await prefs.setString("sleep", sleep);
    await prefs.setString("gender", gender);
    await prefs.setBool("isPregnant", isPregnant);
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      "name": prefs.getString("name") ?? "User",
      "age": prefs.getInt("age") ?? 20,
      "weight": prefs.getDouble("weight") ?? 70,
      "sleep": prefs.getString("sleep") ?? "23:00",
      "gender": prefs.getString("gender") ?? "Man",
      "isPregnant": prefs.getBool("isPregnant") ?? false,
    };
  }
}