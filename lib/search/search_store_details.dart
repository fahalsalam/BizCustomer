import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:reward_hub_customer/Utils/constants.dart';
import 'package:reward_hub_customer/Utils/urls.dart';
import 'package:reward_hub_customer/search/store_details.dart';
import 'package:reward_hub_customer/store/model/search_filter_store_model.dart'
    as filter;
import 'package:reward_hub_customer/store/model/search_vendor_details.dart';
import 'package:reward_hub_customer/store/store_screen.dart';

class SearchStoreDetailsScreen extends StatefulWidget {
  final String placeId;

  SearchStoreDetailsScreen({
    Key? key,
    required this.placeId,
  }) : super(key: key);

  @override
  State<SearchStoreDetailsScreen> createState() =>
      _SearchStoreDetailsScreenState();
}

TextEditingController _textEditingController = TextEditingController();
FocusNode _searchFocusNode = FocusNode();

class _SearchStoreDetailsScreenState extends State<SearchStoreDetailsScreen> {
  List<Vendor> stores = [];
  List<Vendor> filteredStorees = [];
  // List<filter. Vendor> searchStores = [];
  // List<filter. Vendor> filteredsearchStorees = [];
  ScrollController _scrollController = ScrollController();
  late filter.StoreSearchFilterModel filterVendorModel =
      filter.StoreSearchFilterModel();
  String _searchQuery = '';
  int pageNo = 1; // Track the current page number
  int pageSize = 20; // Number of items to load per page
  var filterpageNo = 1;
  var filterpageCount = 20;

  @override
  void initState() {
    super.initState();
    cleartextFeild();
    _scrollController.addListener(_scrollListener);
    _scrollController.addListener(_scrollListenerForFilterStore);
    print("Place ID:>>>${widget.placeId}");
    // loadStoresDataBySearch();
    resetPageNo();
    loadStoresData();
  }

  Future<void> loadStoresData() async {
    try {
      EasyLoading.show(
        dismissOnTap: false,
        status: 'Please Wait...',
        maskType: EasyLoadingMaskType.black,
      );

      final result = await getApprovedVendors(
        token: Constants().token,
        pageNo: pageNo,
        pagecount: pageSize,
        placeId: int.parse(widget.placeId),
      );

      setState(() {
        stores.addAll(result.vendors);
        filteredStorees = stores;
        pageNo++; // Increment the page number for the next load
      });
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<PlaceSearchByVendorDetailsModel> getApprovedVendors({
    required String token,
    required int pageNo,
    required int pagecount,
    required int placeId,
  }) async {
    final String apiUrl = Urls.getApprovedVendorsByPlace;

    final Map<String, String> headers = {
      'Token': token,
      'pageno': pageNo.toString(),
      'pagecount': pagecount.toString(),
      'PlaceID': placeId.toString(),
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return PlaceSearchByVendorDetailsModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch data from API');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error occurred while making the API call');
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // User has reached the end of the list, load more data
      loadStoresData();
    }
  }

  void _scrollListenerForFilterStore() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _loadfilterMoreItems();
      });
    }
  }

  void filterStores(String query) {
    setState(() {
      filteredStorees = stores
          .where(
            (place) => place.vendorBusinessName
                .toLowerCase()
                .contains(query.toLowerCase()),
          )
          .toList();
      filteredStorees
          .sort((a, b) => a.vendorBusinessName.compareTo(b.vendorPlaceName));
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  /// for store filter search
  static Future<filter.StoreSearchFilterModel> getFilteredVendors({
    required String token,
    required int pageNo,
    required int pagecount,
    required String filterText,
    required int placeId,
  }) async {
    final String apiUrl = Urls.getFilteredApprovedSearchByPlaceId;

    final Map<String, String> headers = {
      'Token': token,
      'strPageNo': pageNo.toString(),
      'strPageCount': pagecount.toString(),
      'fltrText': filterText,
      'placeId': placeId.toString(),
    };
    print("Headers:>>>$headers");
    try {
      EasyLoading.show(
        status: 'Please wait...',
        dismissOnTap: true,
        maskType: EasyLoadingMaskType.black,
      );
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("Response data :>>>$data");
        return filter.StoreSearchFilterModel.fromJson(data);
      } else {
        throw Exception('Failed to fetch data from API');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Error occurred while making the API call');
    } finally {
      EasyLoading.dismiss();
    }
  }

//   Future<void> loadStoresDataBySearch() async {
//   try {
//     EasyLoading.show(
//       dismissOnTap: false,
//       status: 'Please Wait...',
//       maskType: EasyLoadingMaskType.black,
//     );

//     final result = await getFilteredVendors(
//       token: Constants().token,
//       pageNo: pageNo,
//       pagecount: pageSize,
//       filterText: _textEditingController.text,
//       placeId: int.parse(widget.placeId),
//     );

//     setState(() {
//       searchStores.addAll(result.vendors);
//       filteredsearchStorees = searchStores;
//       pageNo++; // Increment the page number for the next load
//     });
//   } catch (e) {
//     print('Error loading data: $e');
//   } finally {
//     EasyLoading.dismiss();
//   }
// }

  void onSearchIconClicked() async {
    filterVendorModel = await getFilteredVendors(
      token: Constants().token,
      pageNo: filterpageNo,
      pagecount: filterpageCount,
      filterText: _searchQuery,
      placeId: int.parse(widget.placeId),
    );
    if (mounted) {
      setState(() {});
    }

    fetchData(); // Call your data fetch method
  }

  void fetchData() async {
    // String token = Constants().token;
    try {
      filter.StoreSearchFilterModel filterVendorModel =
          await getFilteredVendors(
        token: Constants().token,
        pageNo: filterpageNo,
        pagecount: filterpageCount,
        filterText: _searchQuery,
        placeId: int.parse(widget.placeId),
      );
      // Use filterVendorModel as needed
      print('Total Records: ${filterVendorModel.totalRecords}');
      print('Vendors: ${filterVendorModel.vendorss}');
      if (mounted) {
        setState(() {
          // Update the state to trigger a rebuild
        });
      }
    } catch (error) {
      print('Error: $error');
      // Handle error
    }
  }

  void cleartextFeild() {
    _textEditingController.clear();
  }

  void resetPageNo() {
    filterpageNo = 1;
  }

  void _loadfilterMoreItems() {
    filterpageNo++;

    getFilteredVendors(
      token: Constants().token,
      pageNo: filterpageNo,
      pagecount: filterpageCount,
      filterText: _searchQuery,
      placeId: int.parse(widget.placeId),
    ).then((filterVendorResponse) {
      if (mounted) {
        setState(() {
          filterVendorModel.vendorss
              ?.addAll(filterVendorResponse.vendorss ?? []);
        });
      }
    });
    // getApprovedVendorsByfilter(
    //   Constants().token,
    //   filterpageNo,
    //   filterpageCount,
    //   _searchQuery,
    // ).then((filterVendorResponse) {
    //   if (mounted) {
    //     setState(() {
    //       // Append the new data to the existing list
    //       filterVendorModel.vendorss
    //           ?.addAll(filterVendorResponse.vendorss ?? []);
    //     });
    //   }
    // });
  }

  void onSearchTextChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
      // Check if the search query is empty
      if (_searchQuery.isEmpty) {
        // Clear the filterVendorModel.vendorss list
        filterVendorModel.vendorss = [];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<filter.Vendor> filteredVendors = filterVendorModel.vendorss ?? [];
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Image.asset(
            "assets/images/ic_back_img.png",
            height: 37.h,
            width: 37.w,
          ),
        ),
        elevation: 0.0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          'Store List',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
            color: Colors.black,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: TextFormField(
                focusNode: _searchFocusNode,
                textInputAction: TextInputAction.search,
                onChanged: onSearchTextChanged,
                // onChanged: (value) {
                //   filterStores(value);
                // },
                controller: _textEditingController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 8.0),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Constants().appColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Constants().appColor),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      resetPageNo();
                      onSearchIconClicked();
                      _searchFocusNode.unfocus();
                      if (_textEditingController.text.isEmpty) {
                        filterVendorModel.vendorss = [];
                      }
                      // _textEditingController.clear();
                      // filterStores('');
                      // _searchFocusNode.unfocus();
                      // loadStoresDataBySearch();
                      // resetPageNo();
                    },
                    icon: Icon(
                      Icons.search,
                      color: Constants().appColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ((_searchQuery.isNotEmpty && filteredVendors.isEmpty) ||
                      (_searchQuery.isEmpty && filteredStorees.isEmpty))
                  ? Center(
                      child: Text(
                        "No Stores available.",
                        style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      controller: _scrollController,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 3.0,
                        mainAxisSpacing: 3.0,
                        childAspectRatio: 3 / 2,
                      ),
                      // itemCount: filteredStorees.length,
                      itemCount: _searchQuery.isNotEmpty
                          ? filteredVendors.length ?? 0
                          : filteredStorees.length,
                      itemBuilder: (context, index) {
                        //                       if ((_searchQuery.isNotEmpty && filteredVendors.isEmpty) ||
                        //     (_searchQuery.isEmpty && filteredStorees.isEmpty)) {
                        //   return Center(
                        //     child: Text(
                        //       _searchQuery.isNotEmpty
                        //           ? "No Vendors available."
                        //           : "No Stores available.",
                        //       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        //     ),
                        //   );
                        // }
                        return GestureDetector(
                          onTap: () {
                            if (mounted) {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: StoreDetails(
                                      storeList: _searchQuery.isEmpty
                                          ? filteredStorees[index]
                                          : filteredVendors[index]),
                                ),
                              );
                            }
                          },

                          // onTap: () {
                          //   Navigator.push(
                          //     context,
                          //     PageTransition(
                          //       type: PageTransitionType.rightToLeft,
                          //       child: StoreDetailScreen(_searchQuery.isEmpty
                          //           ? storesList[index]
                          //           : filteredStores[index]),
                          //     ),
                          //   );
                          // },
                          child: _searchQuery.isEmpty
                              ? Container(
                                  margin:
                                      const EdgeInsets.only(left: 2, right: 2),
                                  height: 50,
                                  width: 122,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: filteredStorees[index]
                                                .vendorBusinessPicUrl1 ==
                                            "null"
                                        ? const DecorationImage(
                                            image: AssetImage(
                                                "assets/images/store.jpg"),
                                            fit: BoxFit.fill,
                                          )
                                        : DecorationImage(
                                            image: CachedNetworkImageProvider(
                                                filteredStorees[index]
                                                    .vendorBusinessPicUrl1),
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
                                            filteredStorees[index]
                                                .vendorBusinessName,
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
                                    image: filteredVendors[index]
                                                .vendorBusinessPicUrl1 ==
                                            "null"
                                        ? const DecorationImage(
                                            image: AssetImage(
                                                "assets/images/ic_sample_image.png"),
                                            fit: BoxFit.fill,
                                          )
                                        : DecorationImage(
                                            image: NetworkImage(
                                                filteredVendors[index]
                                                    .vendorBusinessPicUrl1),
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
                                            filteredVendors[index]
                                                .vendorBusinessName,
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
                        //  return buildVendorItem();
                        // return Padding(
                        //   padding: const EdgeInsets.all(2.0),
                        //   child: GestureDetector(
                        //     onTap: () {
                        //       Navigator.push(
                        //         context,
                        //         PageTransition(
                        //           type: PageTransitionType.rightToLeft,
                        //           child: StoreDetails(
                        //             storeList: vendor,
                        //           ),
                        //         ),
                        //       );
                        //       _textEditingController.clear();
                        //       filterStores('');
                        //       _searchFocusNode.unfocus();
                        //     },
                        //     child: Container(
                        //       margin: const EdgeInsets.only(left: 2, right: 2),
                        //       height: 50,
                        //       width: 122,
                        //       decoration: BoxDecoration(
                        //         borderRadius: BorderRadius.circular(10),
                        //         image: filteredStorees[index]
                        //                     .vendorBusinessPicUrl1 ==
                        //                 "null"
                        //             ? const DecorationImage(
                        //                 image: AssetImage(
                        //                     "assets/images/store.jpg"),
                        //                 fit: BoxFit.fill,
                        //               )
                        //             : DecorationImage(
                        //                 image: CachedNetworkImageProvider(
                        //                     filteredStorees[index]
                        //                         .vendorBusinessPicUrl1),
                        //                 fit: BoxFit.fill,
                        //               ),
                        //       ),
                        //       child: Stack(
                        //         fit: StackFit.expand,
                        //         children: [
                        //           Positioned.fill(
                        //             child: DecoratedBox(
                        //               decoration: BoxDecoration(
                        //                 borderRadius: BorderRadius.circular(10),
                        //                 image: const DecorationImage(
                        //                   image: AssetImage(
                        //                       "assets/images/shadow.png"),
                        //                   fit: BoxFit.fill,
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //           Padding(
                        //             padding: const EdgeInsets.only(bottom: 10),
                        //             child: Align(
                        //               alignment: Alignment.bottomCenter,
                        //               child: Text(
                        //                 filteredStorees[index]
                        //                     .vendorBusinessName,
                        //                 style: const TextStyle(
                        //                   fontSize: 12,
                        //                   color: Colors.white,
                        //                   fontWeight: FontWeight.bold,
                        //                 ),
                        //                 textAlign: TextAlign.center,
                        //               ),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget buildVendorItem(dynamic vendor) {
  //   return Padding(
  //     padding: const EdgeInsets.all(2.0),
  //     child: GestureDetector(
  //       onTap: () {
  //         Navigator.push(
  //           context,
  //           PageTransition(
  //             type: PageTransitionType.rightToLeft,
  //             child: StoreDetails(
  //               storeList: vendor,
  //             ),
  //           ),
  //         );
  //       },
  //       child: Container(
  //         margin: const EdgeInsets.only(left: 2, right: 2),
  //         height: 50,
  //         width: 122,
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(10),
  //           image: vendor.vendorBusinessPicUrl1 == "null"
  //               ? const DecorationImage(
  //                   image: AssetImage("assets/images/store.jpg"),
  //                   fit: BoxFit.fill,
  //                 )
  //               : DecorationImage(
  //                   image: NetworkImage(vendor.vendorBusinessPicUrl1),
  //                   fit: BoxFit.fill,
  //                 ),
  //         ),
  //         child: Stack(
  //           fit: StackFit.expand,
  //           children: [
  //             Positioned.fill(
  //               child: DecoratedBox(
  //                 decoration: BoxDecoration(
  //                   borderRadius: BorderRadius.circular(10),
  //                   image: const DecorationImage(
  //                     image: AssetImage("assets/images/shadow.png"),
  //                     fit: BoxFit.fill,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             Padding(
  //               padding: const EdgeInsets.only(bottom: 10),
  //               child: Align(
  //                 alignment: Alignment.bottomCenter,
  //                 child: Text(
  //                   vendor.vendorBusinessName,
  //                   style: const TextStyle(
  //                     fontSize: 12,
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                   textAlign: TextAlign.center,
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
