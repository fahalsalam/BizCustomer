import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:page_transition/page_transition.dart';
import 'package:reward_hub_customer/Utils/constants.dart';
import 'package:reward_hub_customer/Utils/toast_widget.dart';
import 'package:reward_hub_customer/Utils/urls.dart';
import 'package:reward_hub_customer/store/StoreDetailScreen.dart';
import 'package:reward_hub_customer/store/model/search_town_model.dart';
import 'package:http/http.dart' as http;

import '../store/model/store_model.dart';

class SearchScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return SearchScreenState();
  }
}

class SearchScreenState extends State<SearchScreen> {
  List<PlaceModel> places = [];
  List<PlaceModel> filteredPlaces = [];
  List<StoreModel> masterStoreList = [];
  List<StoreModel> storesList = [];
  List<StoreModel> filteredStoresList = [];
  ScrollController _scrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();
  // bool isLoading = true;
  int currentPage = 1;
  int itemsPerPage = 100;

  String _searchQuery = '';

  bool isLoading = true;
  bool isSearchIconVisible = true;

  @override
  void initState() {
    super.initState();
    fetchPlaces();
    getSearchDetailsList(context);

    filteredPlaces = places;
    // Using WidgetsBinding to add a post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if the widget is still mounted before updating the state
      EasyLoading.show();
      if (mounted) {
        EasyLoading.dismiss();
        setState(() {
          isLoading = false;
        });
      }
    });
  }
  // void initState() {
  //   super.initState();
  //   EasyLoading.show();
  //   Future.delayed(Duration(seconds: 3), () {
  //     fetchPlaces();
  //     getSearchDetailsList(context);
  //     filteredPlaces = places;
  //     EasyLoading.dismiss();
  //     setState(() {
  //       isLoading = false;
  //     });
  //   });
  // }

  Future<void> fetchPlaces() async {
    final String apiUrl = Urls.getPlaceData;
    final String token = Constants().token;

    try {
      // setState(() {
      //   isLoading = true;
      // });
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Token': token,
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          places = placeModelFromJson(response.body);
          // places.sort((a, b) => a.placeName.compareTo(b.placeName));
          filteredPlaces = places;

          // filteredPlaces.sort((a, b) => a.placeName.compareTo(b.placeName));
          // isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data from API');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // const platform = MethodChannel('com.example.Bizatom/search_task_manager');

    // Future<bool> moveTaskToBack() async {
    //   try {
    //     final bool success = await platform.invokeMethod('moveTaskToBack');
    //     return success;
    //   } on PlatformException catch (e) {
    //     print('Failed to move task to back: $e');
    //     return false;
    //   }
    // }

    return
        // WillPopScope(
        //   onWillPop: () async {
        //     final shouldMoveToBack = await moveTaskToBack();
        //     if (!shouldMoveToBack) {
        //       // If moving to the back failed, use a different method to prevent app restart
        //       SystemNavigator
        //           .pop(); // Use SystemNavigator to send the app to the background
        //       return false; // Prevent further back navigation
        //     }
        //     return false; // Allow back navigation if successful

        //     // onWillPop: () async {
        //     //   final shouldMoveToBack = await moveTaskToBack();
        //     //   return shouldMoveToBack;

        //     // SystemNavigator.pop();
        //     // final shouldMoveToBack = await moveTaskToBack();
        //     // return shouldMoveToBack;
        //   },
        // child:
        Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Search Place",
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0.0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextFormField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  filteredPlaces = places
                      .where((place) =>
                          place.placeName
                              .toLowerCase()
                              .contains(value.toLowerCase()) ||
                          place.townName
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                      .toList();
                  isSearchIconVisible = value.isEmpty;
                });
              },
              decoration: InputDecoration(
                  hintText: "Search...",
                  suffixIcon: isSearchIconVisible
                      ? Icon(
                          Icons.search,
                          color: Constants().appColor,
                        )
                      : InkWell(
                          onTap: () {
                            setState(() {
                              _searchController.clear();
                              isSearchIconVisible = true;
                              filteredPlaces = places;
                            });
                          },
                          child: Icon(
                            Icons.close,
                            color: Constants().appColor,
                          ),
                        ),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6))),
            ),
            const SizedBox(height: 10),
            filteredPlaces.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        physics: filteredPlaces.length == 0
                            ? NeverScrollableScrollPhysics()
                            : ClampingScrollPhysics(),
                        //  physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: filteredPlaces.length,
                        itemBuilder: (context, index) {
                          // filteredPlaces.sort(
                          //     (a, b) => a.placeName.compareTo(b.placeName));
                          final place = filteredPlaces[index];

                          return GestureDetector(
                            onTap: () {
                              handleCategoryTap(_searchQuery.isEmpty
                                  ? places[index].placeId.toString()
                                  : filteredPlaces[index].placeId.toString());
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                        appBar: AppBar(
                                          leading: GestureDetector(
                                              onTap: () {
                                                Navigator.pop(context);
                                              },
                                              child: Image.asset(
                                                "assets/images/ic_back_img.png",
                                                height: 37.h,
                                                width: 37.w,
                                              )),
                                          automaticallyImplyLeading: false,
                                          backgroundColor: Colors.white,
                                          title: Text(
                                            "STORE DETAILS",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          centerTitle: true,
                                          elevation: 0.0,
                                        ),
                                        body: searchDetails(),
                                      )));
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
                                  backgroundColor:
                                      const Color.fromARGB(255, 219, 205, 164)),
                              title: Text(place.placeName),
                              subtitle: Text(place.townName),
                            ),
                          );
                        }),
                  )
                : Center(
                    child: Text(
                      '',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
    // );
  }

  Widget searchDetails() {
    // var filteredStores = filterStoresByClassificationId(categoryId.toString());
    //  storesList.sort((a, b) => a.placeName.compareTo(b.placeName));
    var filteredStores = storesList
        .where((store) =>
            store.placeName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    print("Search Query: $_searchQuery");
    print("Filtered Stores: $filteredStores");
    return filteredStores.isEmpty
        ? Center(
            child: Text("No Vendors Found"),
          )
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GridView.builder(
                    // physics: AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    controller: _scrollController,
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 1,
                      mainAxisSpacing: 1,
                    ),
                    itemCount: _searchQuery.isNotEmpty
                        ? filteredStores.length
                        : storesList.length,
                    itemBuilder: (BuildContext ctx, index) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.rightToLeft,
                              child: StoreDetailScreen(_searchQuery.isEmpty
                                  ? storesList[index]
                                  : filteredStores[index]),
                            ),
                          );
                        },
                        child: _searchQuery.isEmpty
                            ? Container(
                                margin:
                                    const EdgeInsets.only(left: 2, right: 2),
                                height: 50,
                                width: 122,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: storesList[index].imageURL1 == "null"
                                      ? const DecorationImage(
                                          image: AssetImage(
                                              "assets/images/ic_sample_image.png"),
                                          fit: BoxFit.fill,
                                        )
                                      : DecorationImage(
                                          image: NetworkImage(
                                              storesList[index].imageURL1),
                                          fit: BoxFit.fill,
                                        ),
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Shadow Image
                                    Positioned.fill(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: const DecorationImage(
                                            image: AssetImage(
                                                "assets/images/shadow.png"),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Text Section
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Text(
                                          storesList[index].name,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                margin:
                                    const EdgeInsets.only(left: 2, right: 2),
                                height: 50,
                                width: 122,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: filteredStores[index].imageURL1 ==
                                          "null"
                                      ? const DecorationImage(
                                          image: AssetImage(
                                              "assets/images/ic_sample_image.png"),
                                          fit: BoxFit.fill,
                                        )
                                      : DecorationImage(
                                          image: NetworkImage(
                                              filteredStores[index].imageURL1),
                                          fit: BoxFit.fill,
                                        ),
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Shadow Image
                                    Positioned.fill(
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: const DecorationImage(
                                            image: AssetImage(
                                                "assets/images/shadow.png"),
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Text Section
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Text(
                                          filteredStores[index].name,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
  }

  Future<http.Response> getSearchDetailsList(BuildContext context,
      {bool reset = false}) async {
    try {
      if (reset) {
        storesList.clear();
        filteredStoresList.clear();
        masterStoreList.clear();
        currentPage = 1;
      }
      EasyLoading.show();

      final Map<String, String> headers = {
        'Token': Constants().token,
        'strPageno': currentPage.toString(),
        'strPagecount': itemsPerPage.toString(),
      };

      final response = await http.get(Uri.parse(Urls.stores), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        if (data['transactionStatus'] == true) {
          List<StoreModel> stores = parseStores(data['vendors']);
          // Check if the widget is still mounted before updating the state
          if (mounted) {
            setState(() {
              storesList.addAll(stores);
              filteredStoresList = storesList;
              masterStoreList = storesList;
            });
          }
        } else {
          showErrorToast("No vendors found.");
        }
      } else {
        showErrorToast(
            "Failed to fetch data. Status code: ${response.statusCode}");
      }
      return response;
    } catch (error) {
      showErrorToast("An error occurred: $error");
      return http.Response('Error', 500);
    } finally {
      // Check if the widget is still mounted before dismissing the loading indicator
      if (mounted) {
        EasyLoading.dismiss();
      }
    }
  }

  // Future<http.Response> getSearchDetailsList(BuildContext context,
  //     {bool reset = false}) async {
  //   try {
  //     if (reset) {
  //       storesList.clear();
  //       filteredStoresList.clear();
  //       masterStoreList.clear();
  //       currentPage = 1;
  //     }
  //     EasyLoading.show();

  //     final Map<String, String> headers = {
  //       'Token': Constants().token,
  //       'strPageno': currentPage.toString(),
  //       'strPagecount': itemsPerPage.toString(),
  //     };

  //     final response = await http.get(Uri.parse(Urls.stores), headers: headers);

  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = json.decode(response.body);

  //       if (data['transactionStatus'] == true) {
  //         List<StoreModel> stores = parseStores(data['vendors']);
  //         setState(() {
  //           storesList.addAll(stores);
  //           filteredStoresList = storesList;
  //           masterStoreList = storesList;
  //         });
  //       } else {
  //         showErrorToast("No vendors found.");
  //       }
  //     } else {
  //       showErrorToast(
  //           "Failed to fetch data. Status code: ${response.statusCode}");
  //     }
  //     return response;
  //   } catch (error) {
  //     showErrorToast("An error occurred: $error");
  //     return http.Response('Error', 500);
  //   } finally {
  //     EasyLoading.dismiss();
  //   }
  // }

  List<StoreModel> parseStores(List<dynamic> vendors) {
    return vendors.map<StoreModel>((obj) {
      return StoreModel(
        obj['VendorId']?.toString() ?? '',
        obj['VendorBusinessName']?.toString() ?? '',
        obj['VendorMobileNumber']?.toString() ?? '',
        obj['VendorClassificationID']?.toString() ?? '',
        obj['VendorClassificationName']?.toString() ?? '',
        obj['VendorCategories']?.toString() ?? '',
        obj['VendorAddressL1']?.toString() ?? '',
        obj['VendorAddressL2']?.toString() ?? '',
        obj['VendorPinCode']?.toString() ?? '',
        obj['VendorGpslocation']?.toString() ?? '',
        obj['VendorBusinessPicUrl1']?.toString() ?? '',
        obj['VendorBusinessPicUrl2']?.toString() ?? '',
        obj['VendorBusinessPicUrl3']?.toString() ?? '',
        obj['VendorBusinessPicUrl4']?.toString() ?? '',
        obj['VendorBusinessPicUrl5']?.toString() ?? '',
        obj['VendorBusinessPicUrl6']?.toString() ?? '',
        obj['VendorCountryId']?.toString() ?? '',
        obj['VendorCountryName']?.toString() ?? '',
        obj['VendorStateId']?.toString() ?? '',
        obj['VendorStateName']?.toString() ?? '',
        obj['VendorDistrictId']?.toString() ?? '',
        obj['VendorDistrictName']?.toString() ?? '',
        obj['VendorTownId']?.toString() ?? '',
        obj['VendorTownName']?.toString() ?? '',
        obj['VendorPlaceID']?.toString() ?? '',
        obj['VendorPlaceName']?.toString() ?? '',
        obj['VendorPlaceName']?.toString() ?? '',
        obj['VendorRegisteredMobileNumber']?.toString() ?? '',
        obj['LandMark']?.toString() ?? '',
      );
    }).toList();
  }

  void showErrorToast(String message) {
    ToastWidget().showToastError(message);
  }

  void handleCategoryTap(String VendorPlaceID) {
    int vendorPlaceId = int.tryParse(VendorPlaceID.toString()) ?? 0;
    if (vendorPlaceId > 0) {
      storesList = masterStoreList
          .where((store) => store.placeID == VendorPlaceID.toString())
          .toList();
    } else {
      storesList = masterStoreList;
      // masterStoreList.sort((a, b) => a.placeName.compareTo(b.placeName));
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
    _searchController.dispose();
  }
}
