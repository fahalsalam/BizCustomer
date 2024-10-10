// To parse this JSON data, do
//
//     final categoriesM = categoriesMFromJson(jsonString);

import 'dart:convert';

List<CategoriesM> categoriesMFromJson(String str) => List<CategoriesM>.from(
    json.decode(str).map((x) => CategoriesM.fromJson(x)));

String categoriesMToJson(List<CategoriesM> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CategoriesM {
  int vendorClassificationId;
  String vendorClassificationName;
  dynamic vendorClassificationImageUrl;

  CategoriesM({
    required this.vendorClassificationId,
    required this.vendorClassificationName,
    required this.vendorClassificationImageUrl,
  });

  factory CategoriesM.fromJson(Map<String, dynamic> json) => CategoriesM(
        vendorClassificationId: json["vendorClassificationId"],
        vendorClassificationName: json["vendorClassificationName"],
        vendorClassificationImageUrl: json["vendorClassificationImageURL"],
      );

  Map<String, dynamic> toJson() => {
        "vendorClassificationId": vendorClassificationId,
        "vendorClassificationName": vendorClassificationName,
        "vendorClassificationImageURL": vendorClassificationImageUrl,
      };
}
