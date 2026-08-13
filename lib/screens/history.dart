import 'package:flutter/material.dart';
import '../storage/hydration_history.dart';

class HistoryScreen extends StatefulWidget {
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  List<Map<String, dynamic>> days = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final result = await HydrationHistory.getLast7Days();

      setState(() {
        days = result;
        isLoading = false;
      });
    } catch (e) {
      print("History error: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(DateTime d) {
    return "${d.month}/${d.day}";
  }

  @override
  Widget build(BuildContext context) {

    if (isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text("History")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text("History")),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: days.isEmpty
            ? Center(child: Text("No data available"))
            : ListView.builder(
          itemCount: days.length,
          itemBuilder: (context, index) {

            var item = days[index];

            DateTime date = item["date"];
            int amount = item["amount"];

            return Card(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(formatDate(date)),
                trailing: Text("$amount ml"),
              ),
            );
          },
        ),
      ),
    );
  }
}