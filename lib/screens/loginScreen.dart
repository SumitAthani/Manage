import "package:flutter/material.dart";
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:manage/api/routeUrls.dart';
import "dart:convert";
import 'package:manage/navigation/routes.dart';

var url = Uri.parse(Urls.login);

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String name = "";
  bool changeButton = false;
  bool navigate = false;
  final _formkey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  moveToHome(BuildContext context) async {
    print(_formkey.currentContext);
    if (_formkey.currentState!.validate()) {
      // print(_formkey.currentState);
      var body = {
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

      var data = jsonDecode(r.body);

      if (r.statusCode >= 300 || r.statusCode < 200) {
        print("herer");
        var error = data["message"];
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text("Error Loging In"),
              content: Text("Username/or password wrong"),
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
              const Text(
                "Login Page",
                style: TextStyle(
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
                          keyboardType: TextInputType.emailAddress,
                          controller: emailController,
                          validator: (value) {
                            RegExp emailValid = RegExp(
                                r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
                            if (value!.isEmpty) {
                              return "Email Cannot be Empty";
                            } else if (!emailValid.hasMatch(value.trim())) {
                              print(!emailValid.hasMatch(value));
                              print(value);
                              print("dfsad");
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
                            if (value!.isEmpty) {
                              return "Password cannot be Empty";
                            } else if (value.length < 4) {
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
                                      "LOGIN",
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
