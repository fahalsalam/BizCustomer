// To parse this JSON data, do
//
//     final placeModel = placeModelFromJson(jsonString);

import 'dart:convert';

List<PlaceModel> placeModelFromJson(String str) =>
    List<PlaceModel>.from(json.decode(str).map((x) => PlaceModel.fromJson(x)));

String placeModelToJson(List<PlaceModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class PlaceModel {
  int placeId;
  String placeName;
  int townId;
  String townName;

  PlaceModel({
    required this.placeId,
    required this.placeName,
    required this.townId,
    required this.townName,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) => PlaceModel(
        placeId: json["placeID"],
        placeName: json["placeName"],
        townId: json["townID"],
        townName: json["townName"],
      );

  Map<String, dynamic> toJson() => {
        "placeID": placeId,
        "placeName": placeName,
        "townID": townId,
        "townName": townName,
      };
}
