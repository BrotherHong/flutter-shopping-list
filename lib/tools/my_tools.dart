import 'package:flutter/material.dart';

class MyTools {
  static const symbol = "";

  static void info(BuildContext context, String info) {
    // info user message [info] with ok button
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("提示"),
        content: Text(info),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  static String moneySymbol(num moenyNum, {int digits = 0}) {
    int money = moenyNum.toInt();
    return symbol + formatMoney(money.toString());
  }

  static String formatMoney(String moneyString, {int per = 3}) {
    String result = "";
    for (int i = 0; i < moneyString.length; i++) {
      int idx = moneyString.length - i - 1;
      result = moneyString[idx] + (i%3 == 0 && i != 0 ? "," : "") + result;
    }
    return result;
  }

}
