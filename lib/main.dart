import "package:flutter/material.dart";
import 'package:manage/navigation/routes.dart';
import 'package:manage/screens/AddListScreen.dart';
import 'package:manage/screens/loginScreen.dart';
import 'package:manage/screens/signupScreen.dart';
import 'package:manage/screens/splashScreen.dart';
import 'package:manage/screens/welcomeScreen.dart';

void main() {
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

bool _darkTheme = false;

class _MyAppState extends State<MyApp> {
  @override
  initState() {
    super.initState();
  }

  setDark() {
    print("herer");

    setState(() {
      if (_darkTheme == false) {
        _darkTheme = true;
      } else {
        _darkTheme = false;
      }
    });
    print("$_darkTheme this");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: MaterialApp(
            darkTheme: ThemeData(brightness: Brightness.dark),
            debugShowCheckedModeBanner: false,
            theme: ThemeData(primarySwatch: Colors.amber),
            initialRoute: MyRoutes.splash,
            themeMode: _darkTheme ? ThemeMode.dark : ThemeMode.light,
            routes: {
              MyRoutes.addList: (context) => AddList(
                    setDark: setDark,
                    dark: _darkTheme,
                  ),
              MyRoutes.login: (context) => const Login(),
              MyRoutes.welcome: (context) => const WelcomeScreen(),
              MyRoutes.splash: (context) => const SplashScreen(),
              MyRoutes.signup: (context) => const Signup(),
            },
          ),
        ),
      ],
    );
  }
}
