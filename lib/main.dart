import 'package:flutter/material.dart';

import 'globals.dart';
import 'universitylist.dart';

final ThemeData _kTheme = new ThemeData(
  primarySwatch: Colors.indigo
);

void main() {
  runApp(new MaterialApp(
    title: 'LaundryAlert',
    routes: kRoutes,
    theme: _kTheme,
    home: new UniversityList()
  ));
}
