import 'package:flutter/material.dart';
import 'package:healthsearch/screens/hospital_map.dart';
import 'package:healthsearch/screens/hospital_tables.dart';
import 'package:healthsearch/screens/Emergency.dart';


class HomeManagement extends StatefulWidget {
  const HomeManagement({Key? key}) : super(key: key);

  @override
  State<HomeManagement> createState() => _HomeManagementState();
}

class _HomeManagementState extends State<HomeManagement> {

  final List<Widget> _pages = [
    const Hospital_Table(),
    const Hospital_Map(),
  ];
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages.elementAt(_index),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (selectedIndex) {
          setState(() {
            _index = selectedIndex;
          });
        },
        currentIndex: _index,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.local_hospital), label: 'Hospitals'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Location'),
        ],
      ),
    );
  }
}
