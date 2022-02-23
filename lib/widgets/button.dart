import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final Color;

  const MyButton(
      {Key? key,
      this.title = "",
      required this.onTap,
      this.Color = Colors.amber})
      : super(key: key);

  final String title;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.hardEdge,
      color: Color,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.black26,
        child: Container(
          padding: const EdgeInsets.all(13),
          alignment: Alignment.center,
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
