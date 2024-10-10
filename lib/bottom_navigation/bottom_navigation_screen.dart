import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:reward_hub_customer/Utils/DeviceInfo.dart';
import 'package:reward_hub_customer/Utils/constants.dart';
import 'package:reward_hub_customer/search/search_screen.dart';
import 'package:reward_hub_customer/search/search_screen2.dart';
import 'package:reward_hub_customer/store/store_screen.dart';
import 'package:reward_hub_customer/utils/SharedPrefrence.dart';
import 'package:reward_hub_customer/wallet/wallet_screen.dart';
import 'package:reward_hub_customer/wallet/wallet_screen2.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../Utils/urls.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  int index = 1;
  DeviceInfo? deviceInfo;
  String? currentDeviceId;
  String? bizatomVersion;

  @override
  void initState() {
    super.initState();
    _initDeviceInfo();
    _checkForUpdates();
  }

  Future<void> _initDeviceInfo() async {
    deviceInfo = await collectDeviceInfo();
    currentDeviceId = deviceInfo?.deviceId;
    setState(() {});
  }

  Future<void> _checkForUpdates() async {
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
        bizatomVersion = data['BizatomVersion'];

        // Check if the versions match
        PackageInfo packageInfo = await PackageInfo.fromPlatform();
        if (bizatomVersion != packageInfo.version) {
          showUpdateBottomSheet(context);
        }
      }
    } else {
      // Handle error response
      print('Failed to load config');
    }
  }

  void showUpdateBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 20),
              Icon(
                Icons.system_update,
                color: Constants().appColor,
                size: 50,
              ),
              SizedBox(height: 20),
              Text(
                'Update Available',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'A new version of the app is available. Please update to the latest version for the best experience.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  const url =
                      'https://play.google.com/store/apps/details?id=com.Bizatom.app';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url));
                  } else {
                    print('Could not launch $url');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants().appColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.update, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Update Now',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Later',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      Icon(
        Icons.search,
        color: index == 0 ? Constants().appColor : Colors.black,
        size: 26,
      ),
      Image.asset(
        index == 1
            ? "assets/images/wallet_orenge.png" // Selected icon
            : "assets/images/wallet_black.png",
        fit: BoxFit.cover, // Unselected icon
        height: 24.h,
        width: 24.w,
      ),
      Image.asset(
        index == 2
            ? "assets/images/category_orange.png" // Selected icon
            : "assets/images/category_black.png",
        fit: BoxFit.cover, // Unselected icon
        height: 24.h,
        width: 24.w,
      ),
    ];
    return Container(
      color: Color.fromARGB(255, 218, 223, 227),
      child: SafeArea(
        top: false,
        child: Scaffold(
          extendBody: true,
          body: _buildPage(index),
          bottomNavigationBar: CurvedNavigationBar(
            height: 60,
            color: Color.fromARGB(255, 218, 223, 227),
            backgroundColor: Colors.transparent,
            animationCurve: Curves.easeInOut,
            animationDuration: Duration(milliseconds: 300),
            index: index,
            items: items.map((widget) {
              return Container(
                child: widget,
                padding: EdgeInsets.all(5), // Adjust the padding as needed
              );
            }).toList(),
            onTap: (int tappedIndex) {
              setState(() {
                index = tappedIndex;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return SearchScreen2();
      case 1:
        return WalletScreen2();
      case 2:
        return StoreScreen(key: UniqueKey());
      default:
        return WalletScreen2();
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
