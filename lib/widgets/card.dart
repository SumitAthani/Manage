import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  const MyCard(
      {Key? key,
      required this.title,
      this.description = "description",
      this.fontsize = 18,
      required this.onTap})
      : super(key: key);

  final String title;
  final double fontsize;
  final String description;

  final void Function() onTap;
  @override
  Widget build(BuildContext context) {
    return Card(
      key: key,
      clipBehavior: Clip.hardEdge,
      color: Colors.amber,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))),
      child: InkWell(
        splashColor: Colors.red,
        onTap: onTap,
        // onTapCancel: onTap,
        onDoubleTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                ),
              ),
              if (description != "")
                SizedBox(
                  height: 10,
                ),
              if (description != "")
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.cyan,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
