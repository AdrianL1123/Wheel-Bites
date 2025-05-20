import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

class ShowToast {
  void success(String message, BuildContext context) {
    Flushbar(
      message: message,
      duration: Duration(seconds: 2),
      flushbarStyle: FlushbarStyle.FLOATING,
      icon: Icon(Icons.check, color: Colors.white),
      margin: EdgeInsets.all(57.0),
      borderRadius: BorderRadius.circular(8),
      backgroundColor: Colors.green,
    ).show(context);
  }

  void error(String message, BuildContext context) {
    Flushbar(
      message: message,
      duration: Duration(seconds: 2),
      flushbarStyle: FlushbarStyle.FLOATING,
      icon: Icon(Icons.error, color: Colors.white),
      margin: EdgeInsets.all(57.0),
      borderRadius: BorderRadius.circular(8),
      backgroundColor: Colors.redAccent,
    ).show(context);
  }
}
