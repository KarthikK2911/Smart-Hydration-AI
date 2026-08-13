import 'package:shared_preferences/shared_preferences.dart';

class HydrationStorage {

  static const String waterKey = "water";
  static const String dateKey = "last_reset_date";
  static const String lastWaterKey = "last_water";

  static Future<void> saveWater(int water) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(waterKey, water);
  }

  static Future<int> getWater() async {
    final prefs = await SharedPreferences.getInstance();
    await _checkAndReset(prefs);
    return prefs.getInt(waterKey) ?? 0;
  }

  static Future<void> addWater(int amount) async {
    final current = await getWater();
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(lastWaterKey, amount);
    await saveWater(current + amount);
  }

  static Future<void> setWater(int amount) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(lastWaterKey, amount);
    await saveWater(amount);
  }

  static Future<int> getLastWater() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(lastWaterKey) ?? 0;
  }

  static Future<void> saveLastWater(int amount) async {
    final prefs = await SharedPreferences.getInstance();

    int current = await getWater();
    int last = await getLastWater();

    int newTotal = current - last + amount;

    await prefs.setInt(lastWaterKey, amount);
    await saveWater(newTotal);
  }

  static Future<void> resetWater() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(waterKey, 0);
    await prefs.setInt(lastWaterKey, 0);
  }

  static Future<void> _checkAndReset(SharedPreferences prefs) async {
    final now = DateTime.now();
    final today = "${now.year}-${now.month}-${now.day}";

    final last = prefs.getString(dateKey);

    if (last == null) {
      await prefs.setString(dateKey, today);
      return;
    }

    if (last != today) {
      await prefs.setInt(waterKey, 0);
      await prefs.setInt(lastWaterKey, 0);
      await prefs.setString(dateKey, today);
    }
  }
}