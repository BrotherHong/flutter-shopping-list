import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopping_list/constants/my_color.dart';
import 'package:shopping_list/screens/home.dart';
import 'package:shopping_list/tools/database_helper.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => DatabaseHelper(),
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: MyColor.swatchColor,
        fontFamily: "Ubuntu",
      ),
      title: "購物清單",
      home: const SafeArea(
        child: HomeScreen(),
      ),
    );
  }
}
