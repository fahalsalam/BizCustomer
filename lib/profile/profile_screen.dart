import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:reward_hub_customer/Utils/SharedPrefrence.dart';
import 'package:reward_hub_customer/Utils/constants.dart';
import 'package:reward_hub_customer/login/login_screen.dart';
import 'package:reward_hub_customer/profile/EncashmentScreen.dart';
import 'package:reward_hub_customer/profile/api_service.dart';
import 'package:reward_hub_customer/profile/edit_profile_screen.dart';
import 'package:reward_hub_customer/profile/encashment_report.dart';
import 'package:reward_hub_customer/provider/user_data_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:http/http.dart' as http;

import '../Utils/urls.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return ProfileScreenState();
  }
}

class ProfileScreenState extends State<ProfileScreen> {
  ApiService apiService = ApiService();
  String profilePic = "";
  String terms_CoditionUrl = "";
  String supportUrl = "";

  @override
  void initState() {
    super.initState();
    Provider.of<UserData>(context, listen: false)
        .setUserProfilePhotoData(SharedPrefrence().getUserProfilePhoto());
    internalUrls();
  }

  Future<void> internalUrls() async {
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
        terms_CoditionUrl = data['Terms_Condition_Url'];
        supportUrl = data['Support_Url'];
      }
    } else {
      // Handle error response
      print('Failed to load config');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserData>(
      builder: (context, userData, _) {
        String profilePhotoPath = SharedPrefrence().getUserProfilePhoto();
        File profilePhotoFile = File(profilePhotoPath);

        Widget profileImage() => FullScreenWidget(
              disposeLevel: DisposeLevel.High,
              child: Hero(
                tag: "profile_image",
                child: profilePhotoFile.existsSync()
                    ? ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(49)),
                        child: Image.file(
                          profilePhotoFile,
                          height: 98,
                          width: 98,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Image.asset(
                        "assets/images/ic_profile.png",
                        height: 98,
                        width: 98,
                        fit: BoxFit.cover,
                      ),
              ),
            );

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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 0,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child:
                                  Image.asset("assets/images/ic_back_img.png"),
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "PROFILE",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 0,
                          child: SizedBox(
                            height: 37,
                            width: 37,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 0,
                  child: Container(
                    height: 250,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        profileImage(),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, top: 8, right: 8),
                          child: Align(
                            alignment: Alignment.center,
                            child: Consumer<UserData>(
                                builder: (context, userData, _) {
                              return Text(
                                "${SharedPrefrence().getUsername()}",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              );
                            }),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            SharedPrefrence().getUserPhone(),
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => EditProfileScreen()));
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 15),
                              height: 40,
                              width: 137,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Constants().appColor),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "EDIT PROFILE",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: const BoxDecoration(
                        image: DecorationImage(
                            image:
                                AssetImage("assets/images/ic_profile_bg.png"),
                            fit: BoxFit.cover)),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding:
                              EdgeInsets.only(left: 20, right: 20, top: 20),
                          child: GestureDetector(
                            onTap: () {
                              _launchInWebView(Uri.parse(terms_CoditionUrl));
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  flex: 0,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Image.asset(
                                      "assets/images/ic_profile_item_icon.png",
                                      height: 24,
                                      width: 24,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 15.0, right: 15),
                                      child: Text(
                                        "Terms and conditions",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      "assets/images/ic_profile_arrow_forward.png",
                                      height: 24,
                                      width: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 20, right: 20, top: 20),
                          child: GestureDetector(
                            onTap: () {
                              _launchInWebView(Uri.parse(supportUrl));
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  flex: 0,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Image.asset(
                                      "assets/images/ic_profile_item_icon.png",
                                      height: 24,
                                      width: 24,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 15.0, right: 15),
                                      child: Text(
                                        "Support",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      "assets/images/ic_profile_arrow_forward.png",
                                      height: 24,
                                      width: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Spacer(),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 20, right: 20, top: 20),
                          child: GestureDetector(
                            onTap: () {
                              _showDeleteConfirmation(context);
                            },
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  flex: 0,
                                  child: Padding(
                                    padding: EdgeInsets.only(left: 10),
                                    child: Image.asset(
                                      "assets/images/ic_profile_item_icon.png",
                                      height: 24,
                                      width: 24,
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  flex: 1,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 15.0, right: 15),
                                      child: Text(
                                        "Delete Account",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 0,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      "assets/images/ic_profile_arrow_forward.png",
                                      height: 24,
                                      width: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding:
                              EdgeInsets.only(left: 20, right: 20, bottom: 20),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                flex: 0,
                                child: Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Image.asset(
                                    "assets/images/ic_profile_item_icon.png",
                                    height: 24,
                                    width: 24,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: 15.0, right: 15),
                                    child: GestureDetector(
                                      onTap: () {
                                        _handleNewVendorDialog();
                                      },
                                      child: Text(
                                        "Logout",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: FutureBuilder<PackageInfo>(
                                  future: PackageInfo.fromPlatform(),
                                  builder: (context, snapshot) {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.done:
                                        return Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Text(
                                            'Version: ${snapshot.data!.version}',
                                          ),
                                        );
                                      default:
                                        return const SizedBox();
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _launchInWebView(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _deleteAccount() async {
    try {
      EasyLoading.show(
          status: "Please Wait...", maskType: EasyLoadingMaskType.black);

      final response = await http.put(
        Uri.parse(Urls.postAccountDeactivate),
        headers: {
          'Token': Constants().token,
          'customerID': SharedPrefrence().getCustomerId().toString(),
        },
      );

      EasyLoading.dismiss();

      if (response.statusCode == 200) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false);
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to delete account")),
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text(
              "Are you sure you want to delete your account? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteAccount();
              },
              child: Text("Yes", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> _handleNewVendorDialog() {
    return showDialog(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Center(child: Text("Log Out")),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  height: 50.h,
                  width: 104.w,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Constants().appColor),
                  child: TextButton(
                    onPressed: () {
                      SharedPrefrence().setLoggedIn(false);
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                          (route) => false);
                    },
                    child: Text(
                      "Yes",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                SizedBox(
                  width: 5.w,
                ),
                Container(
                  height: 50.h,
                  width: 104.w,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "No",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
