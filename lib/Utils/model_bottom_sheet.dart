import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reward_hub_customer/Utils/constants.dart';
import 'package:reward_hub_customer/Utils/urls.dart';
import 'package:reward_hub_customer/store/model/search_town_model.dart';
import 'package:reward_hub_customer/store/model/store_model.dart';
import 'package:http/http.dart' as http;
import 'package:reward_hub_customer/store/store_filter_store_details.dart';

class BottomSheetContent extends StatefulWidget {
  final List<StoreModel> storesList;

  BottomSheetContent({Key? key, required this.storesList}) : super(key: key);

  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  TextEditingController searchController = TextEditingController();
  List<StoreModel> filteredStoresList = [];
  List<PlaceModel> places = [];
  List<PlaceModel> filteredPlaces = [];

  @override
  void initState() {
    super.initState();
    fetchPlaces();
  }

  Future<void> fetchPlaces() async {
    final String apiUrl = Urls.getPlaceData;
    final String token = Constants().token;

    try {
      EasyLoading.show(
          status: 'Please Wait...',
          dismissOnTap: false,
          maskType: EasyLoadingMaskType.black);

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Token': token,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          places = placeModelFromJson(response.body);
          filteredPlaces = places;
          print("PLaces:>>>|||>>:$filteredPlaces");
        });
      } else {
        throw Exception('Failed to fetch data from API');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  void filterPlaces(String query) {
    setState(() {
      String trimmedQuery = query.trim();
      filteredPlaces = places
          .where((place) => place.placeName
              .toLowerCase()
              .contains(trimmedQuery.toLowerCase()))
          .toList();
      filteredPlaces.sort((a, b) => a.placeName.compareTo(b.placeName));
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top search field
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the bottom sheet
                  },
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 52.h,
                width: double.infinity - 50,
                child: TextFormField(
                  controller: searchController,
                  onChanged: filterPlaces,
                  decoration: InputDecoration(
                      hintText: "Search Place",
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Constants().appColor,
                          ),
                          borderRadius: BorderRadius.circular(8)),
                      disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Constants().appColor,
                          ),
                          borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Constants().appColor,
                          ),
                          borderRadius: BorderRadius.circular(8)),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
              ),
            ),
            // List view builder with filtered places
            Expanded(
              child: ListView.builder(
                itemCount: filteredPlaces.length,
                itemBuilder: (context, index) {
                  String firstLetter =
                      filteredPlaces[index].placeName.substring(0, 1);
                  filteredPlaces
                      .sort((a, b) => a.placeName.compareTo(b.placeName));

                  return GestureDetector(
                    onTap: () {
                      handleCategoryTap(
                          filteredPlaces[index].placeId.toString());
                      Navigator.of(context).pop();
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => StroreFilterStoreDetails(
                          placeId: filteredPlaces[index].placeId.toString(),
                        ),
                      ));
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Constants().appColor,
                        child: Text(firstLetter),
                      ),
                      title: Text('${filteredPlaces[index].placeName}'),
                      subtitle: Text('${filteredPlaces[index].townName}'),
                      // Add other ListTile properties as needed
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void handleCategoryTap(String VendorPlaceID) {
    int vendorPlaceId = int.tryParse(VendorPlaceID.toString()) ?? 0;
    if (vendorPlaceId > 0) {
      // Implement logic for handling category tap
    } else {
      // Implement logic for handling category tap
    }
  }
}
