import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pinput/pinput.dart';
import 'package:reward_hub_customer/Utils/SharedPrefrence.dart';
import 'package:reward_hub_customer/Utils/constants.dart';
import 'package:reward_hub_customer/Utils/toast_widget.dart';
import 'package:reward_hub_customer/login/api_service.dart';
import 'package:reward_hub_customer/register/create_password_screen.dart';

import '../login/forgot_password_screen.dart';

class OTPScreen extends StatefulWidget {
  var phone = "";
  var otp = "";
  var fullName = "";
  var email = "";
  var address1 = "";
  var address2 = "";
  var pinCode = "";
  var file = "";
  var deviceID = "";
  var cardNumber = "";
  var from_screen = "";
  var otpType = "";
  late DateTime otpGenerationTime;
  OTPScreen(
      this.phone,
      this.otp,
      this.fullName,
      this.email,
      this.address1,
      this.address2,
      this.pinCode,
      this.file,
      this.deviceID,
      this.cardNumber,
      this.from_screen,
      this.otpType) {
    otpGenerationTime = DateTime.now();
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return OTPScreenState();
  }
}

class OTPScreenState extends State<OTPScreen> {
  int secondsRemaining = 120;
  bool enableResend = false;
  late Timer timer;
  ApiService apiService = ApiService();

  var pinPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (secondsRemaining != 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        setState(() {
          enableResend = true;
        });
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    DateTime currentTime = DateTime.now();
    DateTime newTime = currentTime.add(Duration(minutes: 2));

    String formattedTime = newTime.toIso8601String();

// SharedPrefrence().setOtpTime(formattedTime);
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                flex: 0,
                child: Container(
                  height: 50,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Image.asset(
                            "assets/images/ic_back_img.png",
                          ),
                        ),
                      )
                    ],
                  ),
                )),
            Expanded(
              flex: 1,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/ic_logo.png",
                    height: 91.h,
                    width: 201.w,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 25.0),
                    child: Text(
                      "Verify your phone number",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Enter OTP code sent to - ${widget.phone}",
                      style: const TextStyle(
                          color: Color(0xFF828282),
                          fontSize: 15,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: buildPinPut(),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, top: 20),
                    child: GestureDetector(
                      onTap: () async {
                        if (pinPhoneController.text.isEmpty) {
                          ToastWidget().showToastError("Please fill OTP");
                        } else if (isOtpExpired()) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Center(child: Text("OTP Expired")),
                                content: Text(
                                    "The OTP has expired. Please request a new one."),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);

                                      // Add logic to handle the expiration, maybe resend OTP or navigate back
                                    },
                                    child: Text("OK"),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (pinPhoneController.text.toString() !=
                            widget.otp) {
                          ToastWidget().showToastError("OTP is incorrect");
                        } else {
                          if (widget.from_screen == "password") {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: ForgotPasswordScreen(
                                        widget.phone, widget.otp)));
                          } else {
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: CreatePasswordScreen(
                                        widget.fullName,
                                        widget.phone,
                                        widget.email,
                                        widget.address1,
                                        widget.address2,
                                        widget.pinCode,
                                        widget.file,
                                        widget.deviceID,
                                        widget.cardNumber)));
                          }
                        }
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Constants().appColor),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text(
                            "VERIFY",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 10)),
                  // Text("Resend Otp in:($secondsRemaining)"),
                  Text(
                      "Resend Otp in:(${formatRemainingTime(secondsRemaining)})"),

                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Text(
                      "Didn’t received OTP code?",
                      style: const TextStyle(
                          color: Color(0xFF828282),
                          fontSize: 15,
                          fontWeight: FontWeight.normal),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      enableResend ? _resendCode() : null;
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5.0),
                      child: Text(
                        "Resend Code",
                        style: TextStyle(
                            color: enableResend
                                ? Constants().appColor
                                : Constants().grayColor,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildPinPut() {
    final defaultPinTheme = PinTheme(
      width: 49.w,
      height: 52.h,
      textStyle: TextStyle(
          fontSize: 20,
          color: Constants().appColor,
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: Constants().appColor),
      borderRadius: BorderRadius.circular(10),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: const Color.fromRGBO(234, 239, 243, 1),
      ),
    );

    return Pinput(
      controller: pinPhoneController,
      length: 6,
      keyboardType: TextInputType.number,
      defaultPinTheme: defaultPinTheme,
      focusedPinTheme: focusedPinTheme,
      submittedPinTheme: submittedPinTheme,
      validator: (s) {
        return s == widget.otp ? null : 'OTP is incorrect';
      },
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
      onCompleted: (pin) => debugPrint(pin),
    );
  }

  void _resendCode() {
    setState(() {
      print("Resend Button Clicked");
      secondsRemaining = 30;
      enableResend = false;
      pinPhoneController.clear();
      if (widget.from_screen == 'password') {
        apiService.getResetOtp(
            widget.phone, context, widget.from_screen, widget.otpType);
      } else {
        apiService.getOtp(
            widget.phone,
            context,
            widget.from_screen,
            widget.otpType,
            widget.fullName,
            widget.email,
            widget.address1,
            widget.address2,
            widget.pinCode,
            widget.file,
            widget.deviceID,
            widget.cardNumber);
      }
    });
  }

  // Resnd OTP

  bool isOtpExpired() {
    DateTime currentTime = DateTime.now();
    DateTime expirationTime =
        widget.otpGenerationTime.add(Duration(minutes: 2));
    return currentTime.isAfter(expirationTime);
  }

  String formatRemainingTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;

    String minutesStr = minutes < 10 ? '0$minutes' : '$minutes';
    String secondsStr =
        remainingSeconds < 10 ? '0$remainingSeconds' : '$remainingSeconds';

    return '$minutesStr:$secondsStr';
  }
}
