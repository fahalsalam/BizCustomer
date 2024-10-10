import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:reward_hub_customer/Utils/constants.dart';
import 'package:reward_hub_customer/register/otp_screen.dart';
import 'package:reward_hub_customer/store/model/profile_data_model.dart';

import '../Utils/toast_widget.dart';
import '../utils/urls.dart';

class ApiService {
  void checkCustomerEligible(
      int flag, String mobileNumber, String token, BuildContext context) async {
    EasyLoading.show();
    final request =
        http.MultipartRequest("POST", Uri.parse(Urls.checkCustomerEligible));

    var workIDs = [];
    List<dynamic> estimatedWorks = [];
    var oldEstimatedWorks = [];
    Map<String, dynamic> customerEligible = {
      "flag": flag,
      "mobileNumber": mobileNumber,
      "Token": Constants().token
    };

    print(customerEligible);

    try {
      var response = await http.get(
        Uri.parse(Urls.checkCustomerEligible),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          'Token': Constants().token,
          "flag": flag.toString(),
          "mobileNumber": mobileNumber.toString(),
        },
        /* body: json.encode({
            "flag":flag,
            "mobileNumber": mobileNumber,
            "Token":Constants().token
          })*/
      );

      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        log(response.body);
        Map<String, dynamic> value = json.decode(response.body);
        if (value['isEligible']) {
        } else {}
        /*  if(value['message']=="Data inserted successfully"){
          //if(type=="edit"){
          log(response.body);
          // debugPrint(response.body);
          ToastWidget().showToastSuccess(value['message'].toString());
          SharedPrefrence().setPassword(password);

          */ /* }
            else{
              ToastWidget().showToastSuccess(value['data']['message'].toString());
              Navigator.pop(context);
              Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: JobCardListScreen()));
            }*/ /*

        }
        else{
          ToastWidget().showToastError(value['message'].toString());
        }*/
        log(response.body);
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

  // void getOtp(String phone,
  //     BuildContext context,
  //     String fromScreen,
  //     String otpType,
  //     String fullName,
  //     String email,
  //     String address1,
  //     String address2,
  //     String pincode,
  //     String file,
  //     String deviceID,
  //     String cardNumber
  //     ) async {

  //   EasyLoading.show();
  //   final request = http.MultipartRequest(
  //       "POST", Uri.parse(Urls.sendOtp));

  //   try {
  //     var response =
  //     await http.get(Uri.parse(Urls.sendOtp),
  //         headers: {
  //           'Content-type': 'application/json',
  //           'Accept': 'application/json',
  //           'Token': Constants().token,
  //           'MobileNumber': phone,
  //           'OtpType':otpType,
  //         },
  //         );

  //     if (response.statusCode == 200) {
  //       EasyLoading.dismiss();
  //       log(response.body);
  //       var resp = jsonDecode(response.body);
  //       // String ddd = resp;
  //        log(resp);
  //       Map<String, dynamic> value = json.decode(resp);
  //       var otp = value['otp'].toString();
  //       // var otpType = value['otpvalidity'].toString();
  //       Navigator.push(context,
  //           PageTransition(type: PageTransitionType.rightToLeft,
  //               child: OTPScreen(phone,
  //                   otp,
  //                   fullName,
  //                   email,
  //                   address1,
  //                   address2,
  //                   pincode,
  //                   file,
  //                   deviceID,
  //                   cardNumber,
  //                   "profile")));

  //     } else {
  //       Map<String, dynamic> value = json.decode(response.body);
  //       EasyLoading.dismiss();
  //       ToastWidget().showToastError(value['message'].toString());
  //       log(response.body);
  //     }
  //   } catch (error, stackTrace) {
  //     EasyLoading.dismiss();
  //     log(error.toString());
  //     log(stackTrace.toString());
  //   }
  // }

  Future<GetUserDetails> fetchUserProfileData(
      String token, String registeredMobileNo) async {
    final url = Urls.getProfileData;

    final headers = {
      'Token': token,
      'RegisteredMobileNo': registeredMobileNo,
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final getUserDetails = GetUserDetails.fromJson(data);
      return getUserDetails;
    } else {
      throw Exception('Failed to load data');
    }
  }
}
