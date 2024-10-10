import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:page_transition/page_transition.dart';
import 'package:reward_hub_customer/Utils/DeviceInfo.dart';
import 'package:reward_hub_customer/Utils/constants.dart';
import 'package:reward_hub_customer/bottom_navigation/bottom_navigation_screen.dart';
import 'package:reward_hub_customer/login/login_screen.dart';

import '../Utils/toast_widget.dart';
import '../utils/SharedPrefrence.dart';
import '../utils/urls.dart';

class ApiServiceRegister {
  void postRegister(
      String fullName,
      String mobileNumber,
      String email,
      String address1,
      String address2,
      String pinCode,
      String file,
      String? deviceID,
      String cardNumber,
      String password,
      BuildContext context,
      DeviceInfo deviceInfo) async {
    EasyLoading.show(
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );
    final request = http.MultipartRequest("POST", Uri.parse(Urls.register));

    var workIDs = [];
    List<dynamic> estimatedWorks = [];
    var oldEstimatedWorks = [];
    List<Map<String, dynamic>> followupParams = [
      {
        "cmCustomerName": fullName,
        "cmCustomerRegisteredMobileNumber": mobileNumber,
        "cmCustomerActiveCardNumber": cardNumber,
        "cmCustomerCardRenewalDate": DateTime.now().toString(),
        "cmCustomerEmail": email,
        "cmCustomerAddressL1": address1,
        "cmCustomerAddressL2": address2,
        "cmCustomerPinCode": pinCode,
        "cmCustomerIdproofUrl": file,
        "cmCustomerDeviceId": deviceID,
        "cmCustomerDeviceTypeId": 1,
        // "cmCustomerCountryId": 1,
        // "cmCustomerStateId": 1,
        // "cmCustomerDistrictId": 1,
        // "cmCustomerTownId": 1,
        // "cmCustomerPlaceId": 1,
        "cmCustomerSecret": password,
        "cmIsCustomerCardActive": true,
        "cmCustomerCardActivateDateTime": DateTime.now().toString(),
        "cmCustomerCardActivatedGpslocation": "string",
        "cmIScustomerActive": true,
      }
    ];

    print(followupParams);

    try {
      var response = await http.post(Uri.parse(Urls.register),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            'Token': Constants().token,
          },
          body: json.encode({
            "flag": 100,
            "jsonData": followupParams,
          }));
      log(json.encode({
        "flag": 100,
        "jsonData": followupParams,
      }).toString());

      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        log(response.body);
        var resp = json.decode(response.body);
        Map<String, dynamic> value = json.decode(resp);
        if (value['message'] == "Data inserted successfully") {
          log(response.body);

          // POST Device Iformation
          String CustomerID = value['generatedCustomerID'].toString();
          await postDeviceInfo(deviceInfo, mobileNumber, CustomerID);

          ToastWidget().showToastSuccess(value['message'].toString());
          SharedPrefrence().setPassword(password);
          SharedPrefrence().setActivated(true);
          Navigator.pop(context);
          Navigator.push(
              context,
              PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: LoginScreen(
                    isActivated: true,
                  )));
        } else {
          ToastWidget().showToastError(value['message'].toString());
        }
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
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> postDeviceInfo(
      DeviceInfo deviceInfo, String MobileNo, String CustomerID) async {
    final url = Uri.parse(Urls.deviceInfoPostAPI);

    final headers = {
      'DeviceID': '00',
      'CustomerID': CustomerID.toString(),
      'MobileNo': MobileNo.toString(),
      'Token': Constants().token,
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      "DI_DeviceId": deviceInfo.deviceId,
      "DI_Model": deviceInfo.model,
      "DI_OSVersion": deviceInfo.osVersion,
      "DI_AppName": deviceInfo.appName,
      "DI_PackageName": deviceInfo.packageName,
      "DI_Version": deviceInfo.version,
      "DI_BuildNumber": deviceInfo.buildNumber,
      "DI_Manufacture": deviceInfo.manufacture,
      "DI_Brand": deviceInfo.Brand,
      "DI_SerialNo": deviceInfo.SerialNo,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        print('Device info request successful');
        print('Response body: ${response.body}');
      } else {
        print('Device info request failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error posting device info: $e');
    }
  }
}
