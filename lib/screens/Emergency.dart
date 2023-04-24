import 'package:flutter/material.dart';

class Emergency extends StatefulWidget {
  const Emergency({super.key});

  @override
  State<Emergency> createState() => _EmergencyState();
}

class _EmergencyState extends State<Emergency> {
  bool _isAmbulNeed = false;
  bool _isBloodNeed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Emergency")),
        body: Column(
          children: [
            Row(
              children: [
                Center(
                  child: Checkbox(
                      value: _isAmbulNeed,
                      onChanged: (bool? value) {
                        setState(() {
                          print(value);
                          _isAmbulNeed = value ?? false;
                        });
                      }),
                ),
                Text("Need Ambulance"),
              ],
            ),
            Row(
              children: [
                Center(
                  child: Checkbox(
                      value: _isBloodNeed,
                      onChanged: (bool? value) {
                        setState(() {
                          print(value);
                          _isBloodNeed = value ?? false;
                        });
                      }),
                ),
                Text("Need Blood"),
              ],
            ),
          ],
        ));
  }
}
