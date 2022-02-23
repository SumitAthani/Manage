import "package:flutter/material.dart";
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:manage/api/routeUrls.dart';
import "dart:convert";

import 'package:manage/navigation/routes.dart';

var url = Uri.parse(Urls.signup);

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String name = "";
  bool changeButton = false;
  bool navigate = false;
  final _formkey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  moveToHome(BuildContext context) async {
    print(_formkey.currentContext);
    if (_formkey.currentState!.validate()) {
      // print(_formkey.currentState);
      var body = {
        "username": usernameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text.trim()
      };
      var b = jsonEncode(body);
      print(b);

      var r = await http.post(
        url,
        body: b,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      const storage = FlutterSecureStorage();

      print(r.body);
      var data = jsonDecode(r.body);

      print(r.statusCode);
      if (r.statusCode >= 300 || r.statusCode < 200) {
        print("herer");
        var error = data["message"];
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Error Creating Account"),
              content: Text("$error"),
            );
          },
        );
      } else {
        await storage.write(key: "jwt", value: data["token"]);
        setState(() {
          changeButton = true;
        });
      }
      print(r.body);

      var val = await storage.read(key: "jwt");

      print(val);

      // setState(() {
      //   changeButton = true;
      // });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                "Create a account",
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20),
                child: Form(
                  key: _formkey,
                  child: Column(
                    children: [
                      TextFormField(
                          controller: usernameController,
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return "Username Cannot be Empty";
                            } else {
                              return null;
                            }
                          },
                          decoration: const InputDecoration(
                              hintText: "Username...", labelText: "Username")),
                      TextFormField(
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                          validator: (value) {
                            RegExp emailValid = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                            if (value!.trim().isEmpty) {
                              return "Email Cannot be Empty";
                            } else if (!emailValid.hasMatch(value.trim())) {
                              return "Email not valid";
                            } else {
                              return null;
                            }
                          },
                          decoration: const InputDecoration(
                              hintText: "Email...", labelText: "Email")),
                      TextFormField(
                          controller: passwordController,
                          validator: (value) {
                            if (value!.trim().isEmpty) {
                              return "Password cannot be Empty";
                            } else if (value.trim().length < 4) {
                              return "Password length must be atleast 4";
                            } else {
                              return null;
                            }
                          },
                          obscureText: true,
                          decoration: const InputDecoration(
                              hintText: "Password...", labelText: "Password")),
                      const SizedBox(
                        height: 10,
                      ),
                      Material(
                        borderRadius:
                            BorderRadius.circular(changeButton ? 20 : 50),
                        color: Colors.amber,
                        child: InkWell(
                          onTap: () => moveToHome(context),
                          splashColor: Colors.white,
                          child: AnimatedContainer(
                            onEnd: () {
                              Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  MyRoutes.addList,
                                  ModalRoute.withName("/logout"));
                            },
                            duration: const Duration(seconds: 1),
                            curve: Curves.easeIn,
                            width: changeButton ? 40 : 100,
                            height: 40,
                            child: Center(
                              child: changeButton
                                  ? const Icon(
                                      Icons.done,
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      "SIGNUP",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
