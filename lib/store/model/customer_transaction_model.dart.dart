import 'dart:convert';

List<CustomerTransactionModel> customerTransactionModelFromJson(String str) =>
    List<CustomerTransactionModel>.from(
        json.decode(str).map((x) => CustomerTransactionModel.fromJson(x)));

String customerTransactionModelToJson(List<CustomerTransactionModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CustomerTransactionModel {
  String transactionType;
  DateTime dateTime;
  num value;
  String vendorName;

  CustomerTransactionModel(
      {required this.transactionType,
      required this.dateTime,
      required this.value,
      required this.vendorName});

  factory CustomerTransactionModel.fromJson(Map<String, dynamic> json) =>
      CustomerTransactionModel(
        transactionType: json["transactionType"],
        dateTime: DateTime.parse(json["dateTime"]),
        value: json["value"],
        vendorName: json["vendorName"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "transactionType": transactionType,
        "dateTime": dateTime.toIso8601String(),
        "value": value,
        "vendorName": vendorName,
      };
}
