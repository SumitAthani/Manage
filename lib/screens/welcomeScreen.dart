import 'package:flutter/material.dart';
import 'package:manage/widgets/button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: DecoratedBox(
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/welcome.png"),
                fit: BoxFit.cover),
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Image.asset("assets/images/logo2.png"),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: MyButton(
                          onTap: () {
                            Navigator.pushNamed(context, "/signup");
                          },
                          title: "SIGNUP",
                          Color: const Color.fromRGBO(198, 184, 149, 1),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: MyButton(
                            onTap: () {
                              Navigator.pushNamed(context, "/login");
                            },
                            title: "LOGIN",
                            Color: const Color.fromRGBO(180, 155, 125, 1)),
                      )
                    ],
                  ),
                ),
              )
            ],
          )),
    );
  }
}
