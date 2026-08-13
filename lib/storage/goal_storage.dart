import 'package:shared_preferences/shared_preferences.dart';

class GoalStorage {

  static const String goalKey = "hydration_goal";

  // Save the hydration goal
  static Future<void> saveGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(goalKey, goal);
  }

  // Get the hydration goal
  static Future<int> getGoal() async {
    final prefs = await SharedPreferences.getInstance();

    // If the user never set a goal, default is 3000 ml
    return prefs.getInt(goalKey) ?? 3000;
  }

}