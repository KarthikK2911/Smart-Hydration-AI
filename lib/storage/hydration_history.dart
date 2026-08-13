import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class HydrationHistory {

  static const String key = "history";

  static String _today() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }


  static Future<void> updateToday(int totalWater) async {
    final prefs = await SharedPreferences.getInstance();

    List<String> raw = prefs.getStringList(key) ?? [];

    List<Map<String, dynamic>> data =
    raw.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

    String today = _today();

    bool found = false;

    for (var d in data) {
      if (d["date"] == today) {
        d["amount"] = totalWater; // overwrite
        found = true;
        break;
      }
    }

    if (!found) {
      data.add({
        "date": today,
        "amount": totalWater,
      });
    }

    await prefs.setStringList(
      key,
      data.map((e) => jsonEncode(e)).toList(),
    );
  }

  static Future<List<Map<String, dynamic>>> getLast7Days() async {
    final prefs = await SharedPreferences.getInstance();

    List<String> raw = prefs.getStringList(key) ?? [];

    List<Map<String, dynamic>> data =
    raw.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();

    final random = Random();
    List<Map<String, dynamic>> result = [];

    for (int i = 6; i >= 0; i--) {

      DateTime d = DateTime.now().subtract(Duration(days: i));
      String keyDate = "${d.year}-${d.month}-${d.day}";

      var existing = data.firstWhere(
            (e) => e["date"] == keyDate,
        orElse: () => {},
      );

      int amount;

      if (existing.isEmpty) {
        amount = 2750 + random.nextInt(251);
      } else {
        amount = existing["amount"];
      }

      result.add({
        "date": d,
        "amount": amount,
      });
    }

    return result;
  }
}