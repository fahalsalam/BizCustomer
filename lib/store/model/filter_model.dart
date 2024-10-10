// To parse this JSON data, do
//
//     final filterVendorModel = filterVendorModelFromJson(jsonString);

import 'dart:convert';

FilterVendorModel filterVendorModelFromJson(String str) =>
    FilterVendorModel.fromJson(json.decode(str));

String filterVendorModelToJson(FilterVendorModel data) =>
    json.encode(data.toJson());

class FilterVendorModel {
  bool? isSuccess;
  List<Vendor>? data;

  FilterVendorModel({
    this.isSuccess,
    this.data,
  });

  factory FilterVendorModel.fromJson(Map<String, dynamic> json) =>
      FilterVendorModel(
        isSuccess: json["isSuccess"],
        data: List<Vendor>.from(json["data"].map((x) => Vendor.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "isSuccess": isSuccess,
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
      };
}

class Vendor {
  int vendorId;
  String vendorBusinessName;
  String vendorBusinessDescription;
  String vendorBranchName;
  String landMark;
  int vendorRegdMobileDialCode;
  int vendorRegisteredMobileNumber;
  String vendorContactPersonName;
  int vContPrsnMobDialCode;
  int vendorContactPersonMobNumber;
  int vendorClassificationId;
  String vendorClassificationName;
  String vendorCategories;
  String vendorAddressL1;
  String vendorAddressL2;
  int vendorPinCode;
  String vendorEmail;
  String vendorWebUrl;
  String vendorGpsLocation;
  String vendorBusinessPicUrl1;
  dynamic vendorBusinessPicUrl2;
  dynamic vendorBusinessPicUrl3;
  dynamic vendorBusinessPicUrl4;
  dynamic vendorBusinessPicUrl5;

  Vendor(
      {required this.vendorId,
      required this.vendorBusinessName,
      required this.vendorBusinessDescription,
      required this.vendorBranchName,
      required this.landMark,
      required this.vendorRegdMobileDialCode,
      required this.vendorRegisteredMobileNumber,
      required this.vendorContactPersonName,
      required this.vContPrsnMobDialCode,
      required this.vendorContactPersonMobNumber,
      required this.vendorClassificationId,
      required this.vendorClassificationName,
      required this.vendorCategories,
      required this.vendorAddressL1,
      required this.vendorAddressL2,
      required this.vendorPinCode,
      required this.vendorEmail,
      required this.vendorWebUrl,
      required this.vendorGpsLocation,
      required this.vendorBusinessPicUrl1,
      required this.vendorBusinessPicUrl2,
      required this.vendorBusinessPicUrl3,
      required this.vendorBusinessPicUrl4,
      required this.vendorBusinessPicUrl5});

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
        vendorId: json["VendorId"],
        vendorBusinessName: json["VendorBusinessName"],
        vendorBusinessDescription: json["VendorBusinessDescription"],
        vendorBranchName: json["VendorBranchName"],
        landMark: json["LandMark"],
        vendorRegdMobileDialCode: json["VendorRegdMobileDialCode"],
        vendorRegisteredMobileNumber: json["VendorRegisteredMobileNumber"],
        vendorContactPersonName: json["VendorContactPersonName"],
        vContPrsnMobDialCode: json["VContPrsnMobDialCode"],
        vendorContactPersonMobNumber: json["VendorContactPersonMobNumber"],
        vendorClassificationId: json["VendorClassificationID"],
        vendorClassificationName: json["VendorClassificationName"],
        vendorCategories: json["VendorCategories"],
        vendorAddressL1: json["VendorAddressL1"],
        vendorAddressL2: json["VendorAddressL2"],
        vendorPinCode: json["VendorPinCode"],
        vendorEmail: json["VendorEmail"],
        vendorWebUrl: json["VendorWebURL"],
        vendorGpsLocation: (json["VendorGPSLocation"] as String?) ?? "",
        vendorBusinessPicUrl1: json["VendorBusinessPicUrl1"],
        vendorBusinessPicUrl2: json["VendorBusinessPicUrl2"],
        vendorBusinessPicUrl3: json["VendorBusinessPicUrl3"],
        vendorBusinessPicUrl4: json["VendorBusinessPicUrl4"],
        vendorBusinessPicUrl5: json["VendorBusinessPicUrl5"],
      );

  Map<String, dynamic> toJson() => {
        "VendorId": vendorId,
        "VendorBusinessName": vendorBusinessName,
        "VendorBusinessDescription": vendorBusinessDescription,
        "VendorBranchName": vendorBranchName,
        "LandMark": landMark,
        "VendorRegdMobileDialCode": vendorRegdMobileDialCode,
        "VendorRegisteredMobileNumber": vendorRegisteredMobileNumber,
        "VendorContactPersonName": vendorContactPersonName,
        "VContPrsnMobDialCode": vContPrsnMobDialCode,
        "VendorContactPersonMobNumber": vendorContactPersonMobNumber,
        "VendorClassificationID": vendorClassificationId,
        "VendorClassificationName": vendorClassificationName,
        "VendorCategories": vendorCategories,
        "VendorAddressL1": vendorAddressL1,
        "VendorAddressL2": vendorAddressL2,
        "VendorPinCode": vendorPinCode,
        "VendorEmail": vendorEmail,
        "VendorWebURL": vendorWebUrl,
        "VendorGPSLocation": vendorGpsLocation,
        "VendorBusinessPicUrl1": vendorBusinessPicUrl1,
        "VendorBusinessPicUrl2": vendorBusinessPicUrl2,
        "VendorBusinessPicUrl3": vendorBusinessPicUrl3,
        "VendorBusinessPicUrl4": vendorBusinessPicUrl4,
        "VendorBusinessPicUrl5": vendorBusinessPicUrl5,
      };
}
