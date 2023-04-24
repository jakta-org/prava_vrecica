import 'package:flutter/material.dart';

AppBar normalAppBar(BuildContext context, String name) {
  return AppBar(
    title: Text(
        name,
        style: TextStyle(color: Theme.of(context).colorScheme.onBackground)),
    backgroundColor: Theme.of(context).colorScheme.surface,
    iconTheme: IconThemeData(
      color: Theme.of(context).colorScheme.onBackground,
    ),
    shadowColor: Colors.transparent,
    shape: const Border(bottom: BorderSide(color: Colors.grey, width: 0.1)),
  );
}
