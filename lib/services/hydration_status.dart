class HydrationStatus {

  static Map<String, dynamic> getStatus({
    required int water,
    required int goal,
  }) {

    final now = DateTime.now();

    // Day window (same as your app logic)
    final start = DateTime(now.year, now.month, now.day, 8);
    final end = DateTime(now.year, now.month, now.day, 23, 59);

    double hoursLeft = end.difference(now).inMinutes / 60;

    if (hoursLeft < 0) hoursLeft = 0;

    int remaining = goal - water;

    String message;

    // 🔥 NEW LOGIC (per-hour guidance)
    if (hoursLeft > 0) {

      double perHour = remaining / hoursLeft;

      if (remaining > 0) {
        message =
        "You are $remaining ml behind\n"
            "Drink ~${perHour.round()} ml per hour to stay on track";
      } else if (remaining == 0) {
        message =
        "You reached your goal 👍\n"
            "Maintain hydration (~${(goal / (hoursLeft + 1)).round()} ml/hour)";
      } else {
        message =
        "You are ${-remaining} ml ahead\n"
            "Slow down (~${(perHour.abs()).round()} ml/hour)";
      }

    } else {
      // End of day fallback
      if (remaining > 0) {
        message = "Day ended. You were $remaining ml short";
      } else {
        message = "Great job! Goal achieved 🎉";
      }
    }

    return {
      "hoursLeft": hoursLeft.round(),
      "message": message,
    };
  }
}