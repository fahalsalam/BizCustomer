import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneDialer {
  static const MethodChannel _channel = MethodChannel('phone_dialer');

  static Future<void> makeCall(BuildContext context, String phoneNumber) async {
    try {
      await _channel.invokeMethod('makeCall', {'phoneNumber': phoneNumber});
    } on PlatformException catch (e) {
      _showErrorSnackbar(context, e.message ?? "Failed to make a call");
    }
  }

  static void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
