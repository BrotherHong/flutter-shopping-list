import 'package:flutter/material.dart';

class MyColor {
  static const Color main = Color(0xFF89b4e8);

  static MaterialColor swatchColor = MaterialColor(
    main.value,
    const <int, Color>{
      50: Color(0xFFc4daf4),
      100: Color(0xFFb8d2f1),
      200: Color(0xFFaccbef),
      300: Color(0xFFa1c3ed),
      400: Color(0xFF95bcea),
      500: Color(0xFF89b4e8),
      600: Color(0xFF7ba2d1),
      700: Color(0xFF6e90ba),
      800: Color(0xFF607ea2),
      900: Color(0xFF526c8b),
    },
  );
}
