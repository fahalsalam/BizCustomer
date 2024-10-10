import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:reward_hub_customer/Utils/DeviceInfo.dart';
import 'package:reward_hub_customer/Utils/SharedPrefrence.dart';
import 'package:reward_hub_customer/Utils/constants.dart';
import 'package:reward_hub_customer/Utils/toast_widget.dart';
import 'package:reward_hub_customer/Utils/urls.dart';
import 'package:reward_hub_customer/login/api_service.dart';
import 'package:reward_hub_customer/register/register_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Utils/CustomDialogBox.dart';
import '../store/model/user_model.dart';

class LoginScreen extends StatefulWidget {
  bool? isActivated;
  String? mobileNumber;
  String? customerSecret;

  LoginScreen(
      {super.key,
      this.isActivated,
      this.mobileNumber = "",
      this.customerSecret = ""});

  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  TextEditingController mobileNumberControlller = TextEditingController();
  TextEditingController passWordController = TextEditingController();
  TextEditingController dialogueMobileNumberControlller =
      TextEditingController();
  XFile? file = XFile("");
  bool checkValue = false;
  DeviceInfo? deviceInfo;
  String? CurrentdeviceId;
  dynamic? customerId;
  dynamic? customerDeviceId;
  bool _isLoading = true;
  String? bizatomVersion;

  bool? isActivated;

  final FocusNode _passwordFocus = FocusNode();
  final FocusNode mobileNumberFocused = FocusNode();

  @override
  void initState() {
    isActivated = SharedPrefrence().getActivated() ?? false;
    super.initState();

    mobileNumberControlller.text = widget.mobileNumber.toString();
    _initDeviceInfo();
    _checkForUpdates();
  }

  Future<void> _initDeviceInfo() async {
    deviceInfo = await collectDeviceInfo(false);
    CurrentdeviceId = deviceInfo?.deviceId;
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

  void _showBottomSheet(BuildContext context, dynamic deviceId,
      dynamic customerId, dynamic mobileNo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        bool _isLoading = false;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                ),
                padding: EdgeInsets.all(16.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.error,
                      size: 48.sp, // Responsive size
                      color: Colors.red,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'New Device Login Detected',
                      style: TextStyle(
                        fontSize: 20.sp, // Responsive font size
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'You are currently logged in on another device. '
                      'Would you like to deactivate the session on the previous device and continue on this one?',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 16.sp, // Responsive font size
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : () async {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    // Handle Deactivate button press
                                    DeviceInfo deviceInfo =
                                        await collectDeviceInfo(true);
                                    final response = await _deactivateSession(
                                        deviceId,
                                        customerId,
                                        mobileNo,
                                        deviceInfo);
                                    if (response == 200) {
                                      Fluttertoast.showToast(
                                        msg: 'Deactivated Successfully',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                      );
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: 'Failed to Deactivate',
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                      );
                                    }
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    Navigator.of(context).pop();
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red, // background color
                              padding: EdgeInsets.symmetric(
                                vertical: 12.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              _isLoading ? 'Please wait...' : 'Deactivate',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp, // Responsive font size
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                            width: 16.w), // Add some space between the buttons
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              mobileNumberControlller.text = "";
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.grey[300], // background color
                              padding: EdgeInsets.symmetric(
                                vertical: 12.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.sp, // Responsive font size
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<int> _deactivateSession(dynamic deviceId, dynamic customerId,
      dynamic mobileNumber, DeviceInfo deviceInfo) async {
    final url = Uri.parse(Urls.deviceInfoPostAPI);
    final headers = {
      'DeviceID': deviceId.toString(),
      'CustomerID': customerId.toString(),
      'MobileNo': mobileNumber.toString(),
      'Token': Constants().token,
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'DI_DeviceId': deviceInfo.deviceId,
      'DI_Model': deviceInfo.model,
      'DI_OSVersion': deviceInfo.osVersion,
      'DI_AppName': deviceInfo.appName,
      'DI_PackageName': deviceInfo.packageName,
      'DI_Version': deviceInfo.version,
      'DI_BuildNumber': deviceInfo.buildNumber,
      'DI_Manufacture': deviceInfo.manufacture,
      'DI_Brand': deviceInfo.Brand,
      'DI_SerialNo': deviceInfo.SerialNo,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      return response.statusCode;
    } catch (e) {
      print('Error: $e');
      return 500; // Return an error status code if the request fails
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

  Future<List> customerAlreadyExistedCheckForLogin(
    String mobileNumber,
    context,
  ) async {
    final String apiUrl = Urls.login;

    final Map<String, String> headers = {
      'Token': Constants().token,
      'MobileNumber': mobileNumber,
    };

    try {
      EasyLoading.show(
        dismissOnTap: false,
        maskType: EasyLoadingMaskType.black,
      );
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        List<UserModel> users = userModelFromJson(response.body);
        customerDeviceId = users[0].customerDeviceId;
        customerId = users[0].customerID;
        if (customerDeviceId != "" && customerDeviceId != CurrentdeviceId) {
          _showBottomSheet(context, customerDeviceId, customerId, mobileNumber);
          return users;
        }
        return users;
      } else {
        if (response.statusCode == 404 && mobileNumber.length >= 10) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0.r),
                  ),
                  // title: Text("Phone Number Already Activated"),
                  content: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/ic_logo.png",
                          height: 91.h,
                          width: 201.w,
                        ),
                        SizedBox(height: 30.h),
                        Text(
                          "Invalid Card",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.sp),
                        ),
                        SizedBox(height: 18.h),
                      ],
                    ),
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.black,
                              minimumSize: Size(100.w, 50.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.r),
                              )),
                          onPressed: () {
                            Navigator.of(context).pop();
                            mobileNumberControlller.clear();
                          },
                          child: Text(
                            "Ok",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              );
            },
          );
        }
        print('Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception: $e');
      return [];
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> fetchDataAsync() async {
    try {
      EasyLoading.show(
        dismissOnTap: false,
        maskType: EasyLoadingMaskType.black,
      );
      List customerData = await customerAlreadyExistedCheckForLogin(
          mobileNumberControlller.text, context);

      if (customerData.isNotEmpty) {
        String verificationStatus = customerData[0].verificationStatus;
        if (mobileNumberFocused.hasFocus) {
          if (verificationStatus == "NEW ACTIVATION") {
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(25.0),
                ),
              ),
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: 16.h),
                      Image.asset(
                        "assets/images/ic_logo.png",
                        height: 91.h,
                        width: 201.w,
                      ),
                      SizedBox(height: 30.h),
                      Text(
                        "The phone number is not registered.",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(height: 18.h),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Do you want to proceed with new registration?",
                          style: TextStyle(
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              minimumSize: Size(100.w, 50.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.r),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context, true);
                              SharedPrefrence().setActivated(true);
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: RegisterScreen(
                                    mobileNumber: mobileNumberControlller.text,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              "Register",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              minimumSize: Size(100.w, 50.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.r),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                              mobileNumberControlller.clear();
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                );
              },
            );
          } else if (verificationStatus == "INVALID CARD") {
            showCustomBottomSheet(context);
          } else if (verificationStatus == "ACTIVE CUSTOMER") {
            SharedPrefrence().setPassword(customerData[0].customerSecret);
          }
        }
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  void showCustomBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "INVALID CARD",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  minimumSize: Size(100, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: ConstrainedBox(
            constraints:
                BoxConstraints(minHeight: MediaQuery.of(context).size.height),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Spacer(),
                    Center(
                        child: Image.asset(
                      "assets/images/ic_logo.png",
                      height: 91.h,
                      width: 201.w,
                    )),
                    Padding(
                      padding: EdgeInsets.only(top: 26),
                      child: Center(
                        child: Text(
                          "Sign In",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.black),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.h),
                      child: Text(
                          textAlign: TextAlign.center,
                          "Add your phone number. We’ll send you a\nverification code so we know you’re real",
                          style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: Constants().grayColor)),
                    ),

                    /*  const Padding(padding: EdgeInsets.only(top: 20,left: 15,right: 15),
                       child: Center(
                         child: Align(
                           alignment: Alignment.center,
                           child: Text("Add your phone number. We’ll send you a verification code so we know you’re real",
                             style: TextStyle(fontWeight: FontWeight.bold,
                                 fontSize: 15,
                                 color: Color(0xFF828282)),
                           textAlign: TextAlign.center,),
                         ),
                       ),),*/

                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, bottom: 5, top: 20),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              if (value.length == 10) {
                                fetchDataAsync();
                              }
                            });
                          },
                          onEditingComplete: () {
                            fetchDataAsync();
                          },
                          focusNode: mobileNumberFocused,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10)
                          ],
                          keyboardType: TextInputType.number,
                          controller: mobileNumberControlller,
                          // enabled: isActivated ?? false,
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Constants().appColor)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Color(0xFFE5E7E9), width: 0.0),
                              ),
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFFE5E7E9)),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                              filled: true,
                              contentPadding:
                                  EdgeInsets.only(left: 10, bottom: 5),
                              hintStyle: TextStyle(fontSize: 15),
                              hintText: "Mobile Number",
                              fillColor: Color(0xFFE5E7E9)),
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 20, right: 20, top: 10),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: TextField(
                          focusNode: _passwordFocus,
                          keyboardType: TextInputType.text,
                          controller: passWordController,
                          // enabled: isActivated ?? false,
                          obscureText: false,
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: Constants().appColor)),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: _passwordFocus.hasFocus
                                        ? Colors.black
                                        : Color(0xFFE5E7E9),
                                    width: 0.0),
                              ),
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Color(0xFFE5E7E9)),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                              filled: true,
                              contentPadding:
                                  EdgeInsets.only(left: 10, bottom: 5),
                              hintStyle: TextStyle(fontSize: 15),
                              hintText: "Password",
                              fillColor: Color(0xFFE5E7E9)),
                        ),
                      ),
                    ),
                    Visibility(
                      // visible: isActivated ?? false,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 20, right: 20, top: 0.0, bottom: 0.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              flex: 0,
                              child: Checkbox(
                                activeColor: Constants().appColor,
                                checkColor: Colors.black,
                                value: checkValue,
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkValue = value!;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              flex: 0,
                              child: Padding(
                                padding: EdgeInsets.zero,
                                child: Text(
                                  "Remember me",
                                  style: TextStyle(
                                      color: Constants().grayColor,
                                      fontSize: 13),
                                ),
                              ),
                            ),
                            const Expanded(
                              flex: 1,
                              child: SizedBox(),
                            ),
                            Expanded(
                              flex: 0,
                              child: Padding(
                                padding: EdgeInsets.zero,
                                child: GestureDetector(
                                  onTap: () {
                                    //Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: RegisterScreen()));
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return CustomDialogBox(
                                            title: "Custom Dialog Demo",
                                            descriptions:
                                                "Hii all this is a custom dialog in flutter and  you will be use in your flutter applications",
                                            text: "Yes",
                                            img: "",
                                          );
                                        });
                                  },
                                  child: Visibility(
                                    // visible: isActivated ?? false,
                                    child: Text(
                                      "Forget password?",
                                      style: TextStyle(
                                          decoration: TextDecoration.underline,
                                          color: Constants().grayColor,
                                          fontSize: 13),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Visibility(
                      // visible: isActivated ?? false,
                      child: Padding(
                        padding:
                            EdgeInsets.only(left: 20, right: 20, bottom: 0.0),
                        child: GestureDetector(
                          onTap: () async {
                            if (mobileNumberControlller.text.toString() == "") {
                              ToastWidget()
                                  .showToastError("Please fill mobile number");
                            } else if (passWordController.text.isEmpty) {
                              ToastWidget()
                                  .showToastError("Please fill password");
                            } else if (passWordController.text.toString() !=
                                    SharedPrefrence().getPassword()

                                //  SharedPrefrence().getPassword()
                                ) {
                              ToastWidget()
                                  .showToastError("Please check your password");
                            } else {
                              DeviceInfo deviceInfo =
                                  await collectDeviceInfo(false);
                              ApiService().postLogin(
                                  mobileNumberControlller.text.toString(),
                                  // "123",
                                  context,
                                  checkValue,
                                  "login",
                                  passWordController.text.toString() ?? "",
                                  "",
                                  "",
                                  "",
                                  "",
                                  "",
                                  "",
                                  deviceInfo);
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
                                "SIGN IN",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Spacer(),
                    Visibility(
                      // visible: !isActivated! ?? false,
                      child: Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Align(
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) => RegisterScreen()));
                              // Navigator.pop(context, true);
                              // Navigator.push(
                              //     context,
                              //     PageTransition(
                              //         type: PageTransitionType.rightToLeft,
                              //         child: RegisterScreen()));
                            },
                            child: Text(
                              "New User? Sign Up!",
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Constants().grayColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Visibility(
                    //   // visible: !isActivated! ?? false,
                    //   child: Padding(
                    //     padding: EdgeInsets.only(
                    //         left: 20, right: 20, top: 5, bottom: 20),
                    //     child: GestureDetector(
                    //       onTap: () {
                    //         Navigator.pop(context, true);
                    //         Navigator.push(
                    //             context,
                    //             PageTransition(
                    //                 type: PageTransitionType.rightToLeft,
                    //                 child: RegisterScreen()));
                    //       },
                    //       child: Container(
                    //         height: 50,
                    //         decoration: BoxDecoration(
                    //             borderRadius: BorderRadius.circular(15),
                    //             color: Colors.black),
                    //         child: const Align(
                    //           alignment: Alignment.center,
                    //           child: Text(
                    //             "ACTIVATE YOUR CARD",
                    //             style: TextStyle(
                    //                 color: Colors.white,
                    //                 fontSize: 15,
                    //                 fontWeight: FontWeight.bold),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
        /* bottomSheet: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           Padding(padding: EdgeInsets.only(top: 10),
           child: Align(
             alignment: Alignment.center,
             child: Text("Don’t have BRAND Card?",
               style: TextStyle(
                   color: Constants().grayColor,
                   fontSize: 15,
                   fontWeight: FontWeight.bold
               ),),
           ),),
           Padding(padding: EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 20),
             child: Container(
               height: 50,
               decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(15),
                   color: Colors.black
               ),
               child: const Align(
                 alignment: Alignment.center,
                 child: Text("ACTIVATE YOUR CARD",
                   style: TextStyle(color: Colors.white,
                       fontSize: 16,
                       fontWeight: FontWeight.bold),),
               ),
             ),)
         ],
       ),*/
      ),
    );
  }

  Future<DeviceInfo> collectDeviceInfo(bool newDeviceIdGeneration) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String deviceId = "";
    if (newDeviceIdGeneration) {
      deviceId = await SharedPrefrence().generateDeviceID();
    } else {
      deviceId = await SharedPrefrence().getDeviceID();
    }

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
}
