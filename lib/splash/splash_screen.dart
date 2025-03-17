import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:reward_hub_customer/Utils/DeviceInfo.dart';
import 'package:reward_hub_customer/Utils/urls.dart';
import 'package:reward_hub_customer/provider/user_data_provider.dart';
import '../Utils/SharedPrefrence.dart';
import '../Utils/constants.dart';
import '../bottom_navigation/bottom_navigation_screen.dart';
import '../login/login_screen.dart';
import '../wallet/wallet_screen.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  bool islogged = false;
  bool isActivated = false;
  String? ServerDeviceID = "";
  DeviceInfo? deviceInfo;
  String? currentDeviceId = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    islogged = SharedPrefrence().getLoggedIn();
    // SharedPrefrence().setActivated(true);
    isActivated = SharedPrefrence().getActivated();
    var userProfilePhoto = SharedPrefrence().getUserProfilePhoto() ??
        "assets/images/ic_profile.png";
    if (userProfilePhoto == null) {
      SharedPrefrence().setUserProfilePhoto("assets/images/ic_profile.png");
    } else {
      SharedPrefrence().getUserProfilePhoto();
    }
    _initDeviceInfo();
    deviceIDCheckUp();
    startTime();
  }

  Future<void> _initDeviceInfo() async {
    deviceInfo = await collectDeviceInfo();
    currentDeviceId = deviceInfo?.deviceId;
    setState(() {});
  }

  Future<void> deviceIDCheckUp() async {
    final response = await http.get(
      Uri.parse(Urls.getAppConfig),
      headers: {
        'Token': Constants().token,
        'customerID': SharedPrefrence().getCustomerId().toString(),
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['isSuccess']) {
        final data = responseData['data'][0];
        ServerDeviceID = data['DeviceID'];
        if (ServerDeviceID != currentDeviceId) {
          islogged = false;
        }
      }
    } else {
      // Handle error response
      print('Failed to load config');
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Center(
                child: Image.asset(
                  "assets/images/ic_logo.png",
                  height: 91.w,
                  width: 201.h,
                  /*style: TextStyle(
                  color: AppColor.app_btn_color,
                  fontWeight: FontWeight.bold,
                  fontSize: 25
                ),*/
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  startTime() async {
    var _duration = Duration(seconds: 3);
    return Timer(_duration, navigationPage);
  }

  void navigationPage() {
    // if (islogged) {
    if (islogged) {
      Navigator.pop(context, true);
      //Navigator.push(context, SlideRightRoute(page: IntroScreen()));
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft,
              child: BottomNavigationScreen()));
    } else {
      Navigator.pop(context, true);
      //Navigator.push(context, SlideRightRoute(page: IntroScreen()));
      Navigator.push(
          context,
          PageTransition(
              type: PageTransitionType.rightToLeft,
              child: LoginScreen(isActivated: isActivated)));
    }
  }

  Future<DeviceInfo> collectDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String deviceId = await SharedPrefrence().getDeviceID();

    String? model;
    String? osVersion;
    String? manufacture;
    String? brand;
    String? serialNo;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = deviceId;
      model = androidInfo.model;
      manufacture = androidInfo.manufacturer;
      brand = androidInfo.brand;
      serialNo = androidInfo.serialNumber;
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
      Brand: brand,
      SerialNo: serialNo,
    );
  }
}
