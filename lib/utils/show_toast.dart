import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class ShowToast {
  static void success(String message, BuildContext context) {
    Flushbar(
      message: message,
      isDismissible: true,
      duration: Duration(milliseconds: 800),
      flushbarStyle: FlushbarStyle.FLOATING,
      icon: Icon(Icons.check, color: Colors.white),
      margin: EdgeInsets.all(47.0),
      borderRadius: BorderRadius.circular(8),
      backgroundColor: Colors.green,
    ).show(context);
  }

  static void error(String message, BuildContext context) {
    Flushbar(
      message: message,
      duration: Duration(seconds: 1),
      flushbarStyle: FlushbarStyle.FLOATING,
      icon: Icon(Icons.error, color: Colors.white),
      margin: EdgeInsets.all(47.0),
      borderRadius: BorderRadius.circular(8),
      backgroundColor: Colors.redAccent,
    ).show(context);
  }
}
