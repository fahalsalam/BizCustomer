import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:reward_hub_customer/profile/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:reward_hub_customer/profile/profile_screen.dart';
import 'package:reward_hub_customer/provider/user_data_provider.dart';
import '../Utils/SharedPrefrence.dart';
import '../Utils/constants.dart';
import '../Utils/toast_widget.dart';
import '../Utils/urls.dart';
import '../login/login_screen.dart';

class EncashMentScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return EncashmentScreenState();
  }
}

class EncashmentScreenState extends State<EncashMentScreen> {
  TextEditingController encashController = TextEditingController();
  var isEligible = false;
  var reason = "";
  bool isEncashButtonClicked = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkCustomerEligible(
        1, SharedPrefrence().getUserPhone(), Constants().token, context);
  }

  Widget profileImage() => FullScreenWidget(
        disposeLevel: DisposeLevel.High,
        child: Hero(
          tag: "profile_image",
          child: Consumer<UserData>(
            builder: (context, userdata, _) {
              String profilePhotoPath = SharedPrefrence().getUserProfilePhoto();
              File profilePhotoFile = File(profilePhotoPath);
              return ClipRRect(
                borderRadius: BorderRadius.circular(47),
                child: profilePhotoFile.existsSync()
                    ? Image.file(
                        File(SharedPrefrence().getUserProfilePhoto()),
                        height: 98,
                        width: 98,
                        fit: BoxFit.fill,
                      )
                    : Image.asset(
                        "assets/images/ic_profile.png",
                        height: 98,
                        width: 98,
                        fit: BoxFit.cover,
                      ),
              );
            },
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      // resizeToAvoidBottomInset:true ,
      body: SingleChildScrollView(
        child: SafeArea(
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
                      Expanded(
                        flex: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                          ),
                          child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child:
                                  Image.asset("assets/images/ic_back_img.png")),
                        ),
                      ),
                      const Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "ENCASHMENT",
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
              SizedBox(
                height: 50.h,
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    height: 200.h,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        profileImage(),
                        //  Image.asset("assets/images/ic_profile.png",
                        //    height: 98,
                        //    width: 98,),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, top: 8, right: 8),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              SharedPrefrence().getUsername(),
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
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
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "CARD BALANCE",
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0.0),
                    child: Consumer<UserData>(builder: (context, userData, _) {
                      return Text(
                        userData.userModel?.walletbalance.toStringAsFixed(2) ??
                            "",
                        style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 40),
                      );
                    }),
                    //      Consumer<UserData>(builder: (context, userData, _) {
                    //   return Padding(
                    //     padding: EdgeInsets.only(bottom: 18.0.h, left: 13.w),
                    //     child: Text(
                    //       userData.userModel?.walletbalance
                    //               .toStringAsFixed(2) ??
                    //           "",
                    //       style: TextStyle(
                    //           color: Colors.white,
                    //           fontSize: 16.sp,
                    //           fontWeight: FontWeight.w700),
                    //     ),
                    //   );
                    // }),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 15, right: 15, top: 50),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Enter a value to Encash",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 10, left: 15, right: 15),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: encashController,
                        enabled: true,
                        obscureText: false,
                        decoration: const InputDecoration(
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
                                EdgeInsets.only(left: 10, bottom: 5),
                            hintStyle: TextStyle(fontSize: 15),
                            hintText: "",
                            fillColor: Color(0xFFE5E7E9)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 15),
                    child: GestureDetector(
                      onTap: isEncashButtonClicked
                          ? () async {
                              var deviceID = await _getId();
                              if (!isEligible) {
                                ToastWidget().showToastError(reason);
                              } else if (SharedPrefrence().getWalletBalance() ==
                                  "0.0") {
                                ToastWidget()
                                    .showToastError("No Balance to encash");
                              } else if (encashController.text.toString() ==
                                  "") {
                                ToastWidget().showToastError("Please fill");
                              } else {
                                // checkCustomerEligible();
                                setState(() {
                                  isEncashButtonClicked = true;
                                });
                                postEncashmentRequest();
                                setState(() {
                                  isEncashButtonClicked = false;
                                });
                              }
                            }
                          : () {},
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Constants().appColor),
                        child: const Align(
                          alignment: Alignment.center,
                          child: Text(
                            "ENCASH",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.id; // unique ID on Android
    }
  }

  void checkCustomerEligible(
      int flag, String mobileNumber, String token, BuildContext context) async {
    EasyLoading.show(
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );
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
          setState(() {
            isEligible = true;
          });
        } else {
          setState(() {
            isEligible = false;
            reason = value['reason'].toString();
            ToastWidget().showToastError(value['reason'].toString());
          });
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
    }
  }

  void postCustomerReward(
      String rewardValue, String deviceID, BuildContext context) async {
    EasyLoading.show(
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );
    final request = http.MultipartRequest("POST", Uri.parse(Urls.postRewards));

    var workIDs = [];
    List<dynamic> estimatedWorks = [
      {
        "rwRef": 0,
        "rwDateTime": DateTime.now().toString(),
        "rwCustomerId": SharedPrefrence().getUserId(),
        "rwCustomerCardNumber": SharedPrefrence().getCard(),
        "rwVendorId": 0,
        "rwValue": int.parse(rewardValue),
        "rwVendorDeviceId": "0",
        "rwCustomerDeviceId": deviceID
      }
    ];
    var oldEstimatedWorks = [];
    print(estimatedWorks);

    try {
      var response = await http.post(Uri.parse(Urls.postRewards),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
            'Token': Constants().token,
          },
          body: json.encode({"flag": 0, "jsonData": estimatedWorks}));

      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        log(response.body);
        Map<String, dynamic> value = json.decode(response.body);
        if (value['message'].toString() ==
            "Reward Transaction completed successfully") {
          setState(() {
            ToastWidget().showToastSuccess(value['message'].toString());
            Navigator.pop(context);
            Navigator.push(
                context,
                PageTransition(
                    type: PageTransitionType.rightToLeft,
                    child: ProfileScreen()));
          });
        } else {
          setState(() {
            ToastWidget().showToastError(value['message'].toString());
          });
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
    }
  }

  void postEncashmentRequest() async {
    const url = Urls.postEncashmentRequest;

    Map<String, String> headers = {
      "Token": Constants().token,
      "Content-Type": "application/json",
    };

    Map<String, dynamic> requestBody = {
      "requestDateTime":
          DateFormat("yyyy-MM-ddTHH:mm:ss.SSSZ").format(DateTime.now()).toString(),
      "customerID": int.tryParse(SharedPrefrence().getCustomerId()),
      "customerCardNumber":int.tryParse(SharedPrefrence().getCard()) ,
      "requestedValue": num.tryParse(encashController.text) ,
      "customerDeviceID": SharedPrefrence().getCustomerDeviceID().toString()
    };
    print("request Body :>>>$requestBody");
    //  SharedPreference().setVendorId("1000055");
    // SharedPreference().setVendorDeviceId("123456");

    try {
        EasyLoading.show(
        dismissOnTap: false,
        maskType: EasyLoadingMaskType.black,
      );
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print('POST request successful');
        print('Response: ${response.body}');

        Map<String, dynamic> responseData = jsonDecode(response.body);
        // num encashmentRefNo = responseData["EncashmentRef"];

        // Show an alert dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Center(child: const Text('Encashment Successful')),
              content: Text(
                  '${responseData['message']}'),
              actions: [
                Center(
                  child: Container(
                    height: 50,
                    width: 120,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black),
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        encashController.clear();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProfileScreen()));
                      },
                      child: Text(
                        'OK',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            );
          },
        );
      } else {
        print('Encashment request failed!: ${response.statusCode}');
        print('Response: ${response.body}');
            Map<String, dynamic> responsemdg = jsonDecode(response.body);
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Center(child: const Text('Encashment')),
              content: Text(
                  '${responsemdg["message"]}'),
              actions: [
                Center(
                  child: Container(
                    height: 50,
                    width: 120,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black),
                    child: TextButton(
                      onPressed: () {
                      Navigator.of(context).pop();
                        encashController.clear();
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ProfileScreen()));
                      },
                      child: Text(
                        'OK',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            );
          },
        );
      }
    } catch (error) {
      print('Error: $error');
    } finally {
      EasyLoading.dismiss();
    }
  }
}
