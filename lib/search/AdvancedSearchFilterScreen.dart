import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:reward_hub_customer/Utils/constants.dart';
import 'package:reward_hub_customer/wallet/wallet_store_model.dart';

import '../Utils/urls.dart';

class AdvancedSearchFilterScreen extends StatefulWidget {
  final String? selectedDistrictId;
  final String? selectedTownId;
  final String? selectedPlaceId;
  final String? selectedDistrictName;
  final String? selectedTownName;
  final String? selectedPlaceName;

  AdvancedSearchFilterScreen({
    this.selectedDistrictId,
    this.selectedTownId,
    this.selectedPlaceId,
    this.selectedDistrictName,
    this.selectedTownName,
    this.selectedPlaceName,
  });

  @override
  _AdvancedSearchFilterScreenState createState() =>
      _AdvancedSearchFilterScreenState();
}

class _AdvancedSearchFilterScreenState
    extends State<AdvancedSearchFilterScreen> {
  TextEditingController districtController = TextEditingController();
  TextEditingController townController = TextEditingController();
  TextEditingController placeController = TextEditingController();

  List<Map<String, dynamic>> districts = [];
  List<Map<String, dynamic>> towns = [];
  List<Map<String, dynamic>> places = [];

  String? selectedDistrictId;
  String? selectedTownId;
  String? selectedPlaceId;
  String? selectedDistrictName;
  String? selectedTownName;
  String? selectedPlaceName;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
    // Populate fields with initial values
    selectedDistrictId = widget.selectedDistrictId;
    selectedTownId = widget.selectedTownId;
    selectedPlaceId = widget.selectedPlaceId;
    selectedDistrictName = widget.selectedDistrictName;
    selectedTownName = widget.selectedTownName;
    selectedPlaceName = widget.selectedPlaceName;
  }

  Future<void> fetchInitialData() async {
    final String token = Constants().token;
    final response = await http.get(
      Uri.parse(Urls.getMastersCombo),
      headers: {
        'Token': token,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['isSuccess']) {
        setState(() {
          districts = (data['data']['district'] as List)
              .map<Map<String, dynamic>>((item) => {
                    'id': item['DistrictID'].toString(),
                    'name': item['DistrictName'].toString(),
                  })
              .toList();
          towns = (data['data']['town'] as List)
              .map<Map<String, dynamic>>((item) => {
                    'id': item['TopwnID'].toString(),
                    'name': item['TownName'].toString(),
                  })
              .toList();
          places = (data['data']['place'] as List)
              .map<Map<String, dynamic>>((item) => {
                    'id': item['PlaceID'].toString(),
                    'name': item['PlaceName'].toString(),
                  })
              .toList();

          // Update controllers with the names of the selected filters
          if (selectedDistrictId != null) {
            districtController.text = districts.firstWhere(
                (element) => element['id'] == selectedDistrictId)['name'];
          }
          if (selectedTownId != null) {
            townController.text = towns.firstWhere(
                (element) => element['id'] == selectedTownId)['name'];
          }
          if (selectedPlaceId != null) {
            placeController.text = places.firstWhere(
                (element) => element['id'] == selectedPlaceId)['name'];
          }
        });
      }
    } else {
      // Handle the error case
      print('Failed to load initial data');
    }
  }

  Future<List<Map<String, dynamic>>> fetchSuggestions(
      String query, String filterMode) async {
    // if (query.length < 3) {
    //   return [];
    // }
    final String token = Constants().token;
    final response = await http.get(
      Uri.parse(Urls.getMastersFilterCombo),
      headers: {
        'Token': token,
        'filterMode': filterMode,
        'filterValues': query,
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['isSuccess']) {
        return (data['data'] as List).map<Map<String, dynamic>>((item) {
          if (filterMode == 'T') {
            return {
              'id': item['TopwnID'].toString(),
              'name': item['TownName'].toString(),
            };
          } else if (filterMode == 'P') {
            return {
              'id': item['PlaceID'].toString(),
              'name': item['PlaceName'].toString(),
            };
          }
          return {};
        }).toList();
      }
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        title: Text(
          'ADVANCED SEARCH',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select District',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            buildAutoCompleteField(
              hintText: 'District',
              controller: districtController,
              suggestionsCallback: (query) async {
                return districts; // Preloaded districts
              },
              onSuggestionSelected: (suggestion) {
                setState(() {
                  selectedDistrictId = suggestion['id'];
                  selectedDistrictName = suggestion['name'];
                  districtController.text = suggestion['name'];
                });
              },
            ),
            SizedBox(height: 16.h),
            Text(
              'Select Town',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            buildAutoCompleteField(
              hintText: 'City',
              controller: townController,
              suggestionsCallback: (query) async {
                return await fetchSuggestions(query, 'T'); // API call for Town
              },
              onSuggestionSelected: (suggestion) {
                setState(() {
                  selectedTownId = suggestion['id'];
                  selectedTownName = suggestion['name'];
                  townController.text = suggestion['name'];
                });
              },
            ),
            SizedBox(height: 16.h),
            Text(
              'Select Place',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            buildAutoCompleteField(
              hintText: 'Place',
              controller: placeController,
              suggestionsCallback: (query) async {
                return await fetchSuggestions(query, 'P'); // API call for Place
              },
              onSuggestionSelected: (suggestion) {
                setState(() {
                  selectedPlaceId = suggestion['id'];
                  selectedPlaceName = suggestion['name'];
                  placeController.text = suggestion['name'];
                });
              },
            ),
            Spacer(), // This pushes the button to the bottom
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () async {
                  EasyLoading.show(
                    dismissOnTap: false,
                    maskType: EasyLoadingMaskType.black,
                  );

                  try {
                    final String token = Constants().token;
                    final String apiUrl = Urls.stores;

                    final response = await http.get(
                      Uri.parse(apiUrl),
                      headers: {
                        'Token': token,
                        'pageNo': '1',
                        'pageSize': '10',
                        'districtId': selectedDistrictId ?? '',
                        'townID': selectedTownId ?? '',
                        'placeID': selectedPlaceId ?? '',
                      },
                    );

                    if (response.statusCode == 200) {
                      final data = json.decode(response.body);
                      if (data['isSuccess']) {
                        Navigator.of(context).pop({
                          'data': data,
                          'selectedDistrictId': selectedDistrictId,
                          'selectedTownId': selectedTownId,
                          'selectedPlaceId': selectedPlaceId,
                          'selectedDistrictName': selectedDistrictName,
                          'selectedTownName': selectedTownName,
                          'selectedPlaceName': selectedPlaceName,
                        });
                        EasyLoading.dismiss();
                      } else {
                        EasyLoading.showError('Failed to fetch vendors');
                        EasyLoading.dismiss();
                      }
                    } else {
                      EasyLoading.showError('Error: ${response.statusCode}');
                      EasyLoading.dismiss();
                    }
                  } catch (e) {
                    print('Unexpected error: $e');
                    EasyLoading.showError('Unexpected error occurred');
                    EasyLoading.dismiss();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants().appColor,
                  // Customize your color here
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'ENTER',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAutoCompleteField({
    required String hintText,
    required TextEditingController controller,
    required Future<List<Map<String, dynamic>>> Function(String)
        suggestionsCallback,
    required Function(Map<String, dynamic>) onSuggestionSelected,
  }) {
    return TypeAheadFormField<Map<String, dynamic>>(
      textFieldConfiguration: TextFieldConfiguration(
        controller: controller,
        decoration: InputDecoration(
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey.shade200,
          contentPadding:
              EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey,
              width: 1,
            ),
          ),
        ),
      ),
      suggestionsCallback: suggestionsCallback,
      itemBuilder: (context, Map<String, dynamic> suggestion) {
        return ListTile(
          title: Text(
            suggestion['name'],
            style: TextStyle(fontSize: 16.sp),
          ),
        );
      },
      onSuggestionSelected: onSuggestionSelected,
      transitionBuilder: (context, suggestionsBox, controller) {
        return suggestionsBox;
      },
      hideOnError: true,
      hideSuggestionsOnKeyboardHide: true,
    );
  }
}
