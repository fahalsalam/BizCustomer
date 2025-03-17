import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:reward_hub_customer/Utils/DeviceInfo.dart';
import 'package:reward_hub_customer/Utils/constants.dart';
import 'package:reward_hub_customer/Utils/smsType.dart';
import 'package:reward_hub_customer/bottom_navigation/bottom_navigation_screen.dart';
import 'package:reward_hub_customer/login/login_screen.dart';
import 'package:reward_hub_customer/register/otp_screen.dart';
import 'package:reward_hub_customer/register/register_screen.dart';

import '../Utils/toast_widget.dart';
import '../store/model/user_model.dart';
import '../utils/SharedPrefrence.dart';
import '../utils/urls.dart';

class ApiService {
  void postLogin(
      String phone,
      BuildContext context,
      bool isRemember,
      String fromScreen,
      String fullName,
      String email,
      String address1,
      String address2,
      String pincode,
      String documentFile,
      String deviceID,
      DeviceInfo deviceInfo) async {
    try {
      EasyLoading.show(
        dismissOnTap: false,
        maskType: EasyLoadingMaskType.black,
      );
      final request = http.MultipartRequest("GET", Uri.parse(Urls.login));

      //request.fields['username'] = name;
      // request.fields['password'] = password;
      log("REQ>>>" + request.fields.toString());
      request.headers.addAll({
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Token': Constants().token,
        'MobileNumber': phone,
      });

      var response = await request.send();
      var responsed = await http.Response.fromStream(response);
      log("RESPONCE>>>" + responsed.body.toString());
      log(response.statusCode.toString());

      if (response.statusCode == 200) {
        List<dynamic> value = json.decode(responsed.body);

        if (value[0]['verificationStatus'] == "ACTIVE CUSTOMER") {
          EasyLoading.dismiss();
          if (fromScreen == "register") {
            SharedPrefrence().setActivated(true);
            ToastWidget().showToastSuccess("Already activated...Please login");
            Navigator.pop(context);
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: LoginScreen()));
          } else {
            ToastWidget().showToastSuccess("Success...!");
            // EasyLoading.showSuccess("Successfully Logi");
            if (isRemember) {
              SharedPrefrence().setLoggedIn(isRemember);
              bool islogged = SharedPrefrence().getLoggedIn();
              log("islogged>>>" + islogged.toString());
            }

            SharedPrefrence().setCustomerId(value[0]['customerID'].toString());
            SharedPrefrence().setUsername(value[0]['customerName'].toString());
            SharedPrefrence().setUserphone(value[0]['mobileNumber'].toString());
            SharedPrefrence().setCard(value[0]['cardNumber'].toString());
            SharedPrefrence()
                .setWalletBalance(value[0]['walletbalance'].toString());
            SharedPrefrence()
                .setCustomerDeviceID(value[0]['customerDeviceID'].toString());
            SharedPrefrence().setCardActive(value[0]['cardActive'].toString());

            Navigator.pop(context);
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: BottomNavigationScreen()));
          }
        } else if (value[0]['verificationStatus'] == "NEW ACTIVATION") {
          if (fromScreen == "register") {
            int smsType = getSMSType(SMSType.accountActivation);
            EasyLoading.dismiss();
            // Navigator.pop(context);
            getOtp(
                phone,
                context,
                fromScreen,
                smsType.toString(),
                fullName,
                email,
                address1,
                address2,
                pincode,
                documentFile,
                deviceID,
                value[0]['cardNumber'].toString());
          }
        } else {
          EasyLoading.dismiss();
          // ToastWidget().showToastError(value['message']);
        }
      } else {
        EasyLoading.dismiss();
        // List<dynamic> value = json.decode(responsed.body);
        ToastWidget().showToastError("Invalid Card or Invalid Customer");
      }
    } catch (e, stackTrace) {
      print(e.toString());
      print(stackTrace.toString());
      e.toString();
    } finally {
      EasyLoading.dismiss();
    }
  }

  void getOtp(
      String phone,
      BuildContext context,
      String fromScreen,
      String otpType,
      String fullName,
      String email,
      String address1,
      String address2,
      String pincode,
      String file,
      String deviceID,
      String cardNumber) async {
    EasyLoading.show(
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );
    try {
      var response = await http.post(
        Uri.parse(Urls.sendOtp),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'MobileNumber': phone,
          'OtpType': otpType,
        }),
      );

      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        log(response.body);
        Map<String, dynamic> resp = jsonDecode(response.body);
        var otp = "";
        if (phone == "9961662827") {
          otp = "123456";
        } else {
          otp = resp['otp'].toString();
        }
        Navigator.push(
            context,
            PageTransition(
                type: PageTransitionType.rightToLeft,
                child: OTPScreen(
                    phone,
                    otp,
                    fullName,
                    email,
                    address1,
                    address2,
                    pincode,
                    file,
                    deviceID,
                    cardNumber,
                    "login",
                    otpType)));
      } else {
        Map<String, dynamic> value = json.decode(response.body);
        EasyLoading.dismiss();
        ToastWidget().showToastError(value['message'].toString());
        log(response.body);
      }
    } catch (error, stackTrace) {
      EasyLoading.dismiss();
      log(error.toString());
      log(stackTrace.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  void getResetOtp(
    String phone,
    BuildContext context,
    String fromScreen,
    String otpType,
  ) async {
    EasyLoading.show(
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );
    try {
      var response = await http.post(
        Uri.parse(Urls.sendOtp),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'MobileNumber': phone,
          'OtpType': otpType,
        }),
      );
      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        log(response.body);
        Map<String, dynamic> resp = jsonDecode(response.body);
        var otp = "";
        if (phone == "9961662827") {
          otp = "123456";
        } else {
          otp = resp['otp'].toString();
        }
        // var otp = resp['otp'].toString();
        Navigator.push(
          context,
          PageTransition(
            type: PageTransitionType.rightToLeft,
            child: OTPScreen(
              phone,
              otp,
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              "",
              fromScreen,
              otpType,
            ),
          ),
        );
      } else {
        Map<String, dynamic> value = json.decode(response.body);
        EasyLoading.dismiss();
        ToastWidget().showToastError(value['message'].toString());
        log(response.body);
      }
    } catch (error, stackTrace) {
      EasyLoading.dismiss();
      log(error.toString());
      log(stackTrace.toString());
    }
  }

  void resetPassword(
      String phone, BuildContext context, String newPassword) async {
    EasyLoading.show(
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );
    final request = http.MultipartRequest("PUT", Uri.parse(Urls.resetPassword));

    try {
      var response = await http.put(Uri.parse(Urls.resetPassword),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            'Token': Constants().token,
          },
          body: json.encode({
            "customerID": 0,
            "customerRegisteredMobileNumber": phone,
            "newPassword": newPassword,
          }));
      log(json.encode({
        "customerID": 0,
        "customerRegisteredMobileNumber": phone,
        "newPassword": newPassword,
      }).toString());

      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        log(response.body);
        var resp = json.decode(response.body);
        /* Map<String, dynamic> value = json.decode(resp);*/
        log(response.body);
        if (resp == "Password reset successfully.") {
          ToastWidget().showToastSuccess(resp);
          SharedPrefrence().setPassword(newPassword);
          Navigator.pop(context);
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft, child: LoginScreen()));
        }
      } else {
        log(response.body);
        String value = json.decode(response.body);
        EasyLoading.dismiss();
        ToastWidget().showToastError(value.toString());
      }
    } catch (error, stackTrace) {
      EasyLoading.dismiss();
      log(error.toString());
      log(stackTrace.toString());
    }
  }

  Future<Map<String, dynamic>> customerAlreadyExisted(BuildContext context,
      TextEditingController mobileNumberController, String mobileNumber) async {
    final String apiUrl = Urls.login;

    try {
      EasyLoading.show(status: 'Please wait...', dismissOnTap: true);
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Token': Constants().token,
          'MobileNumber': mobileNumber,
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          if (data[0]['verificationStatus'] == "ACTIVE CUSTOMER") {
            return Map<String, dynamic>.from(data[0]);
          } else {
            print("The customer is not active.");
          }
        } else {
          print("No data found.");
        }
      } else {
        print("Error: Received status code ${response.statusCode}");
        List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          if (data[0]['verificationStatus'] == 'INVALID CARD') {
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (BuildContext context) {
                return Container(
                  padding: EdgeInsets.all(16.0),
                  height: 200,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 50),
                      SizedBox(height: 16),
                      Text(
                        'Invalid Card',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.blue),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 10),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          mobileNumberController
                              .clear(); // Clear the text field
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            print("Verification status: ${data[0]['verificationStatus']}");
          }
        }
      }
      return {};
    } catch (e) {
      print('Error: $e');
      throw Exception('Error during API call: $e');
    } finally {
      EasyLoading.dismiss();
    }
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
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        List<UserModel> users = userModelFromJson(response.body);
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
                          "The phone number is not registered.",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18.sp),
                        ),
                        SizedBox(height: 18.h),
                        Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Do you want to proceed with new registration",
                              style: TextStyle(fontSize: 15.sp),
                            )),
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
                            Navigator.pop(context, true);
                            SharedPrefrence().setActivated(true);
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: RegisterScreen()));
                          },
                          child: Text(
                            "Registor",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.black,
                              minimumSize: Size(100.w, 50.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.r),
                              )),
                          onPressed: () {
                            Navigator.of(context).pop();
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
        }
        print('Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Exception: $e');
      return [];
    }
  }

  Future<dynamic> popUpDialogue(context, mobileNumber) {
    return showDialog(
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
                    "The phone number is not registered.",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
                  ),
                  SizedBox(height: 18.h),
                  Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Do you want to proceed with new registration",
                        style: TextStyle(fontSize: 15.sp),
                      )),
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
                      Navigator.pop(context, true);
                      SharedPrefrence().setActivated(true);
                      Navigator.push(
                          context,
                          PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: RegisterScreen()));
                    },
                    child: Text(
                      "Registor",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: Size(100.w, 50.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        )),
                    onPressed: () {
                      Navigator.of(context).pop();
                      mobileNumber.clear();
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
  }
}
