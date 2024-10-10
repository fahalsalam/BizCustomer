import 'dart:convert';
import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:reward_hub_customer/Utils/DeviceInfo.dart';
import 'package:reward_hub_customer/Utils/SharedPrefrence.dart';
import 'package:reward_hub_customer/Utils/toast_widget.dart';
import 'package:reward_hub_customer/login/api_service.dart';
import 'package:reward_hub_customer/login/login_screen.dart';

import '../Utils/constants.dart';
import '../Utils/urls.dart';
import 'api_service.dart';

class RegisterScreen extends StatefulWidget {
  String? mobileNumber;
  RegisterScreen({super.key, this.mobileNumber = ""});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return RegisterScreenState();
  }
}

class RegisterScreenState extends State<RegisterScreen> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController address1Controller = TextEditingController();
  TextEditingController address2Controller = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool checkValue = false;
  var phonePrefix = "+91";
  XFile file = XFile("");
  String? deviceID = "";
  Position? position;
  bool isImageUploaded = false;
  String fileName = "";
  FocusNode mobileNumberFocused = FocusNode();
  bool isActiveCustomer = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    mobileNumberController.text = widget.mobileNumber.toString();
    _determinePosition();
  }

  Future<void> fetchDataAsync() async {
    String _mobileNo = mobileNumberController.text;
    try {
      Map<String, dynamic> customerData = await ApiService()
          .customerAlreadyExisted(context, mobileNumberController, _mobileNo);
      if (customerData.isNotEmpty) {
        bool isActiveCustomer =
            customerData["verificationStatus"] == "ACTIVE CUSTOMER";
        if (isActiveCustomer) {
          showCustomBottomSheet(context, mobileNumberController, customerData);
        } else {
          print("The customer is not active.$isActiveCustomer");
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void showCustomBottomSheet(
      BuildContext context,
      TextEditingController mobileNumberController,
      Map<String, dynamic> customerData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0.r)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: IntrinsicHeight(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20.h),
                Image.asset(
                  "assets/images/ic_logo.png",
                  height: 91.h,
                  width: 201.w,
                ),
                SizedBox(height: 20.h),
                Text(
                  "Phone Number Already Activated",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.sp,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10.h),
                Text(
                  "Do you want to login?",
                  style: TextStyle(fontSize: 16.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: Size(120.w, 50.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context, true);
                        SharedPrefrence().setActivated(true);

                        String customerSecret =
                            customerData["customerSecret"] ?? '';
                        SharedPrefrence().setPassword(customerSecret);
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: LoginScreen(
                              mobileNumber: mobileNumberController.text ?? "",
                              customerSecret: customerSecret,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        "Login",
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        minimumSize: Size(120.w, 50.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        mobileNumberController.clear();
                      },
                      child: Text(
                        "Cancel",
                        style: TextStyle(color: Colors.white, fontSize: 16.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      // appBar: AppBar(
      //   // automaticallyImplyLeading: false,
      //   leading: IconButton(
      //       onPressed: () {
      //         Navigator.of(context).pop();
      //       },
      //       icon: Icon(Icons.arrow_back_ios)),
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            // mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                height: 50,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 0,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                        ),
                        child: GestureDetector(
                            onTap: () {
                              SharedPrefrence().setLoggedIn(false);
                              // Navigator.of(context).push(MaterialPageRoute(builder: (context)=>LoginScreen()));
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()),
                              );
                            },
                            child:
                                Image.asset("assets/images/ic_back_img.png")),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20.h,
              ),
              Image.asset(
                "assets/images/ic_logo.png",
                height: 91.h,
                width: 201.w,
              ),
              SizedBox(
                height: 20.h,
              ),
              const Padding(
                padding: EdgeInsets.only(top: 0),
                child: Center(
                  child: Text(
                    "Create your Account",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              const Padding(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Center(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Add your phone number. We’ll send you a verification code so we know you’re real",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF828282)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 12.h,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: TextField(
                    keyboardType: TextInputType.text,
                    controller: fullNameController,
                    enabled: true,
                    obscureText: false,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Constants().appColor)),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 0.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                        filled: true,
                        contentPadding: EdgeInsets.only(left: 10, bottom: 5),
                        hintStyle: TextStyle(fontSize: 15),
                        hintText: "Full Name",
                        fillColor: Color(0xFFE5E7E9)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 5, top: 20),
                child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          flex: 0,
                          child: Container(
                            child: Align(
                              alignment: Alignment.center,
                              child: CountryCodePicker(
                                onChanged: (value) {
                                  setState(() {
                                    phonePrefix = value.dialCode!;

                                    print(phonePrefix);
                                  });
                                },
                                // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                initialSelection: 'IN',
                                favorite: ['+91', 'IN'],
                                // optional. Shows only country name and flag
                                showCountryOnly: false,
                                // optional. Shows only country name and flag when popup is closed.
                                showOnlyCountryWhenClosed: false,
                                // optional. aligns the flag and the Text left
                                alignLeft: false,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            // for Testing Purpose
                            onChanged: (value) {
                              if (value.length == 10) {
                                fetchDataAsync();
                              }
                            },
                            focusNode: mobileNumberFocused,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10)
                            ],
                            keyboardType: TextInputType.number,
                            controller: mobileNumberController,
                            enabled: true,
                            decoration: InputDecoration(
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Constants().appColor)),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black, width: 0.0),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black),
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
                      ],
                    )),
              ),
              // Padding(
              //   padding: const EdgeInsets.only(
              //       left: 20, right: 20, bottom: 0, top: 10),
              //   child: SizedBox(
              //     width: double.infinity,
              //     height: 50,
              //     child: TextField(
              //       keyboardType: TextInputType.text,
              //       controller: emailController,
              //       enabled: true,
              //       obscureText: false,
              //       decoration: InputDecoration(
              //           focusedBorder: OutlineInputBorder(
              //               borderSide:
              //                   BorderSide(color: Constants().appColor)),
              //           enabledBorder: OutlineInputBorder(
              //             borderSide:
              //                 BorderSide(color: Colors.black, width: 0.0),
              //           ),
              //           border: OutlineInputBorder(
              //             borderSide: BorderSide(color: Colors.black),
              //             borderRadius: BorderRadius.all(
              //               Radius.circular(8.0),
              //             ),
              //           ),
              //           filled: true,
              //           contentPadding: EdgeInsets.only(left: 10, bottom: 5),
              //           hintStyle: TextStyle(fontSize: 15),
              //           hintText: "Email",
              //           fillColor: Color(0xFFE5E7E9)),
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 0, top: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextField(
                    keyboardType: TextInputType.text,
                    controller: address1Controller,
                    enabled: true,
                    obscureText: false,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Constants().appColor)),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 0.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                        filled: true,
                        contentPadding: EdgeInsets.only(left: 10, bottom: 5),
                        hintStyle: TextStyle(fontSize: 15),
                        hintText: "Address 1",
                        fillColor: Color(0xFFE5E7E9)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 0, top: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextField(
                    keyboardType: TextInputType.text,
                    controller: address2Controller,
                    enabled: true,
                    obscureText: false,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Constants().appColor)),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 0.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                        filled: true,
                        contentPadding: EdgeInsets.only(left: 10, bottom: 5),
                        hintStyle: TextStyle(fontSize: 15),
                        hintText: "Address 2",
                        fillColor: Color(0xFFE5E7E9)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 0, top: 10),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    keyboardType: TextInputType.number,
                    controller: pinCodeController,
                    enabled: true,
                    obscureText: false,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Constants().appColor)),
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black, width: 0.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                        filled: true,
                        contentPadding: EdgeInsets.only(left: 10, bottom: 5),
                        hintStyle: TextStyle(fontSize: 15),
                        hintText: "Pin code",
                        fillColor: Color(0xFFE5E7E9)),
                  ),
                ),
              ),
              // GestureDetector(
              //   onTap: () {
              //     Pickimage(context);
              //   },
              //   child: Padding(
              //     padding: EdgeInsets.only(left: 20, right: 20, top: 10),
              //     child: Row(
              //       mainAxisSize: MainAxisSize.max,
              //       mainAxisAlignment: MainAxisAlignment.end,
              //       children: [
              //         Padding(
              //           padding: EdgeInsets.only(right: 10),
              //           child: Column(
              //             mainAxisSize: MainAxisSize.min,
              //             children: [
              //               Align(
              //                 alignment: Alignment.centerRight,
              //                 child: file.path.isEmpty
              //                     ? const Text(
              //                         "Please attach any ID proof here",
              //                         style: TextStyle(
              //                             color: Colors.black,
              //                             fontWeight: FontWeight.bold,
              //                             fontSize: 15),
              //                       )
              //                     : Text(
              //                         file.name,
              //                         style: const TextStyle(
              //                             color: Colors.black,
              //                             fontWeight: FontWeight.bold,
              //                             fontSize: 15),
              //                       ),
              //               ),
              //             ],
              //           ),
              //         ),
              //         Image.asset(
              //           "assets/images/ic_register_attach.png",
              //           height: 40,
              //           width: 64,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      flex: 0,
                      child: Checkbox(
                        visualDensity:
                            VisualDensity(horizontal: -1, vertical: -1),
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
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: Text(
                          "By providing my phone number, I hereby agree and accept the Terms & Condition and Privacy Policy in use of the BizAtom",
                          style: TextStyle(
                              color: Constants().grayColor, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
                child: GestureDetector(
                  onTap: () async {
                    deviceID = await _getId();
                    if (fullNameController.text.isEmpty) {
                      ToastWidget().showToastError("Please fill name");
                    } else if (mobileNumberController.text.isEmpty) {
                      ToastWidget().showToastError("Please fill mobile");
                    } else if (mobileNumberController.text.length < 10) {
                      ToastWidget().showToastError("Please enter valid mobile");
                      // } else if (emailController.text.isEmpty) {
                      //   ToastWidget().showToastError("Please fill email");
                      // } else if (RegExp(
                      //             r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                      //         .hasMatch(emailController.text.toString()) ==
                      //     false) {
                      //   ToastWidget().showToastError("Please enter valid email");
                    } else if (address1Controller.text.isEmpty) {
                      ToastWidget().showToastError("Please fill address");
                    } else if (pinCodeController.text.isEmpty) {
                      ToastWidget().showToastError("Please fill pin code");
                    } else if (pinCodeController.text.toString().length < 6) {
                      ToastWidget()
                          .showToastError("Please enter valid pin code");
                    }
                    // else if (!isImageUploaded) {
                    //   ToastWidget().showToastError("Please select file");
                    // }
                    else if (!checkValue) {
                      ToastWidget()
                          .showToastError("Please accept terms and condition");
                      SharedPrefrence()
                          .setUserAddress1(address1Controller.text.toString());
                      SharedPrefrence()
                          .setUserAddress2(address2Controller.text.toString());

                      SharedPrefrence()
                          .setPincode(pinCodeController.text.toString());
                    } else {
                      DeviceInfo deviceInfo = await collectDeviceInfo();
                      ApiService().postLogin(
                          mobileNumberController.text.toString(),
                          context,
                          false,
                          "register",
                          fullNameController.text.toString(),
                          "",
                          address1Controller.text.toString(),
                          address2Controller.text.toString(),
                          pinCodeController.text.toString(),
                          "",
                          deviceID!,
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
                        "CREATE ACCOUNT",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "If, You have a BizAtom account?",
                    style: TextStyle(
                        color: Constants().grayColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, top: 5, bottom: 20),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context, true);
                    SharedPrefrence().setActivated(true);
                    Navigator.push(
                        context,
                        PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: LoginScreen()));
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.black),
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
              )
            ],
          ),
        ),
      ),
    );
  }

  void Pickimage(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (image != null) {
      setState(() {
        file = image;
        uploadDocument(file);
      });
    }

    // Navigator.pop(context);
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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print(position!.latitude);
    return position!;
  }

  void uploadDocument(XFile image) async {
    var dio = Dio();
    try {
      EasyLoading.show(
        dismissOnTap: false,
        maskType: EasyLoadingMaskType.black,
      );
      final mimeTypeData =
          lookupMimeType(image.path, headerBytes: [0xFF, 0xD8])?.split('/');
      FormData formData = FormData.fromMap({
        "imageFile": await MultipartFile.fromFile(image.path,
            contentType: MediaType(mimeTypeData![0], mimeTypeData[1])),
      });

      dio.options.headers['Content-Type'] = 'application/json';
      dio.options.headers['Token'] = Constants().token;
      var response = await dio.post(
        Urls.uploadImage,
        data: formData,
        options: Options(
            followRedirects: false,
            validateStatus: (status) => true,
            contentType: 'multipart/form-data'),
      );
      debugPrint(response.data.toString());
      debugPrint(response.statusCode.toString());
      if (response.statusCode == 200) {
        EasyLoading.dismiss();
        // return response.statusCode;
        // return UploadJobcardImageResponse.fromJson(
        //     json.decode(response.toString()));
        var param = json.decode(response.toString());
        Map<String, dynamic> value = param;
        if (value['status'].toString() == "true") {
          setState(() {
            isImageUploaded = true;
            fileName = value['filename'].toString();
          });
          ToastWidget().showToastSuccess(value['message'].toString());
        } else {
          setState(() {
            //isImageUploaded = false;
            // fileName = "";
          });
          ToastWidget().showToastError(value['message'].toString());
        }
      } else {
        // return response.statusCode;
      }
    } catch (e, stacktrace) {
      print(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<DeviceInfo> collectDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String? deviceId;
    String? model;
    String? osVersion;
    String? manufacture;
    String? Brand;
    String? SerialNo;

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceId = androidInfo.id;
      model = androidInfo.model;
      manufacture = androidInfo.manufacturer;
      Brand = androidInfo.brand;
      SerialNo = androidInfo.serialNumber;

      osVersion = androidInfo.version.release;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      deviceId = iosInfo.identifierForVendor;
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
