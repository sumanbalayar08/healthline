import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:healthsearch/main.dart';

class ConnectivityWidget extends StatefulWidget {
  final Widget child;

  ConnectivityWidget({required this.child});

  @override
  _ConnectivityWidgetState createState() => _ConnectivityWidgetState();
}

class _ConnectivityWidgetState extends State<ConnectivityWidget> {
  bool isConnected = true;

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        !isConnected
            ? CupertinoAlertDialog(
                title: const Text("No Connection"),
                content: const Text('Please check your internet connectivity'),
                actions: <Widget>[
                  TextButton(
                      onPressed: () {
                        checkConnection();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MyApp()),
                        );
                      },
                      child: const Text("Ok"))
                ],
              )
            : Container(),
      ],
    );
  }

  void checkConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isConnected =
          connectivityResult != ConnectivityResult.none ? true : false;
    });
    Future.delayed(Duration(seconds: 10), checkConnection);
  }
  
@override
void dispose() {
    super.dispose();
  }
}
