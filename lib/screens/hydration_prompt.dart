import 'package:flutter/material.dart';
import '../storage/hydration_storage.dart';
import 'dashboard.dart';

class HydrationPrompt extends StatelessWidget {

  void record(BuildContext context, int amount) async {
    await HydrationStorage.addWater(amount);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => Dashboard()),
    );
  }

  void skip(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => Dashboard()),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text("Hydration AI"), centerTitle: true),

      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/water_droplet.png'),
            fit: BoxFit.cover,
            opacity: 0.2, // Adjust the opacity to make it subtle
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                "Did you drink water?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 20),

              ElevatedButton(
                child: Text("Yes"),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      TextEditingController controller = TextEditingController();

                      return AlertDialog(
                        title: Text("Water amount (ml)"),
                        content: TextField(controller: controller, keyboardType: TextInputType.number,),
                        actions: [
                          TextButton(
                            child: Text("Submit"),
                            onPressed: () {
                              int amount = int.parse(controller.text);
                              record(context, amount);
                            },
                          )
                        ],
                      );
                    },
                  );
                },
              ),

              SizedBox(height: 10),

              ElevatedButton(
                child: Text("No"),
                onPressed: () => skip(context),
              )
            ],
          ),
        ),
      ),
    );
  }
}