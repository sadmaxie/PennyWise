import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast(String message, {Color? color}) {
  Fluttertoast.showToast(
    msg: message,
    backgroundColor: color ?? Colors.grey[800],
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    textColor: Colors.white,
    fontSize: 14,
  );
}
