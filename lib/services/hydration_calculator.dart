class HydrationCalculator {
  static int calculateGoal({
    required double weight,
    required double temperature,
    required double humidity,
    required String gender,
    required bool isPregnant,
  }) {
    double base;

    if (gender == "Man") {
      base = weight * 40;
    } else if (gender == "Woman") {
      base = weight * 35;

      if (isPregnant) {
        base += 300;
      }
    } else {
      base = weight * 35;
    }

    if (temperature > 30) {
      base += 750;
    } else if (temperature > 20) {
      base += 250;
    }

    if (humidity < 40) {
      base += 250;
    } else if (humidity > 70) {
      base += 200;
    }

    return base.round();
  }
}