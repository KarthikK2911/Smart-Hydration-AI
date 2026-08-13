import 'package:flutter/material.dart';
import 'package:liquid_progress_indicator_v2/liquid_progress_indicator.dart';

import '../services/weather_service.dart';
import '../services/hydration_calculator.dart';
import '../services/fuzzy_logic.dart';

import '../storage/hydration_storage.dart';
import '../storage/profile_storage.dart';
import '../storage/hydration_history.dart';

import 'settings.dart';
import 'history.dart';

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int water = 0;
  int goal = 3000;

  double temp = 0;
  double humidity = 0;

  String name = "User";
  double weight = 70;

  String gender = "Man";
  bool isPregnant = false;

  String sleepTime = "23:00";

  int caloriesBurned = 0;

  String statusMessage = "";
  int hoursLeft = 0;

  int currentIndex = 0;

  bool isWeatherLoading = false;
  String weatherMessage = "Tap Refresh Weather to update weather data";

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    water = await HydrationStorage.getWater();

    var profile = await ProfileStorage.getProfile();

    name = profile["name"];
    weight = profile["weight"];
    sleepTime = profile["sleep"];
    gender = profile["gender"];
    isPregnant = profile["isPregnant"];

    if (gender != "Woman") {
      isPregnant = false;
    }

    updateGoalAndStatus();

    if (!mounted) return;

    setState(() {});
  }

  void updateGoalAndStatus() {
    goal = HydrationCalculator.calculateGoal(
      weight: weight,
      temperature: temp,
      humidity: humidity,
      gender: gender,
      isPregnant: isPregnant,
    );

    int extraWater = (caloriesBurned * 0.6).toInt();
    goal += extraWater;

    statusMessage = FuzzyLogic.evaluate(
      temp,
      humidity,
      water.toDouble(),
    );

    hoursLeft = calculateHoursLeft();
  }

  Future<void> refreshWeather() async {
    if (isWeatherLoading) return;

    setState(() {
      isWeatherLoading = true;
      weatherMessage = "Getting your location and weather...";
    });

    final weather = await WeatherService().getWeather();

    if (!mounted) return;

    setState(() {
      isWeatherLoading = false;

      if (weather["success"] == true) {
        temp = weather["temperature"].toDouble();
        humidity = weather["humidity"].toDouble();

        updateGoalAndStatus();

        weatherMessage =
        "${weather["message"]}\nLat: ${weather["latitude"]}, Lon: ${weather["longitude"]}";
      } else {
        weatherMessage = weather["message"];
      }
    });
  }

  int calculateHoursLeft() {
    try {
      final parts = sleepTime.split(":");

      int sleepHour = int.parse(parts[0]);
      int sleepMinute = int.parse(parts[1]);

      DateTime now = DateTime.now();

      DateTime sleep = DateTime(
        now.year,
        now.month,
        now.day,
        sleepHour,
        sleepMinute,
      );

      if (sleep.isBefore(now)) return 1;

      int difference = sleep.difference(now).inHours;

      if (difference <= 0) return 1;

      return difference;
    } catch (e) {
      return 1;
    }
  }

  int mlPerHour() {
    int remaining = goal - water;

    if (remaining <= 0) return 0;

    int hrs = hoursLeft == 0 ? 1 : hoursLeft;

    return (remaining / hrs).ceil();
  }

  void caloriesDialog() {
    TextEditingController c = TextEditingController(
      text: caloriesBurned.toString(),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Calories Burned Today"),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                caloriesBurned = int.tryParse(c.text) ?? 0;
                updateGoalAndStatus();
              });

              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget waterAnimation(double progress) {
    if (progress > 1) progress = 1;
    if (progress < 0) progress = 0;

    return Container(
      height: 250,
      width: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.blue, width: 3),
        color: Colors.blue.withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: LiquidCircularProgressIndicator(
          value: progress,
          valueColor: AlwaysStoppedAnimation(Colors.blue),
          backgroundColor: Colors.white,
          borderColor: Colors.blue,
          borderWidth: 2,
          direction: Axis.vertical,
          center: Text(
            "${(progress * 100).round()}%",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }

  Widget progressBar() {
    double progress = goal == 0 ? 0 : water / goal;

    if (progress > 1) progress = 1;
    if (progress < 0) progress = 0;

    Color startColor = Colors.red;
    Color endColor = Colors.green;

    return Container(
      width: double.infinity,
      height: 20,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade300,
      ),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.transparent,
        valueColor: AlwaysStoppedAnimation(
          Color.lerp(startColor, endColor, progress)!,
        ),
      ),
    );
  }

  void addWaterDialog() {
    TextEditingController c = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Add Water (ml)"),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              int v = int.tryParse(c.text) ?? 0;

              if (v > 0) {
                await HydrationStorage.addWater(v);
                await load();
                await HydrationHistory.updateToday(water);
              }

              Navigator.pop(context);
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void editWaterDialog() async {
    int lastWater = await HydrationStorage.getLastWater();

    TextEditingController c = TextEditingController(
      text: lastWater.toString(),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Edit Last Intake"),
        content: TextField(
          controller: c,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              int v = int.tryParse(c.text) ?? 0;

              if (v >= 0) {
                await HydrationStorage.saveLastWater(v);
                await load();
                await HydrationHistory.updateToday(water);
              }

              Navigator.pop(context);
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }

  String profileGoalText() {
    if (gender == "Woman" && isPregnant) {
      return "Goal adjusted for: Woman, Pregnant";
    }

    return "Goal adjusted for: $gender";
  }

  Widget weatherTemperatureText() {
    if (temp == 0) {
      return Text(
        "🌡 Temperature not loaded",
        style: TextStyle(fontSize: 20),
      );
    }

    return Text(
      "🌡 $temp°C",
      style: TextStyle(fontSize: 20),
    );
  }

  Widget weatherHumidityText() {
    if (humidity == 0) {
      return Text("💧 Humidity not loaded");
    }

    return Text("💧 $humidity%");
  }

  Widget body() {
    double progress = goal == 0 ? 0 : water / goal;

    if (progress > 1) progress = 1;
    if (progress < 0) progress = 0;

    int remaining = goal - water;

    if (remaining < 0) remaining = 0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            "Hello $name",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 20),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  weatherTemperatureText(),

                  weatherHumidityText(),

                  SizedBox(height: 8),

                  Text(
                    weatherMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700),
                  ),

                  SizedBox(height: 10),

                  isWeatherLoading
                      ? CircularProgressIndicator()
                      : ElevatedButton.icon(
                    onPressed: refreshWeather,
                    icon: Icon(Icons.refresh),
                    label: Text("Refresh Weather"),
                  ),

                  SizedBox(height: 8),

                  Text(
                    profileGoalText(),
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Today's Intake",
                    style: TextStyle(fontSize: 18),
                  ),

                  SizedBox(height: 10),

                  waterAnimation(progress),

                  SizedBox(height: 10),

                  Text(
                    "$water ml",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),

                  SizedBox(height: 10),

                  Text(
                    statusMessage,
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 8),

                  Text(
                    "🔥 Calories Burned: $caloriesBurned kcal",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  Text(
                    "➕ Extra Water: ${(caloriesBurned * 0.6).toInt()} ml",
                    style: TextStyle(color: Colors.blue),
                  ),

                  SizedBox(height: 8),

                  Text(
                    "💧 ${mlPerHour()} ml/hour needed",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          await HydrationStorage.addWater(250);
                          await load();
                          await HydrationHistory.updateToday(water);
                        },
                        child: Text("+250"),
                      ),

                      ElevatedButton(
                        onPressed: () async {
                          await HydrationStorage.addWater(500);
                          await load();
                          await HydrationHistory.updateToday(water);
                        },
                        child: Text("+500"),
                      ),

                      ElevatedButton(
                        onPressed: () async {
                          await HydrationStorage.addWater(1000);
                          await load();
                          await HydrationHistory.updateToday(water);
                        },
                        child: Text("+1L"),
                      ),

                      ElevatedButton(
                        onPressed: caloriesDialog,
                        child: Text("Calories"),
                      ),
                    ],
                  ),

                  SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: addWaterDialog,
                        child: Text("Add"),
                      ),

                      ElevatedButton(
                        onPressed: editWaterDialog,
                        child: Text("Edit"),
                      ),

                      ElevatedButton(
                        onPressed: () async {
                          await HydrationStorage.resetWater();
                          await load();
                          await HydrationHistory.updateToday(water);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text("Reset"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 20),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Goal: $goal ml",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    profileGoalText(),
                    style: TextStyle(color: Colors.grey.shade700),
                  ),

                  SizedBox(height: 10),

                  progressBar(),

                  SizedBox(height: 10),

                  Text(
                    "${(progress * 100).toStringAsFixed(1)}% completed",
                  ),

                  SizedBox(height: 10),

                  Text("You need $remaining ml more"),

                  SizedBox(height: 5),

                  Text("⏳ $hoursLeft hours left until sleep"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: body(),
      ),
      HistoryScreen(),
      Settings(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Hydration AI"),
        centerTitle: true,
      ),
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) async {
          if (index == 0) {
            await load();
          }

          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.water_drop),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}