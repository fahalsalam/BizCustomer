// To parse this JSON data, do
//
//     final getUserDetails = getUserDetailsFromJson(jsonString);

import 'dart:convert';

GetUserDetails getUserDetailsFromJson(String str) =>
    GetUserDetails.fromJson(json.decode(str));

String getUserDetailsToJson(GetUserDetails data) => json.encode(data.toJson());

class GetUserDetails {
  String cmCustomerName;
  num cmCustomerRegisteredMobileNumber;
  num cmCustomerActiveCardNumber;
  num cmCustomerWalletBalance;
  DateTime cmCustomerCardRenewalDate;
  String cmCustomerEmail;
  String cmCustomerAddressL1;
  String cmCustomerAddressL2;
  num cmCustomerPinCode;
  String cmCustomerIdproofUrl;
  dynamic customerPhotoUrl;
  String cmCustomerDeviceId;
  num cmCustomerDeviceTypeId;
  // num cmCustomerCountryId;
  // num cmCustomerStateId;
  // num cmCustomerDistrictId;
  // num cmCustomerTownId;
  // num cmCustomerPlaceId;
  String cmCustomerSecret;
  bool cmIsCustomerCardActive;
  DateTime cmCustomerCardActivateDateTime;
  String cmCustomerCardActivatedGpslocation;
  bool cmIScustomerActive;

  GetUserDetails({
    required this.cmCustomerName,
    required this.cmCustomerRegisteredMobileNumber,
    required this.cmCustomerActiveCardNumber,
    required this.cmCustomerWalletBalance,
    required this.cmCustomerCardRenewalDate,
    required this.cmCustomerEmail,
    required this.cmCustomerAddressL1,
    required this.cmCustomerAddressL2,
    required this.cmCustomerPinCode,
    required this.cmCustomerIdproofUrl,
     this.customerPhotoUrl,
    required this.cmCustomerDeviceId,
    required this.cmCustomerDeviceTypeId,
    // required this.cmCustomerCountryId,
    // required this.cmCustomerStateId,
    // required this.cmCustomerDistrictId,
    // required this.cmCustomerTownId,
    // required this.cmCustomerPlaceId,
    required this.cmCustomerSecret,
    required this.cmIsCustomerCardActive,
    required this.cmCustomerCardActivateDateTime,
    required this.cmCustomerCardActivatedGpslocation,
    required this.cmIScustomerActive,
  });

  factory GetUserDetails.fromJson(Map<String, dynamic> json) => GetUserDetails(
        cmCustomerName: json["cmCustomerName"],
        cmCustomerRegisteredMobileNumber:
            json["cmCustomerRegisteredMobileNumber"],
        cmCustomerActiveCardNumber: json["cmCustomerActiveCardNumber"],
        cmCustomerWalletBalance: json["cmCustomerWalletBalance"],
        cmCustomerCardRenewalDate:
            DateTime.parse(json["cmCustomerCardRenewalDate"]),
        cmCustomerEmail: json["cmCustomerEmail"],
        cmCustomerAddressL1: json["cmCustomerAddressL1"],
        cmCustomerAddressL2: json["cmCustomerAddressL2"],
        cmCustomerPinCode: json["cmCustomerPinCode"],
        cmCustomerIdproofUrl: json["cmCustomerIdproofUrl"],
        customerPhotoUrl: json["customerPhotoUrl"],
        cmCustomerDeviceId: json["cmCustomerDeviceId"],
        cmCustomerDeviceTypeId: json["cmCustomerDeviceTypeId"],
        // cmCustomerCountryId: json["cmCustomerCountryId"],
        // cmCustomerStateId: json["cmCustomerStateId"],
        // cmCustomerDistrictId: json["cmCustomerDistrictId"],
        // cmCustomerTownId: json["cmCustomerTownId"],
        // cmCustomerPlaceId: json["cmCustomerPlaceId"],
        cmCustomerSecret: json["cmCustomerSecret"],
        cmIsCustomerCardActive: json["cmIsCustomerCardActive"],
        cmCustomerCardActivateDateTime:
            DateTime.parse(json["cmCustomerCardActivateDateTime"]),
        cmCustomerCardActivatedGpslocation:
            json["cmCustomerCardActivatedGpslocation"],
        cmIScustomerActive: json["cmIScustomerActive"],
      );

  Map<String, dynamic> toJson() => {
        "cmCustomerName": cmCustomerName,
        "cmCustomerRegisteredMobileNumber": cmCustomerRegisteredMobileNumber,
        "cmCustomerActiveCardNumber": cmCustomerActiveCardNumber,
        "cmCustomerWalletBalance": cmCustomerWalletBalance,
        "cmCustomerCardRenewalDate":
            cmCustomerCardRenewalDate.toIso8601String(),
        "cmCustomerEmail": cmCustomerEmail,
        "cmCustomerAddressL1": cmCustomerAddressL1,
        "cmCustomerAddressL2": cmCustomerAddressL2,
        "cmCustomerPinCode": cmCustomerPinCode,
        "cmCustomerIdproofUrl": cmCustomerIdproofUrl,
        "customerPhotoUrl": customerPhotoUrl,
        "cmCustomerDeviceId": cmCustomerDeviceId,
        "cmCustomerDeviceTypeId": cmCustomerDeviceTypeId,
        // "cmCustomerCountryId": cmCustomerCountryId,
        // "cmCustomerStateId": cmCustomerStateId,
        // "cmCustomerDistrictId": cmCustomerDistrictId,
        // "cmCustomerTownId": cmCustomerTownId,
        // "cmCustomerPlaceId": cmCustomerPlaceId,
        "cmCustomerSecret": cmCustomerSecret,
        "cmIsCustomerCardActive": cmIsCustomerCardActive,
        "cmCustomerCardActivateDateTime":
            cmCustomerCardActivateDateTime.toIso8601String(),
        "cmCustomerCardActivatedGpslocation":
            cmCustomerCardActivatedGpslocation,
        "cmIScustomerActive": cmIScustomerActive,
      };
}
