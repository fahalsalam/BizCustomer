import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:reward_hub_customer/Utils/constants.dart';
import 'package:reward_hub_customer/Utils/urls.dart';
import 'package:reward_hub_customer/search/search_store_details.dart';
import 'package:reward_hub_customer/store/model/search_town_model.dart';

class SearchScreen2 extends StatefulWidget {
  const SearchScreen2({super.key});

  @override
  State<SearchScreen2> createState() => _SearchScreen2State();
}

DateTime? currentBackPressTime;

List<PlaceModel> places = [];
List<PlaceModel> filteredPlaces = [];
final TextEditingController _searchController = TextEditingController();
FocusNode searchFocus = FocusNode();

class _SearchScreen2State extends State<SearchScreen2> {
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentBackPressTime == null ||
            DateTime.now().difference(currentBackPressTime!) >
                Duration(seconds: 1)) {
          // Show a toast or snackbar indicating that the user should double tap to exit
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );

          // Update the currentBackPressTime
          currentBackPressTime = DateTime.now();
          return false; // Do not exit the app
        } else {
          // The user has double-tapped within 2 seconds, exit the app
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
            title: Text(
              "Search Place",
              style:
                  TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
            ),
            centerTitle: true,
            elevation: 0.0,
            backgroundColor: Colors.white),
        // body: Stack(
        //   children: [
        //   Sample2()
        //   ],
        // ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextFormField(
                    // keyboardAppearance: Brightness.dark,
                    focusNode: searchFocus,
                    controller: _searchController,
                    onChanged: (value) {
                      filterPlaces(value);
                    },
                    decoration: InputDecoration(
                      hintText: "Search...",
                      //  hintStyle: TextStyle(fontSize: 12.0.sp, color: Colors.grey[400]),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 8.0),
                      suffixIcon: _searchController.text.isEmpty
                          ? Icon(
                              Icons.search,
                              color: Constants().appColor,
                            )
                          : InkWell(
                              onTap: () {
                                _searchController.clear();
                                filterPlaces('');
                                searchFocus.unfocus();
                              },
                              child: Icon(
                                Icons.close,
                                color: Constants().appColor,
                              ),
                            ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Constants().appColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Constants().appColor),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              filteredPlaces.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          physics: filteredPlaces.length == 0
                              ? NeverScrollableScrollPhysics()
                              : ClampingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: filteredPlaces.length,
                          itemBuilder: (context, index) {
                            filteredPlaces.sort(
                                (a, b) => a.placeName.compareTo(b.placeName));
                            final place = filteredPlaces[index];

                            return GestureDetector(
                              onTap: () {
                                handleCategoryTap(
                                    filteredPlaces[index].placeId.toString());
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) =>
                                      SearchStoreDetailsScreen(
                                    placeId: filteredPlaces[index]
                                        .placeId
                                        .toString(),
                                  ),
                                ));
                              },
                              child: ListTile(
                                leading: CircleAvatar(
                                    child: Text(
                                      place.placeName
                                          .substring(0, 1)
                                          .toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    backgroundColor: const Color.fromARGB(
                                        255, 219, 205, 164)),
                                title: Text(place.placeName),
                                subtitle: Text(place.townName),
                              ),
                            );
                          }),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Text("No Data Found..."),
                        )
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }

// void filterPlaces(String query) {
//     setState(() {
//       filteredPlaces = places
//           .where(
//             (place) =>
//                 place.placeName.toLowerCase().contains(query.toLowerCase()) ||
//                 place.townName.toLowerCase().contains(query.toLowerCase()),
//           )
//           .toList();

//       filteredPlaces.sort((a, b) {
//         bool aPlaceNameStartsWithQuery =
//             a.placeName.toLowerCase().startsWith(query.toLowerCase());
//         bool bPlaceNameStartsWithQuery =
//             b.placeName.toLowerCase().startsWith(query.toLowerCase());

//         bool aTownNameStartsWithQuery =
//             a.townName.toLowerCase().startsWith(query.toLowerCase());
//         bool bTownNameStartsWithQuery =
//             b.townName.toLowerCase().startsWith(query.toLowerCase());

//         if (aPlaceNameStartsWithQuery && !bPlaceNameStartsWithQuery) {
//           return -1; // a place name comes first
//         } else if (!aPlaceNameStartsWithQuery && bPlaceNameStartsWithQuery) {
//           return 1; // b place name comes first
//         } else if (aTownNameStartsWithQuery && !bTownNameStartsWithQuery) {
//           return -1; // a town name comes first
//         } else if (!aTownNameStartsWithQuery && bTownNameStartsWithQuery) {
//           return 1; // b town name comes first
//         } else {
//           return a.placeName.compareTo(b.placeName); // sort alphabetically
//         }
//       });
//     });
//   }

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

  void handleCategoryTap(String VendorPlaceID) {
    int vendorPlaceId = int.tryParse(VendorPlaceID.toString()) ?? 0;
    if (vendorPlaceId > 0) {
      // Implement logic for handling category tap
    } else {
      // Implement logic for handling category tap
    }
  }
}
