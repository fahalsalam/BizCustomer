// ignore_for_file: unnecessary_null_comparison

import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:reward_hub_customer/Utils/SharedPrefrence.dart';
import 'package:reward_hub_customer/Utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:reward_hub_customer/Utils/toast_widget.dart';
import 'package:reward_hub_customer/Utils/urls.dart';
import 'package:reward_hub_customer/profile/api_service.dart';
import 'package:reward_hub_customer/provider/user_data_provider.dart';
import 'package:reward_hub_customer/store/model/profile_data_model.dart';

import 'package:image_cropper/image_cropper.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

TextEditingController _fulNameController = TextEditingController();
TextEditingController _addres1Controller = TextEditingController();
TextEditingController _addres2Controller = TextEditingController();
TextEditingController _pinCodeController = TextEditingController();
TextEditingController _emailController = TextEditingController();
TextEditingController _phoneNumberController = TextEditingController();

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? _imageFile;
  ApiService apiService = ApiService();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadUserProfileData();
  }

  Future<void> _loadUserProfileData() async {
    try {
      GetUserDetails userDetails = await apiService.fetchUserProfileData(
        Constants().token,
        SharedPrefrence().getUserPhone(),
      );

      setState(() {
        _fulNameController.text = SharedPrefrence().getUsername();
        _emailController.text = userDetails.cmCustomerEmail.toString();
        _phoneNumberController.text =
            userDetails.cmCustomerRegisteredMobileNumber.toString();
        _addres1Controller.text = userDetails.cmCustomerAddressL1.toString();
        _addres2Controller.text = userDetails.cmCustomerAddressL2.toString();
        _pinCodeController.text = userDetails.cmCustomerPinCode.toString();
        if (userDetails.customerPhotoUrl != null &&
            userDetails.customerPhotoUrl.isNotEmpty) {
          _imageFile = File(userDetails.customerPhotoUrl);
        }
      });
    } catch (error) {
      print("Error loading user profile data: $error");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source).then(
      (value) {
        if (value != null) {
          _cropImage(File(value.path));
        }
      },
    );
    ;

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showImagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Choose from gallery'),
                onTap: () {
                  _pickImage(ImageSource.gallery);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Take a photo'),
                onTap: () {
                  _pickImage(ImageSource.camera);
                  // _cropImage(imgFile)
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                          "EDIT PROFILE",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 0,
              child: Container(
                height: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    GestureDetector(
                        onTap: () {
                          _showImagePicker(context);
                        },
                        child: _imageFile == null
                            ? Image.asset(
                                "assets/images/Frame_2.png",
                                height: 98.h,
                                width: 98.h,
                                fit: BoxFit.cover,
                              )
                            : _imageFile!.existsSync()
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(49),
                                    child: Image.file(
                                      _imageFile!,
                                      height: 98,
                                      width: 98,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Image.asset(
                                    "assets/images/Frame_2.png",
                                    height: 98.h,
                                    width: 98.h,
                                    fit: BoxFit.cover,
                                  )),
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 8.0, top: 8, right: 8),
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
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Full Name",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      )),
                  SizedBox(
                    height: 52,
                    child: TextFormField(
                      controller: _fulNameController,
                      decoration: InputDecoration(
                          hintText: "Full Name",
                          // enabledBorder: OutlineInputBorder(),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Email",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      )),
                  SizedBox(
                    height: 52,
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                          hintText: "Email",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address.';
                        }
                        // Use a regular expression for basic email validation
                        // You can use a more sophisticated validation based on your requirements
                        bool isValid = RegExp(
                                r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$")
                            .hasMatch(value);
                        if (!isValid) {
                          return 'Please enter a valid email address.';
                        }
                        return null; // Return null if the input is valid
                      },

                      // validator: (value) {
                      //   if (value == null || value.isEmpty) {
                      //     return 'Please enter an email address.';
                      //   } else if (!value.isEmail) {
                      //     return 'Please enter a valid email address.';
                      //   }
                      //   return null;
                      // },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Text("Phone Number",
                  //     style: TextStyle(
                  //       fontSize: 16,
                  //       fontWeight: FontWeight.w500,
                  //     )),
                  // SizedBox(
                  //   height: 52,
                  //   child: TextFormField(
                  //     controller: _phoneNumberController,
                  //     decoration: InputDecoration(
                  //         hintText: "Phone Number",
                  //         border: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(10))),
                  //   ),
                  // ),
                  // const SizedBox(height: 10),
                  Text("Address 1",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      )),
                  SizedBox(
                    height: 52,
                    child: TextFormField(
                      controller: _addres1Controller,
                      decoration: InputDecoration(
                          hintText: "Address1",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Address 2",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      )),
                  SizedBox(
                    height: 52,
                    child: TextFormField(
                      controller: _addres2Controller,
                      decoration: InputDecoration(
                          hintText: "Address2",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Pincode",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      )),
                  SizedBox(
                    height: 52,
                    child: TextFormField(
                      
                      controller: _pinCodeController,
                      decoration: InputDecoration(
                        hintText: "Pin code",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                   
                      ),keyboardType: TextInputType.number,
                            inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9]')), // Only allow numeric characters
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 52,
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 5.0),
                      child: TextButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Constants().appColor),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)))),
                          onPressed: () {
                            _updateProfile();
                            Navigator.of(context).pop();
                            setState(() {});
                          },
                          child: Text("SAVE",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ))),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      )),
    );
  }

  void _updateProfile() async {
    final String apiUrl = Urls.updateProfileData;
    final String token = Constants().token;

    Map<String, dynamic> requestBody = {
      "customerID": 0,
      "customerRegisteredMobileNumber": int.parse(_phoneNumberController.text),
      "customerName": _fulNameController.text,
      "customerEmail": _emailController.text,
      "customerAddressL1": _addres1Controller.text,
      "customerAddressL2": _addres2Controller.text,
      "customerPinCode": int.parse(_pinCodeController.text),
      "customerIdproofUrl": "",
      "customerPhotoUrl": _imageFile != null ? _imageFile?.path : "",
    };

    try {
      EasyLoading.show(
        dismissOnTap: false,
        maskType: EasyLoadingMaskType.black,
      );
      setState(() {
        Provider.of<UserData>(context, listen: false)
            .setUserName(_fulNameController.text);

        Provider.of<UserData>(context, listen: false)
            .setUserProfilePhotoData(_imageFile?.path ?? "");
      });
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {
          "Token": token,
          HttpHeaders.contentTypeHeader: "application/json", // Set content type
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        await _loadUserProfileData();
        ToastWidget().showToastSuccess("Profile updated successfully");
        print("Profile updated successfully");
      } else {
        // Handle error
        print("Failed to update profile. Status code: ${response.statusCode}");
      }
    } catch (error) {
      // Handle exception
      print("Error updating profile: $error");
    } finally {
      EasyLoading.dismiss();
    }
  }

  _cropImage(File imgFile) async {
    final croppedFile = await ImageCropper().cropImage(
        sourcePath: imgFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: "Image Cropper",
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: "Image Cropper",
        ));
    if (croppedFile != null) {
      // imageCache.clear();
      setState(() {
        _imageFile = File(croppedFile.path);
      });
      // reload();
    }
  }
}
// extension EmailValidator on String {
//   bool get isEmail => RegExp(
//         r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
//       ).hasMatch(this);
// }
