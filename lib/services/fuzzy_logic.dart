class FuzzyLogic {
  // ------------------------------------------------------------
  // MEMBERSHIP FUNCTIONS
  // ------------------------------------------------------------

  /// Standard triangular membership function.
  ///
  /// a = left point
  /// b = peak point
  /// c = right point
  static double triangular(double x, double a, double b, double c) {
    if (x <= a || x >= c) {
      return 0.0;
    }

    if (x == b) {
      return 1.0;
    }

    if (x < b) {
      return (x - a) / (b - a);
    }

    return (c - x) / (c - b);
  }

  /// Left-shoulder membership function.
  ///
  /// Membership is 1 at and below [fullPoint],
  /// then gradually decreases to 0 at [zeroPoint].
  static double leftShoulder(
      double x,
      double fullPoint,
      double zeroPoint,
      ) {
    if (x <= fullPoint) {
      return 1.0;
    }

    if (x >= zeroPoint) {
      return 0.0;
    }

    return (zeroPoint - x) / (zeroPoint - fullPoint);
  }

  /// Right-shoulder membership function.
  ///
  /// Membership is 0 at and below [zeroPoint],
  /// then gradually increases to 1 at [fullPoint].
  static double rightShoulder(
      double x,
      double zeroPoint,
      double fullPoint,
      ) {
    if (x <= zeroPoint) {
      return 0.0;
    }

    if (x >= fullPoint) {
      return 1.0;
    }

    return (x - zeroPoint) / (fullPoint - zeroPoint);
  }

  // ------------------------------------------------------------
  // TEMPERATURE MEMBERSHIP FUNCTIONS
  // ------------------------------------------------------------

  static double tempLow(double temperature) {
    return leftShoulder(temperature, 0.0, 20.0);
  }

  static double tempModerate(double temperature) {
    return triangular(temperature, 15.0, 25.0, 35.0);
  }

  static double tempHigh(double temperature) {
    return rightShoulder(temperature, 30.0, 50.0);
  }

  // ------------------------------------------------------------
  // HUMIDITY MEMBERSHIP FUNCTIONS
  // ------------------------------------------------------------

  static double humidityLow(double humidity) {
    return leftShoulder(humidity, 0.0, 40.0);
  }

  static double humidityModerate(double humidity) {
    return triangular(humidity, 30.0, 50.0, 70.0);
  }

  static double humidityHigh(double humidity) {
    return rightShoulder(humidity, 60.0, 100.0);
  }

  // ------------------------------------------------------------
  // WATER INTAKE MEMBERSHIP FUNCTIONS
  // ------------------------------------------------------------

  static double waterLow(double water) {
    return leftShoulder(water, 0.0, 2000.0);
  }

  static double waterModerate(double water) {
    return triangular(water, 1500.0, 3500.0, 5000.0);
  }

  static double waterHigh(double water) {
    return rightShoulder(water, 4500.0, 7000.0);
  }

  // ------------------------------------------------------------
  // MAIN FUZZY EVALUATION
  // ------------------------------------------------------------

  static String evaluate(
      double temperature,
      double humidity,
      double water,
      ) {
    // Input validation
    final double safeTemperature = temperature.clamp(-20.0, 60.0).toDouble();
    final double safeHumidity = humidity.clamp(0.0, 100.0).toDouble();
    final double safeWater = water < 0.0 ? 0.0 : water;

    // Safety thresholds.
    //
    // These are intentionally evaluated before the fuzzy rules.
    // This makes the model a hybrid threshold-and-fuzzy system.
    if (safeWater >= 6000.0) {
      return '⚠️ Overhydrated';
    }

    if (safeWater >= 5000.0) {
      return '🟢 Low Hydration Needed';
    }

    if (safeWater <= 800.0) {
      return '🔥 High Hydration Required';
    }

    // Calculate temperature memberships
    final double tLow = tempLow(safeTemperature);
    final double tModerate = tempModerate(safeTemperature);
    final double tHigh = tempHigh(safeTemperature);

    // Calculate humidity memberships
    final double hLow = humidityLow(safeHumidity);
    final double hModerate = humidityModerate(safeHumidity);
    final double hHigh = humidityHigh(safeHumidity);

    // Calculate water memberships
    final double wLow = waterLow(safeWater);
    final double wModerate = waterModerate(safeWater);
    final double wHigh = waterHigh(safeWater);

    // ----------------------------------------------------------
    // COMPLETE 27-RULE FUZZY RULE BASE
    //
    // 3 temperature categories
    // × 3 humidity categories
    // × 3 water categories
    // = 27 total combinations
    // ----------------------------------------------------------

    final double highNeed = _max([
      // Low temperature, low water
      _min(tLow, hLow, wLow),
      _min(tLow, hModerate, wLow),
      _min(tLow, hHigh, wLow),

      // Moderate temperature, low water
      _min(tModerate, hLow, wLow),
      _min(tModerate, hModerate, wLow),
      _min(tModerate, hHigh, wLow),

      // High temperature, low water
      _min(tHigh, hLow, wLow),
      _min(tHigh, hModerate, wLow),
      _min(tHigh, hHigh, wLow),

      // High temperature, moderate water
      _min(tHigh, hLow, wModerate),
      _min(tHigh, hModerate, wModerate),
      _min(tHigh, hHigh, wModerate),
    ]);

    final double moderateNeed = _max([
      // Low temperature, moderate water
      _min(tLow, hLow, wModerate),
      _min(tLow, hModerate, wModerate),
      _min(tLow, hHigh, wModerate),

      // Moderate temperature, moderate water
      _min(tModerate, hLow, wModerate),
      _min(tModerate, hModerate, wModerate),
      _min(tModerate, hHigh, wModerate),

      // High temperature, high water
      _min(tHigh, hLow, wHigh),
      _min(tHigh, hModerate, wHigh),
      _min(tHigh, hHigh, wHigh),
    ]);

    final double lowNeed = _max([
      // Low temperature, high water
      _min(tLow, hLow, wHigh),
      _min(tLow, hModerate, wHigh),
      _min(tLow, hHigh, wHigh),

      // Moderate temperature, high water
      _min(tModerate, hLow, wHigh),
      _min(tModerate, hModerate, wHigh),
      _min(tModerate, hHigh, wHigh),
    ]);

    // Overhydration is primarily protected by the threshold above.
    // This fuzzy output is retained for completeness.
    final double overHydrated = _max([
      _min(tLow, hLow, wHigh),
      _min(tLow, hModerate, wHigh),
      _min(tLow, hHigh, wHigh),
    ]);

    final Map<String, double> outputStrengths = {
      '🔥 High Hydration Required': highNeed,
      '💧 Moderate Hydration': moderateNeed,
      '🟢 Low Hydration Needed': lowNeed,
      '⚠️ Overhydrated': overHydrated,
    };

    final double maxValue = _max(outputStrengths.values.toList());

    // No rule was activated.
    if (maxValue <= 0.0) {
      return '💧 Normal Hydration';
    }

    // Tie-breaking priority:
    //
    // 1. Overhydrated
    // 2. Low need
    // 3. Moderate
    // 4. High need
    //
    // The safety thresholds above already handle the most important
    // low-intake and high-intake conditions.
    const List<String> priority = [
      '⚠️ Overhydrated',
      '🟢 Low Hydration Needed',
      '💧 Moderate Hydration',
      '🔥 High Hydration Required',
    ];

    for (final String label in priority) {
      final double strength = outputStrengths[label] ?? 0.0;

      if (_approximatelyEqual(strength, maxValue)) {
        return label;
      }
    }

    return '💧 Normal Hydration';
  }

  // ------------------------------------------------------------
  // OPTIONAL DEBUG METHOD
  // ------------------------------------------------------------

  /// Returns membership values and rule strengths.
  ///
  /// This is useful for testing and demonstrating how the fuzzy
  /// system reached its result.
  static Map<String, dynamic> evaluateWithDetails(
      double temperature,
      double humidity,
      double water,
      ) {
    final double safeTemperature = temperature.clamp(-20.0, 60.0).toDouble();
    final double safeHumidity = humidity.clamp(0.0, 100.0).toDouble();
    final double safeWater = water < 0.0 ? 0.0 : water;

    return {
      'inputs': {
        'temperature': safeTemperature,
        'humidity': safeHumidity,
        'water': safeWater,
      },
      'temperatureMemberships': {
        'low': tempLow(safeTemperature),
        'moderate': tempModerate(safeTemperature),
        'high': tempHigh(safeTemperature),
      },
      'humidityMemberships': {
        'low': humidityLow(safeHumidity),
        'moderate': humidityModerate(safeHumidity),
        'high': humidityHigh(safeHumidity),
      },
      'waterMemberships': {
        'low': waterLow(safeWater),
        'moderate': waterModerate(safeWater),
        'high': waterHigh(safeWater),
      },
      'result': evaluate(
        safeTemperature,
        safeHumidity,
        safeWater,
      ),
    };
  }

  // ------------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------------

  static double _min(double a, double b, double c) {
    return [a, b, c].reduce(
          (double first, double second) =>
      first < second ? first : second,
    );
  }

  static double _max(List<double> values) {
    if (values.isEmpty) {
      return 0.0;
    }

    return values.reduce(
          (double first, double second) =>
      first > second ? first : second,
    );
  }

  static bool _approximatelyEqual(
      double first,
      double second, [
        double tolerance = 0.000001,
      ]) {
    return (first - second).abs() <= tolerance;
  }
}