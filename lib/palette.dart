//palette.dart
import 'package:flutter/material.dart';

class Palette {
  static const MaterialColor light = MaterialColor(
    0xffb71c1c,
    <int, Color>{
      50: Colors.redAccent,
      100: Colors.redAccent,
      200: Colors.redAccent,
      300: Colors.redAccent,
      400: Colors.redAccent,
      500: Colors.redAccent,
      600: Colors.redAccent,
      700: Colors.redAccent,
      800: Colors.redAccent,
      900: Colors.redAccent,
    },
  );
  static const MaterialColor lToDark = MaterialColor(
    0x4134E,
    <int, Color>{
      50: Color.fromRGBO(139, 196, 222, .1),
      100: Color.fromRGBO(139, 196, 222, .2),
      200: Color.fromRGBO(139, 196, 222, .3),
      300: Color.fromRGBO(139, 196, 222, .4),
      400: Color.fromRGBO(139, 196, 222, .5),
      500: Color.fromRGBO(139, 196, 222, .6),
      600: Color.fromRGBO(139, 196, 222, .7),
      700: Color.fromRGBO(139, 196, 222, .8),
      800: Color.fromRGBO(139, 196, 222, .9),
      900: Color.fromRGBO(139, 196, 222, 1),
    },
  );
}
