import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reward_hub_customer/Utils/SharedPrefrence.dart';
import 'package:reward_hub_customer/Utils/urls.dart';
import 'package:reward_hub_customer/store/model/user_model.dart';

class UserApiService {
  static const String baseUrl = Urls.baseUrl; // replace with your API base URL

  Future<UserModel?> getUserDetails(String token, String mobileNumber) async {
    final String apiUrl =
        Urls.login; // replace with your API endpoint for user details

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Content-type': 'application/json',
          'Accept': 'application/json',
          'Token': token,
          'MobileNumber': mobileNumber.toString(),
        },
      );

      if (response.statusCode == 200) {
        dynamic jsonResponse = json.decode(response.body);

        // Check if the jsonResponse is a List
        if (jsonResponse is List) {
          // Handle list items accordingly
          // For example, if you expect a list of user models:
          // SharedPrefrence().setCustomerId(jsonResponse[0].customerID);
          List<UserModel> users =
              jsonResponse.map((data) => UserModel.fromJson(data)).toList();

          return users.isNotEmpty ? users.first : null;
        }
        // If it's a Map
        else if (jsonResponse is Map<String, dynamic>) {
          // Parse the map and return a UserModel object
          return UserModel.fromJson(jsonResponse);
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        // If the server returns an error response, throw an exception
        throw Exception('Failed to load user details');
      }
    } catch (error) {
      // Handle any errors that occur during the HTTP request
      print(error.toString());
      throw Exception('Error fetching user details');
    }
  }
}
