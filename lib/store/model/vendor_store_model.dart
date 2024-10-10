// To parse this JSON data, do
//
//     final vendorStoreModel = vendorStoreModelFromJson(jsonString);

import 'dart:convert';

VendorStoreModel vendorStoreModelFromJson(String str) =>
    VendorStoreModel.fromJson(json.decode(str));

String vendorStoreModelToJson(VendorStoreModel data) =>
    json.encode(data.toJson());

class VendorStoreModel {
  bool transactionStatus;
  int totalRecords;
  List<Vendor> vendors;

  VendorStoreModel({
    required this.transactionStatus,
    required this.totalRecords,
    required this.vendors,
  });

  factory VendorStoreModel.fromJson(Map<String, dynamic> json) =>
      VendorStoreModel(
        transactionStatus: json["transactionStatus"],
        totalRecords: json["totalRecords"],
        vendors:
            List<Vendor>.from(json["vendors"].map((x) => Vendor.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "transactionStatus": transactionStatus,
        "totalRecords": totalRecords,
        "vendors": List<dynamic>.from(vendors.map((x) => x.toJson())),
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
  String idProofPicUrl1;
  String idProofPicUrl2;
  String idProofPicUrl3;
  String vendorGpsLocation;
  String vendorBusinessPicUrl1;
  String vendorBusinessPicUrl2;
  String vendorBusinessPicUrl3;
  String vendorBusinessPicUrl4;
  String vendorBusinessPicUrl5;
  String vendorBusinessPicUrl6;
  int vendorCountryId;
  String vendorCountryName;
  int vendorStateId;
  String vendorStateName;
  int vendorDistrictId;
  String vendorDistrictName;
  int vendorTownId;
  String vendorTownName;
  int vendorPlaceId;
  String vendorPlaceName;
  bool iSVendorActive;

  Vendor({
    required this.vendorId,
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
    required this.idProofPicUrl1,
    required this.idProofPicUrl2,
    required this.idProofPicUrl3,
    required this.vendorGpsLocation,
    required this.vendorBusinessPicUrl1,
    required this.vendorBusinessPicUrl2,
    required this.vendorBusinessPicUrl3,
    required this.vendorBusinessPicUrl4,
    required this.vendorBusinessPicUrl5,
    required this.vendorBusinessPicUrl6,
    required this.vendorCountryId,
    required this.vendorCountryName,
    required this.vendorStateId,
    required this.vendorStateName,
    required this.vendorDistrictId,
    required this.vendorDistrictName,
    required this.vendorTownId,
    required this.vendorTownName,
    required this.vendorPlaceId,
    required this.vendorPlaceName,
    required this.iSVendorActive,
  });

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
        idProofPicUrl1: json["IDProofPicURL1"],
        idProofPicUrl2: json["IDProofPicURL2"],
        idProofPicUrl3: json["IDProofPicURL3"],
        vendorGpsLocation: json["VendorGPSLocation"],
        vendorBusinessPicUrl1: json["VendorBusinessPicUrl1"],
        vendorBusinessPicUrl2: json["VendorBusinessPicUrl2"],
        vendorBusinessPicUrl3: json["VendorBusinessPicUrl3"],
        vendorBusinessPicUrl4: json["VendorBusinessPicUrl4"],
        vendorBusinessPicUrl5: json["VendorBusinessPicUrl5"],
        vendorBusinessPicUrl6: json["VendorBusinessPicUrl6"],
        vendorCountryId: json["VendorCountryID"],
        vendorCountryName: json["VendorCountryName"],
        vendorStateId: json["VendorStateID"],
        vendorStateName: json["VendorStateName"],
        vendorDistrictId: json["VendorDistrictID"],
        vendorDistrictName: json["VendorDistrictName"],
        vendorTownId: json["VendorTownID"],
        vendorTownName: json["VendorTownName"],
        vendorPlaceId: json["VendorPlaceID"],
        vendorPlaceName: json["VendorPlaceName"],
        iSVendorActive: json["iSVendorActive"],
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
        "IDProofPicURL1": idProofPicUrl1,
        "IDProofPicURL2": idProofPicUrl2,
        "IDProofPicURL3": idProofPicUrl3,
        "VendorGPSLocation": vendorGpsLocation,
        "VendorBusinessPicUrl1": vendorBusinessPicUrl1,
        "VendorBusinessPicUrl2": vendorBusinessPicUrl2,
        "VendorBusinessPicUrl3": vendorBusinessPicUrl3,
        "VendorBusinessPicUrl4": vendorBusinessPicUrl4,
        "VendorBusinessPicUrl5": vendorBusinessPicUrl5,
        "VendorBusinessPicUrl6": vendorBusinessPicUrl6,
        "VendorCountryID": vendorCountryId,
        "VendorCountryName": vendorCountryName,
        "VendorStateID": vendorStateId,
        "VendorStateName": vendorStateName,
        "VendorDistrictID": vendorDistrictId,
        "VendorDistrictName": vendorDistrictName,
        "VendorTownID": vendorTownId,
        "VendorTownName": vendorTownName,
        "VendorPlaceID": vendorPlaceId,
        "VendorPlaceName": vendorPlaceName,
        "iSVendorActive": iSVendorActive,
      };
}
