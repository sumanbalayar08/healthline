import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:healthsearch/helpers/hospitals.dart';
import 'package:healthsearch/helpers/shared_prefs.dart';
import 'package:healthsearch/screens/hospital_map.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Hospital_Table extends StatefulWidget {
  const Hospital_Table({super.key});

  @override
  State<Hospital_Table> createState() => _Hospital_TableState();
}

class _Hospital_TableState extends State<Hospital_Table> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> _dialCall(String number) async {
    String phoneNumber = number;
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launch(launchUri.toString());
  }

  final TextEditingController _editingController = TextEditingController();
  bool searchByName = true;

  List<Map<dynamic, dynamic>> newhospitals = List.from(hospitals);

  onItemChanged(String value) {
    setState(() {
      newhospitals = hospitals
          .where((hospital) =>
              hospital['name'].toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  onServiceChanged(String value) {
    setState(() {
      newhospitals = hospitals
          .where((hospital) =>
              hospital['service'].toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  bool _sortAscending = true;
  bool _isAmbulNeed = false;
  bool _isBloodNeed = false;

  void _sortHospital(bool ascending, bool _isAmbulNeed, bool _isBloodNeed) {
    int a, b, c, d, priority_val, dist1;
    List<Map<dynamic, dynamic>> newhospitals1 = List.of(newhospitals);
    num dist;
    for (int i = 0; i < newhospitals.length; i++) {
      print(newhospitals[i]["priorityval"]);
      a = newhospitals[i]["isDocAvail"];
      b = newhospitals[i]["isBloodAvail"];
      c = newhospitals[i]["isBedAvail"];
      d = newhospitals[i]["isAmbulAvail"];
      dist = getDistanceFromSharedPrefs(i) / 1000;
      dist1 = dist.toInt();
      //print(a + b + c + d);

      priority_val = dist1 + a + b + c + d;
      if (b == 1 && _isBloodNeed == true) {
        priority_val = priority_val + 1;
      }
      if (d == 1 && _isAmbulNeed == true) {
        priority_val = priority_val + 1;
      }

      //print(dist);
      //newhospitals1[i]["priorityval"] = priority_val;
      print("next");
      print(priority_val);
    }

    print("hello world");
    setState(() {
      _sortAscending = ascending;
      newhospitals.sort((a, b) => ascending
          ? a['priorityval'].compareTo(b['priorityval'])
          : b['priorityval'].compareTo(a['priorityval']));
    });
  }

  void prior(int value) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Hospitals Available"),
        ),
        body: SingleChildScrollView(
          physics: const ScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text('Search by name'),
                    Switch(
                      value: searchByName,
                      onChanged: (value) {
                        setState(() {
                          searchByName = value;
                        });
                      },
                    ),
                    Text('Search by service'),
                  ],
                ),
                TextField(
                  onChanged: (value) {
                    if (searchByName) {
                      onItemChanged(value);
                    } else {
                      onServiceChanged(value);
                    }
                  },
                  controller: _editingController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search for Hospitals',
                    filled: true,
                    fillColor: Colors.grey[900],
                    suffixIcon: IconButton(
                        onPressed: () {
                          print(_isAmbulNeed);
                          print(_isBloodNeed);
                          _sortHospital(
                              !_sortAscending, _isAmbulNeed, _isBloodNeed);
                        },
                        icon: Icon(_sortAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
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
                const SizedBox(
                  height: 8,
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: newhospitals.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 175,
                            width: 140,
                            child: Image.network(
                              newhospitals[index]['image'],
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 175,
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    newhospitals[index]['name'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  Text(newhospitals[index]['service']),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Text(
                                    'Closes at 10PM',
                                    style:
                                        TextStyle(color: Colors.redAccent[100]),
                                  ),
                                  SizedBox(
                                    height: 13,
                                  ),
                                  Row(
                                    children: [
                                      ElevatedButton(
                                        onPressed: () => _dialCall(
                                            '${(newhospitals[index]['phone'])}'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.all(5),
                                          minimumSize: Size.zero,
                                        ),
                                        child: Row(
                                          children: const [
                                            Icon(Icons.call, size: 16),
                                            SizedBox(width: 2),
                                            Text("Call")
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      ElevatedButton(
                                        onPressed: () => {
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Hospital_Map()))
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.all(5),
                                          minimumSize: Size.zero,
                                        ),
                                        child: Row(
                                          children: const [
                                            Icon(Icons.location_on, size: 16),
                                            SizedBox(width: 2),
                                            Text("Map")
                                          ],
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                          '${(getDistanceFromSharedPrefs(index) / 1000).toStringAsFixed(1)}km'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
