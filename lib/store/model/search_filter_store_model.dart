// To parse this JSON data, do
//
//     final storeSearchFilterModel = storeSearchFilterModelFromJson(jsonString);

import 'dart:convert';

StoreSearchFilterModel storeSearchFilterModelFromJson(String str) => StoreSearchFilterModel.fromJson(json.decode(str));

String storeSearchFilterModelToJson(StoreSearchFilterModel data) => json.encode(data.toJson());

class StoreSearchFilterModel {
    bool? transactionStatus;
    int? totalRecords;
    int? totalFilteredRecords;
    List<Vendor>? vendorss;

    StoreSearchFilterModel({
         this.transactionStatus,
        this.totalRecords,
         this.totalFilteredRecords,
         this.vendorss,
    });

    factory StoreSearchFilterModel.fromJson(Map<String, dynamic> json) => StoreSearchFilterModel(
        transactionStatus: json["transactionStatus"],
        totalRecords: json["totalRecords"],
        totalFilteredRecords: json["totalFilteredRecords"],
        vendorss: List<Vendor>.from(json["vendors"].map((x) => Vendor.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "transactionStatus": transactionStatus,
        "totalRecords": totalRecords,
        "totalFilteredRecords": totalFilteredRecords,
        "vendors": List<dynamic>.from(vendorss!.map((x) => x.toJson())),
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
        required this.vendorGpsLocation,
        required this.vendorBusinessPicUrl1,
        required this.vendorBusinessPicUrl2,
        required this.vendorBusinessPicUrl3,
        required this.vendorBusinessPicUrl4,
        required this.vendorBusinessPicUrl5,
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
        vendorGpsLocation: json["VendorGPSLocation"],
        vendorBusinessPicUrl1: json["VendorBusinessPicUrl1"],
        vendorBusinessPicUrl2: json["VendorBusinessPicUrl2"],
        vendorBusinessPicUrl3: json["VendorBusinessPicUrl3"],
        vendorBusinessPicUrl4: json["VendorBusinessPicUrl4"],
        vendorBusinessPicUrl5: json["VendorBusinessPicUrl5"],
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
        "VendorGPSLocation": vendorGpsLocation,
        "VendorBusinessPicUrl1": vendorBusinessPicUrl1,
        "VendorBusinessPicUrl2": vendorBusinessPicUrl2,
        "VendorBusinessPicUrl3": vendorBusinessPicUrl3,
        "VendorBusinessPicUrl4": vendorBusinessPicUrl4,
        "VendorBusinessPicUrl5": vendorBusinessPicUrl5,
        "iSVendorActive": iSVendorActive,
    };
}
