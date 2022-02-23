import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({Key? key, required this.setDark, required this.dark})
      : super(key: key);

  final setDark;
  final bool dark;

  @override
  State<MyDrawer> createState() => _MyDrawerState(setDark: setDark, dark: dark);
}

class _MyDrawerState extends State<MyDrawer> {
  final setDark;
  final bool dark;

  _MyDrawerState({required this.setDark, required this.dark});

  static const storage = FlutterSecureStorage();

  late Map<String, dynamic> user;
  int f = 0;
  getData() async {
    var token = await storage.read(key: "jwt");
    user = parseJwt(token!);
    setState(() {
      user = user;
      f = 1;
    });
  }

  Map<String, dynamic> parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('invalid token');
    }

    final payload = _decodeBase64(parts[1]);
    final payloadMap = json.decode(payload);
    if (payloadMap is! Map<String, dynamic>) {
      throw Exception('invalid payload');
    }

    return payloadMap;
  }

  String _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Illegal base64url string!"');
    }

    return utf8.decode(base64Url.decode(output));
  }

  logOut() async {
    await storage.deleteAll();
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/welcome', (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  bool val = false;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.indigo,
        child: ListView(
          children: [
            DrawerHeader(
                decoration: BoxDecoration(color: Colors.amber[200]),
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                child: UserAccountsDrawerHeader(
                  accountName: Text(
                    f == 1 ? user["username"].toString() : "Loading",
                    style: const TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  accountEmail: Text(
                      f == 1 ? user["email"].toString() : "Loading",
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16)),
                )),
            ListTile(
              onTap: () {
                logOut();
              },
              leading: const Icon(
                Icons.logout,
                color: Colors.white,
              ),
              title: const Text(
                "LogOut",
                textScaleFactor: 1.4,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            SwitchListTile(
              activeColor: Colors.amber,
              title: Text("Dark theme",
                  textScaleFactor: 1.4, style: TextStyle(color: Colors.white)),
              value: val,
              onChanged: (value) {
                setState(() {
                  val = !val;
                });
                setState(() {
                  setDark();
                });
                print("$dark");
              },
            ),
            const ListTile(
              leading: const Icon(
                Icons.info,
                color: Colors.white,
              ),
              title: const Text(
                "Made by Sumit Athani",
                textScaleFactor: 1,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                "Reach us at sstech.apps.mobile@gmail.com",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
