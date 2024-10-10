// // To parse this JSON data, do
// //
// //     final userModel = userModelFromJson(jsonString);

// import 'dart:convert';

// List<UserModel> userModelFromJson(String str) =>
//     List<UserModel>.from(json.decode(str).map((x) => UserModel.fromJson(x)));

// String userModelToJson(List<UserModel> data) =>
//     json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

// class UserModel {
//   String verificationStatus;
//   String customerName;
//   num customerId;
//   var mobileNumber;
//   var cardNumber;
//   var walletbalance;
//   String customerDeviceId;
//   String customerSecret;
//   var cardActive;
//   DateTime cardRenewalDate;

//   UserModel({
//     required this.verificationStatus,
//     required this.customerId,
//     required this.customerName,
//     required this.mobileNumber,
//     required this.cardNumber,
//     required this.walletbalance,
//     required this.customerDeviceId,
//     required this.customerSecret,
//     required this.cardActive,
//     required this.cardRenewalDate,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
//         verificationStatus: json["verificationStatus"],
//         customerId: json["customer_id"] ,
//         customerName: json["customerName"]??"",
//         mobileNumber: json["mobileNumber"],
//         cardNumber: json["cardNumber"]??"",
//         walletbalance: json["walletbalance"]??0,
//         customerDeviceId: json["customerDeviceID"]??"",
//         customerSecret: json["customerSecret"]??"",
//         cardActive: json["cardActive"]??"",
//        cardRenewalDate: json["cardRenewalDate"] != null
//             ? DateTime.parse(json["cardRenewalDate"])
//             : DateTime.now().subtract(Duration(days: 1)),

//       );

//   Map<String, dynamic> toJson() => {
//         "verificationStatus": verificationStatus,
//         "customer_id" : customerId,
//         "customerName": customerName,
//         "mobileNumber": mobileNumber,
//         "cardNumber": cardNumber,
//         "walletbalance": walletbalance,
//         "customerDeviceID": customerDeviceId,
//         "customerSecret": customerSecret,
//         "cardActive": cardActive,
//         "cardRenewalDate": cardRenewalDate.toIso8601String(),
//       };
// }
// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

List<UserModel> userModelFromJson(String str) =>
    List<UserModel>.from(json.decode(str).map((x) => UserModel.fromJson(x)));

String userModelToJson(List<UserModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class UserModel {
  String verificationStatus;
  num customerID;
  String customerName;
  num mobileNumber;
  num cardNumber;
  num walletbalance;
  String customerDeviceId;
  String customerSecret;
  num cardActive;
  DateTime cardRenewalDate;
  num customerDailyLimit;
  num maxRedemptionAmountPerDay;
  num minRedemptionAmount;
  num minWalletBalance;

  UserModel({
    required this.verificationStatus,
    required this.customerID,
    required this.customerName,
    required this.mobileNumber,
    required this.cardNumber,
    required this.walletbalance,
    required this.customerDeviceId,
    required this.customerSecret,
    required this.cardActive,
    required this.cardRenewalDate,
    required this.customerDailyLimit,
    required this.maxRedemptionAmountPerDay,
    required this.minRedemptionAmount,
    required this.minWalletBalance,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        verificationStatus: json["verificationStatus"] ?? '',
        customerID: json["customerID"] ?? 0,
        customerName: json["customerName"] ?? '',
        mobileNumber: json["mobileNumber"] ?? 0,
        cardNumber: json["cardNumber"] ?? 0,
        walletbalance: json["walletbalance"] ?? 0,
        customerDeviceId: json["customerDeviceID"] ?? '',
        customerSecret: json["customerSecret"] ?? '',
        cardActive: json["cardActive"] ?? 0,
        cardRenewalDate: json["cardRenewalDate"] != null
            ? DateTime.tryParse(json["cardRenewalDate"]) ?? DateTime.now()
            : DateTime.now(),
        customerDailyLimit: json["customerDailyLimit"] ?? 0.00,
        maxRedemptionAmountPerDay: json["maxRedemptionAmountPerDay"] ?? 0.00,
        minRedemptionAmount: json["minRedemptionAmount"] ?? 0.00,
        minWalletBalance: json["minWalletBalance"] ?? 0.00,
      );

  Map<String, dynamic> toJson() => {
        "verificationStatus": verificationStatus,
        "customerID": customerID,
        "customerName": customerName,
        "mobileNumber": mobileNumber,
        "cardNumber": cardNumber,
        "walletbalance": walletbalance,
        "customerDeviceID": customerDeviceId,
        "customerSecret": customerSecret,
        "cardActive": cardActive,
        "cardRenewalDate": cardRenewalDate.toIso8601String(),
        "customerDailyLimit": customerDailyLimit,
        "maxRedemptionAmountPerDay": maxRedemptionAmountPerDay,
        "minRedemptionAmount": minRedemptionAmount,
        "minWalletBalance": minWalletBalance,
      };
}
