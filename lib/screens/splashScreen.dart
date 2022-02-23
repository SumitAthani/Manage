import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:manage/navigation/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const storage = FlutterSecureStorage();

  getToken() async {
    var jwt = await storage.read(key: "jwt");
    if (jwt == null) {
      setState(() {
        color = Colors.red;
      });
    } else {
      setState(() {
        color = Colors.greenAccent[400];
      });
    }
  }

  var route = "welcome";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getToken();
  }

  Color? color = Colors.amber;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: AnimatedContainer(
        duration: const Duration(seconds: 2),
        onEnd: () {
          if (color == Colors.red) {
            Navigator.pushReplacementNamed(context, MyRoutes.welcome);
          } else {
            Navigator.pushReplacementNamed(context, MyRoutes.addList);
          }
        },
        color: color,
        child: SizedBox(
          // color: color,
          height: 400,
          width: 400,
          child: Center(
            child: Image.asset("assets/images/logo2.png"),
          ),
        ),
      ),
    );
  }
}
