import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reward_hub_customer/Utils/DeviceInfo.dart';
import 'package:reward_hub_customer/Utils/SharedPrefrence.dart';
import 'package:reward_hub_customer/Utils/toast_widget.dart';

import '../Utils/constants.dart';
import 'api_service.dart';

class CreatePasswordScreen extends StatefulWidget {
  var fullName = "";
  var mobileNumber = "";
  var email = "";
  var address1 = "";
  var address2 = "";
  var pinCode = "";
  var file = "";
  var deviceID = "";
  var cardNumber = "";

  CreatePasswordScreen(
      this.fullName,
      this.mobileNumber,
      this.email,
      this.address1,
      this.address2,
      this.pinCode,
      this.file,
      this.deviceID,
      this.cardNumber);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return CreatePasswordScreenState();
  }
}

class CreatePasswordScreenState extends State<CreatePasswordScreen> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  DeviceInfo? deviceInfo;
  String? CurrentdeviceId;
  dynamic? customerId;
  dynamic? customerDeviceId;

  Future<void> _initDeviceInfo() async {
    deviceInfo = await collectDeviceInfo();
    CurrentdeviceId = deviceInfo?.deviceId;
    setState(() {});
  }

  Future<DeviceInfo> collectDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String deviceId = await SharedPrefrence().generateDeviceID();

    String? model;
    String? osVersion;
    String? manufacture;
    String? Brand;
    String? SerialNo;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = deviceId;
      model = androidInfo.model;
      manufacture = androidInfo.manufacturer;
      Brand = androidInfo.brand;
      SerialNo = androidInfo.serialNumber;

      osVersion = androidInfo.version.release;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = deviceId;
      model = iosInfo.utsname.machine;
      osVersion = iosInfo.systemVersion;
    }

    return DeviceInfo(
        deviceId: deviceId!,
        model: model!,
        osVersion: osVersion!,
        appName: packageInfo.appName,
        packageName: packageInfo.packageName,
        version: packageInfo.version,
        buildNumber: packageInfo.buildNumber,
        manufacture: manufacture,
        Brand: Brand,
        SerialNo: SerialNo);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
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
                          child: Image.asset("assets/images/ic_back_img.png"),
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
                  Padding(
                    padding: EdgeInsets.only(top: 31.0.h),
                    child: Text(
                      "Create a Password",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 20.w, right: 20.w, bottom: 0.h, top: 15.h),
                    child: SizedBox(
                      width: double.infinity,
                      height: 51.h,
                      child: TextField(
                        keyboardType: TextInputType.text,
                        controller: passwordController,
                        enabled: true,
                        obscureText: true,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFFE5E7E9), width: 0.0),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFE5E7E9)),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                            ),
                            filled: true,
                            contentPadding:
                                EdgeInsets.only(left: 10.w, bottom: 5.h),
                            hintStyle: TextStyle(fontSize: 15.sp),
                            hintText: "Password",
                            fillColor: Color(0xFFE5E7E9)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 20.w, right: 20.w, bottom: 0.h, top: 10.h),
                    child: SizedBox(
                      width: double.infinity,
                      height: 51.h,
                      child: TextField(
                        keyboardType: TextInputType.text,
                        controller: confirmPasswordController,
                        enabled: true,
                        obscureText: true,
                        decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFFE5E7E9), width: 0.0),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFFE5E7E9)),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                            ),
                            filled: true,
                            contentPadding:
                                EdgeInsets.only(left: 10.w, bottom: 5.h),
                            hintStyle: TextStyle(fontSize: 15.sp),
                            hintText: "Confirm Password",
                            fillColor: Color(0xFFE5E7E9)),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.only(left: 20.w, right: 20.w, top: 20.h),
                    child: GestureDetector(
                      onTap: () async {
                        if (passwordController.text.isEmpty) {
                          ToastWidget().showToastError("Please fill Password");
                        } else if (confirmPasswordController.text.isEmpty) {
                          ToastWidget()
                              .showToastError("Please confirm Password");
                        } else if (passwordController.text !=
                            confirmPasswordController.text) {
                          ToastWidget().showToastError("Password mismatch");
                        } else {
                          DeviceInfo deviceInfo = await collectDeviceInfo();
                          ApiServiceRegister().postRegister(
                              // Fahal Salam
                              widget.fullName,
                              widget.mobileNumber,
                              widget.email,
                              widget.address1,
                              widget.address2,
                              widget.pinCode,
                              widget.file,
                              widget.deviceID,
                              widget.cardNumber,
                              passwordController.text.toString(),
                              context,
                              deviceInfo);
                        }
                      },
                      child: Container(
                        height: 51.h,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Constants().appColor),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "SAVE PASSWORD",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
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
}
