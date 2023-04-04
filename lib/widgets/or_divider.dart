import 'package:flutter/material.dart';

Widget orDivider(BuildContext context) {
  return Stack(
    children: [
      Center(
        child: Divider(
          thickness: 2,
          height: 20,
          indent: 50,
          endIndent: 50,
          color: Theme.of(context).colorScheme.surfaceTint,
        ),
      ),
      Center(
        child: Container(
          color: Theme.of(context).colorScheme.background,
          width: 26,
          child: Text(
            "or",
            style: TextStyle(
              color: Theme.of(context).colorScheme.surfaceTint,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ],
  );
}
