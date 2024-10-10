// To parse this JSON data, do
//
//     final placeSearchByVendorDetailsModel = placeSearchByVendorDetailsModelFromJson(jsonString);

import 'dart:convert';

PlaceSearchByVendorDetailsModel placeSearchByVendorDetailsModelFromJson(
        String str) =>
    PlaceSearchByVendorDetailsModel.fromJson(json.decode(str));

String placeSearchByVendorDetailsModelToJson(
        PlaceSearchByVendorDetailsModel data) =>
    json.encode(data.toJson());

class PlaceSearchByVendorDetailsModel {
  bool transactionStatus;
  int totalRecords;
  List<Vendor> vendors;

  PlaceSearchByVendorDetailsModel({
    required this.transactionStatus,
    required this.totalRecords,
    required this.vendors,
  });

  factory PlaceSearchByVendorDetailsModel.fromJson(Map<String, dynamic> json) =>
      PlaceSearchByVendorDetailsModel(
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
  num vendorId;
  String vendorBusinessName;
  String vendorBusinessDescription;
  String vendorBranchName;
  var landMark;
  num vendorRegdMobileDialCode;
  num vendorRegisteredMobileNumber;
  String vendorContactPersonName;
  num vContPrsnMobDialCode;
  num vendorContactPersonMobNumber;
  num vendorClassificationId;
  String vendorClassificationName;
  String vendorCategories;
  String vendorAddressL1;
  String vendorAddressL2;
  num vendorPinCode;
  String vendorEmail;
  String vendorWebUrl;
  String idProofPicUrl1;
  var idProofPicUrl2;
  var idProofPicUrl3;
  String vendorGpsLocation;
  String vendorBusinessPicUrl1;
  String vendorBusinessPicUrl2;
  String vendorBusinessPicUrl3;
  String vendorBusinessPicUrl4;
  String vendorBusinessPicUrl5;
  String vendorBusinessPicUrl6;
  num vendorCountryId;
  String vendorCountryName;
  num vendorStateId;
  String vendorStateName;
  num vendorDistrictId;
  String vendorDistrictName;
  num vendorTownId;
  String vendorTownName;
  num vendorPlaceId;
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
        vendorId: json["VendorId"]??0,
        vendorBusinessName: json["VendorBusinessName"]??"",
        vendorBusinessDescription: json["VendorBusinessDescription"]??"",
        vendorBranchName: json["VendorBranchName"]??"",
        landMark: json["LandMark"]??"",
        vendorRegdMobileDialCode: json["VendorRegdMobileDialCode"]??0,
        vendorRegisteredMobileNumber: json["VendorRegisteredMobileNumber"]??0,
        vendorContactPersonName: json["VendorContactPersonName"]??"",
        vContPrsnMobDialCode: json["VContPrsnMobDialCode"]??0,
        vendorContactPersonMobNumber: json["VendorContactPersonMobNumber"]??0,
        vendorClassificationId: json["VendorClassificationID"]??0,
        vendorClassificationName: json["VendorClassificationName"]??"",
        vendorCategories: json["VendorCategories"]??"",
        vendorAddressL1: json["VendorAddressL1"]??"",
        vendorAddressL2: json["VendorAddressL2"]??"",
        vendorPinCode: json["VendorPinCode"]??0,
        vendorEmail: json["VendorEmail"]??"",
        vendorWebUrl: json["VendorWebURL"]??"",
        idProofPicUrl1: json["IDProofPicURL1"]??"",
        idProofPicUrl2: json["IDProofPicURL2"]??"",
        idProofPicUrl3: json["IDProofPicURL3"],
        vendorGpsLocation: json["VendorGPSLocation"]??"",
        vendorBusinessPicUrl1: json["VendorBusinessPicUrl1"]??"",
        vendorBusinessPicUrl2: json["VendorBusinessPicUrl2"]??"",
        vendorBusinessPicUrl3: json["VendorBusinessPicUrl3"]??"",
        vendorBusinessPicUrl4: json["VendorBusinessPicUrl4"]??"",
        vendorBusinessPicUrl5: json["VendorBusinessPicUrl5"]??"",
        vendorBusinessPicUrl6: json["VendorBusinessPicUrl6"]??"",
        vendorCountryId: json["VendorCountryID"]??0,
        vendorCountryName: json["VendorCountryName"]??"",
        vendorStateId: json["VendorStateID"]??0,
        vendorStateName: json["VendorStateName"]??"",
        vendorDistrictId: json["VendorDistrictID"]??0,
        vendorDistrictName: json["VendorDistrictName"]??"",
        vendorTownId: json["VendorTownID"]??0,
        vendorTownName: json["VendorTownName"]??"",
        vendorPlaceId: json["VendorPlaceID"]??0,
        vendorPlaceName: json["VendorPlaceName"]??"",
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
