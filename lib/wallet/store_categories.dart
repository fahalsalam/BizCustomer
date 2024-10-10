import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:reward_hub_customer/Utils/constants.dart';
import 'package:reward_hub_customer/Utils/urls.dart';
import 'package:reward_hub_customer/store/model/filter_model.dart' as filter;
import 'package:reward_hub_customer/wallet/wallet_store_details.dart';
import 'package:reward_hub_customer/wallet/wallet_store_model.dart';
import 'package:shimmer/shimmer.dart';

class StoreCategories extends StatefulWidget {
  final String selectedVendorClassificationId;
  final bool? fromCategories;

  const StoreCategories(
      {super.key,
      required this.selectedVendorClassificationId,
      this.fromCategories});

  @override
  State<StoreCategories> createState() => _StoreCategoriesState();
}

TextEditingController _textEditingController = TextEditingController();
FocusNode _searchFocusNode = FocusNode();

class _StoreCategoriesState extends State<StoreCategories> {
  List<Vendor> vendorsList = [];
  List<Vendor> filteredVendorsList = [];

  int pageNo = 1; // Initial page number
  int pageCount = 20000; // Number of items to fetch per page
  var filterpageNo = 1;
  var filterpageCount = 20;
  String _searchQuery = '';
  bool isLoading = false;
  bool isLoadingMore = false;
  ScrollController _scrollController = ScrollController();
  late filter.FilterVendorModel filterVendorModel = filter.FilterVendorModel();

  @override
  void initState() {
    super.initState();
    fetchData();
    print("vendor Id:${widget.selectedVendorClassificationId}");
    // _scrollController.addListener(_loadMoreItems);
    // _scrollController.addListener(_scrollListenerForFilterStore);
    // _scrollController.addListener(() {
    //   if (_scrollController.position.pixels ==
    //       _scrollController.position.maxScrollExtent) {
    //     loadMoreData();
    //   }
    // });
  }

  // void _scrollListenerForFilterStore() {
  //   if (_scrollController.position.pixels ==
  //       _scrollController.position.maxScrollExtent) {
  //     setState(() {
  //       _loadfilterMoreItems();
  //     });
  //   }
  // }

  // void _loadfilterMoreItems() {
  //   filterpageNo++;

  //   getApprovedVendorsByfilter(
  //     Constants().token,
  //     filterpageNo,
  //     filterpageCount,
  //     _searchQuery,
  //   ).then((filterVendorResponse) {
  //     if (mounted) {
  //       setState(() {
  //         // Append the new data to the existing list
  //         filterVendorModel.vendorss
  //             ?.addAll(filterVendorResponse.vendorss ?? []);
  //       });
  //     }
  //   });
  // }

  // Future<filter.FilterVendorModel> getApprovedVendorsByfilter(
  //   String token,
  //   int pageNo,
  //   int pageCount,
  //   String filterText,
  // ) async {
  //   final String apiUrl = Urls.getFilteredApprovedVendors;

  //   final Map<String, String> headers = {
  //     'Token': token,
  //     "strPageno": pageNo.toString(),
  //     "strPagecount": pageCount.toString(),
  //     'fltrText': filterText,
  //   };

  //   print("filterHeaders:>>>:$headers");

  //   late http.Response response; // Declare response variable

  //   try {
  //     EasyLoading.show(status: 'Please wait...', dismissOnTap: true);
  //     response = await http.get(Uri.parse(apiUrl), headers: headers);

  //     if (response.statusCode == 200) {
  //       // Parse JSON response into FilterVendorModel
  //       final Map<String, dynamic> jsonResponse = json.decode(response.body);
  //       print("Response:>>>${response.body}");
  //       print("Response:>>>${jsonResponse}");
  //       return filter.FilterVendorModel.fromJson(jsonResponse);
  //     } else {
  //       throw Exception('API call failed with status code ${response.body}');
  //     }
  //   } catch (error, stackTrace) {
  //     // Handle error
  //     print('Error: $error');
  //     print('Stack trace: $stackTrace');
  //     print('Response body: ${response.body}');
  //     throw Exception('Error: $error');
  //   } finally {
  //     EasyLoading.dismiss();
  //   }
  // }

  // void filterFetchData() async {
  //   String token = Constants().token;
  //   try {
  //     filter.FilterVendorModel filterVendorModel =
  //         await getApprovedVendorsByfilter(
  //             token, pageNo, pageCount, _searchQuery);
  //     // Use filterVendorModel as needed
  //     print('Total Records: ${filterVendorModel.totalRecords}');
  //     print('Vendors: ${filterVendorModel.vendorss}');
  //     if (mounted) {
  //       setState(() {
  //         // Update the state to trigger a rebuild
  //       });
  //     }
  //   } catch (error) {
  //     print('Error: $error');
  //     // Handle error
  //   }
  // }

  // void onSearchIconClicked() async {
  //   filterVendorModel = await getApprovedVendorsByfilter(
  //       Constants().token, filterpageNo, filterpageCount, _searchQuery);
  //   if (mounted) {
  //     setState(() {});
  //   }

  //   filterFetchData(); // Call your data fetch method
  // }

  // void resetPageNo() {
  //   filterpageNo = 1;
  // }

  // void onSearchTextChanged(String value) {
  //   setState(() {
  //     _searchQuery = value.toLowerCase();
  //     // Check if the search query is empty
  //     if (_searchQuery.isEmpty) {
  //       // Clear the filterVendorModel.vendorss list
  //       filterVendorModel.vendorss = [];
  //     }
  //   });
  // }
  void filterStores(String query) {
    setState(() {
      filteredVendorsList = vendorsList
          .where(
            (place) => place.vendorBusinessName
                .toLowerCase()
                .contains(query.toLowerCase())
            // // ||
            // place.townName.toLowerCase().contains(query.toLowerCase())
            ,
          )
          .toList();
      filteredVendorsList
          .sort((a, b) => a.vendorBusinessName.compareTo(b.vendorPlaceName));
    });
  }

  @override
  Widget build(BuildContext context) {
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
            SizedBox(height: 10.h),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 52.h,
                child: TextFormField(
                  focusNode: _searchFocusNode,
                  textInputAction: TextInputAction.search,
                  // autofocus: true,
                  onChanged: (value) {
                    filterStores(value);
                  },
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    hintText: 'Search...',
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
                        _textEditingController.clear();
                        // _searchStore('');
                        filterStores('');
                        _searchFocusNode.unfocus();
                      },
                      icon: Icon(
                        Icons.close,
                        color: Constants().appColor,
                      ),
                    ),
                    // suffixIcon: _tabController.index ==
                    //         1 // Check if 'Store' tab is selected
                    //     ? GestureDetector(
                    //         onTap: () {
                    //           resetPageNo();
                    //           onSearchIconClicked();
                    //           _searchFocusNode.unfocus();
                    //           if (_textEditingController.text.isEmpty) {
                    //             filterVendorModel.vendorss = [];
                    //           }
                    //         },
                    //         child: Icon(
                    //           Icons.search,
                    //           color: Constants().appColor,
                    //         ),
                    //       ) // Show search icon only for 'Store' tab
                    // : null, // No prefix icon for other tabs
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
                child: filteredVendorsList.isEmpty
                    ? Center(
                        child: Text("No Stores Available..."),
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
                        itemCount: filteredVendorsList.length,
                        // itemCount: _searchQuery.isEmpty
                        //     ? vendorsList.length + (isLoadingMore ? 1 : 0)
                        //     : filterVendorModel.vendorss?.length ?? 0,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: WalletStoreDetails(
                                      storeList: filteredVendorsList[index],
                                    ),
                                  ),
                                );
                                filterStores('');
                                _searchFocusNode.unfocus();
                                _textEditingController.clear();
                              },
                              child: Container(
                                margin:
                                    const EdgeInsets.only(left: 2, right: 2),
                                height: 50,
                                width: 122,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: filteredVendorsList[index]
                                              .vendorBusinessPicUrl1 ==
                                          "null"
                                      ? const DecorationImage(
                                          image: AssetImage(
                                              "assets/images/store.jpg"),
                                          fit: BoxFit.fill,
                                        )
                                      : DecorationImage(
                                          image: CachedNetworkImageProvider(
                                              filteredVendorsList[index]
                                                  .vendorBusinessPicUrl1),
                                          fit: BoxFit.fill,
                                        ),
                                ),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
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
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 10),
                                      child: Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Text(
                                          filteredVendorsList[index]
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
                            ),
                          );
                        },
                      )
                // : GridView.builder(
                //     shrinkWrap: true,
                //     controller: _scrollController,
                //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                //       crossAxisCount: 2,
                //       crossAxisSpacing: 3.0,
                //       mainAxisSpacing: 3.0,
                //       childAspectRatio: 3 / 2,
                //     ),
                //     itemCount: _searchQuery.isEmpty
                //         ? vendorsList.length + (isLoadingMore ? 1 : 0)
                //         : filterVendorModel.vendorss?.length ?? 0,
                //     itemBuilder: (context, index) {
                //       List<filter.Vendor> filteredVendors =
                //           filterVendorModel.vendorss ?? [];
                //       if (vendorsList == null ||
                //           vendorsList.length == 0 ||
                //           vendorsList.isEmpty) {
                //         return Center(
                //           child: Text(
                //             "No vendors available",
                //             style: TextStyle(color: Colors.black),
                //           ),
                //         );
                //       } else if (index < vendorsList.length) {
                //         return Padding(
                //           padding: const EdgeInsets.all(2.0),
                //           child: GestureDetector(
                //             onTap: () {
                //               Navigator.push(
                //                 context,
                //                 PageTransition(
                //                   type: PageTransitionType.rightToLeft,
                //                   child: WalletStoreDetails(
                //                     vendor: vendorsList[index],
                //                   ),
                //                 ),
                //               );
                //             },
                //             child: Container(
                //               margin:
                //                   const EdgeInsets.only(left: 2, right: 2),
                //               height: 50,
                //               width: 122,
                //               decoration: BoxDecoration(
                //                 borderRadius: BorderRadius.circular(10),
                //                 image: vendorsList[index]
                //                             .vendorBusinessPicUrl1 ==
                //                         "null"
                //                     ? const DecorationImage(
                //                         image: AssetImage(
                //                             "assets/images/store.jpg"),
                //                         fit: BoxFit.fill,
                //                       )
                //                     : DecorationImage(
                //                         image: NetworkImage(vendorsList[index]
                //                             .vendorBusinessPicUrl1),
                //                         fit: BoxFit.fill,
                //                       ),
                //               ),
                //               child: Stack(
                //                 fit: StackFit.expand,
                //                 children: [
                //                   Positioned.fill(
                //                     child: DecoratedBox(
                //                       decoration: BoxDecoration(
                //                         borderRadius:
                //                             BorderRadius.circular(10),
                //                         image: const DecorationImage(
                //                           image: AssetImage(
                //                               "assets/images/shadow.png"),
                //                           fit: BoxFit.fill,
                //                         ),
                //                       ),
                //                     ),
                //                   ),
                //                   Padding(
                //                     padding:
                //                         const EdgeInsets.only(bottom: 10),
                //                     child: Align(
                //                       alignment: Alignment.bottomCenter,
                //                       child: Text(
                //                         vendorsList[index].vendorBusinessName,
                //                         style: const TextStyle(
                //                           fontSize: 12,
                //                           color: Colors.white,
                //                           fontWeight: FontWeight.bold,
                //                         ),
                //                         textAlign: TextAlign.center,
                //                       ),
                //                     ),
                //                   ),
                //                 ],
                //               ),
                //             ),
                //           ),
                //         );
                //       } else if (isLoadingMore) {
                //         // Render a loading indicator
                //         return Center(child: SizedBox());
                //       } else {
                //         // This case should not be reached normally
                //         return SizedBox.shrink();
                //       }
                //     },
                //   ),
                )

            // Expanded(
            //   child: GridView.builder(
            //     shrinkWrap: true,
            //     controller: _scrollController,
            //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //         crossAxisCount: 2,
            //         crossAxisSpacing: 3.0,
            //         mainAxisSpacing: 3.0,
            //         childAspectRatio: 3 / 2),

            //     itemCount: vendorsList.length + (isLoadingMore ? 1 : 0),
            //     itemBuilder: (context, index) {
            //       print(">>>>>>>${vendorsList[index].vendorBusinessPicUrl1}");
            //       print(">>>>||>>>${vendorsList.length}");

            //       if (vendorsList.isEmpty) {
            //         return Center(
            //           child: Text(
            //             "No Stores available",
            //             style: TextStyle(color: Colors.black),
            //           ),
            //         );
            //       } else if (index < vendorsList.length) {
            //         return Padding(
            //           padding: const EdgeInsets.all(2.0),
            //           child: Container(
            //             child: GestureDetector(
            //                 onTap: () {
            //                   Navigator.push(
            //                     context,
            //                     PageTransition(
            //                       type: PageTransitionType.rightToLeft,
            //                       child: WalletStoreDetails(
            //                           vendor: vendorsList[index]),
            //                     ),
            //                   );
            //                 },
            //                 child: Container(
            //                   margin: const EdgeInsets.only(left: 2, right: 2),
            //                   height: 50,
            //                   width: 122,
            //                   decoration: BoxDecoration(
            //                     borderRadius: BorderRadius.circular(10),
            //                     image: vendorsList[index]
            //                                 .vendorBusinessPicUrl1 ==
            //                             "null"
            //                         ? const DecorationImage(
            //                             image: AssetImage(
            //                                 "assets/images/store.jpg"),
            //                             fit: BoxFit.fill,
            //                           )
            //                         : DecorationImage(
            //                             image: NetworkImage(vendorsList[index]
            //                                 .vendorBusinessPicUrl1),
            //                             fit: BoxFit.fill,
            //                           ),
            //                   ),
            //                   child: Stack(
            //                     fit: StackFit.expand,
            //                     children: [
            //                       // Shadow Image
            //                       Positioned.fill(
            //                         child: DecoratedBox(
            //                           decoration: BoxDecoration(
            //                             borderRadius: BorderRadius.circular(10),
            //                             image: const DecorationImage(
            //                               image: AssetImage(
            //                                   "assets/images/shadow.png"),
            //                               fit: BoxFit.fill,
            //                             ),
            //                           ),
            //                         ),
            //                       ),
            //                       // Text Section
            //                       Padding(
            //                         padding: const EdgeInsets.only(bottom: 10),
            //                         child: Align(
            //                           alignment: Alignment.bottomCenter,
            //                           child: Text(
            //                             vendorsList[index].vendorBusinessName,
            //                             style: const TextStyle(
            //                               fontSize: 12,
            //                               color: Colors.white,
            //                               fontWeight: FontWeight.bold,
            //                             ),
            //                             textAlign: TextAlign.center,
            //                           ),
            //                         ),
            //                       ),
            //                     ],
            //                   ),
            //                 )

            //                 // child: vendorsList[],
            //                 // child: Container(
            //                 //   decoration: BoxDecoration(
            //                 //       borderRadius: BorderRadius.all(Radius.circular(10)),

            //                 //       image:
            //                 //        vendorsList[index].vendorBusinessPicUrl1 !=
            //                 //                   null &&
            //                 //               vendorsList[index]
            //                 //                   .vendorBusinessPicUrl1
            //                 //                   .isNotEmpty
            //                 //           ? DecorationImage(
            //                 //               image: NetworkImage(
            //                 //                 vendorsList[index].vendorBusinessPicUrl1,
            //                 //               ),
            //                 //               fit: BoxFit.cover,
            //                 //             )
            //                 //           :
            //                 //          DecorationImage(
            //                 //               image: AssetImage(
            //                 //                   "assets/images/image 4.png"))),
            //                 //   child: Column(
            //                 //     crossAxisAlignment: CrossAxisAlignment.center,
            //                 //     mainAxisAlignment: MainAxisAlignment.end,
            //                 //     children: [
            //                 //       Padding(
            //                 //         padding: const EdgeInsets.all(8.0),
            //                 //         child: Text(
            //                 //           vendorsList[index].vendorBusinessName,
            //                 //           style: TextStyle(
            //                 //             fontSize: 12.sp,
            //                 //             fontWeight: FontWeight.w700,
            //                 //             color: Colors.white,
            //                 //           ),
            //                 //         ),
            //                 //       ),
            //                 //     ],
            //                 //   ),
            //                 // ),

            //                 // child: Container(
            //                 //   // height: 194.h,
            //                 //   // width: 127.w,
            //                 //   decoration: BoxDecoration(
            //                 //     borderRadius: BorderRadius.all(Radius.circular(10)),
            //                 //     image:
            //                 //      vendorsList[index].vendorBusinessPicUrl1==""
            //                 //         ?
            //                 //         const DecorationImage(
            //                 //             image:
            //                 //                 AssetImage("assets/images/image 4.png"),
            //                 //             fit: BoxFit.fill,
            //                 //           )
            //                 //         :
            //                 //          DecorationImage(
            //                 //             image: NetworkImage(
            //                 //               vendorsList[index].vendorBusinessPicUrl1,
            //                 //             ),
            //                 //             fit: BoxFit.fill,
            //                 //           ),
            //                 //   ),
            //                 //   child: Column(
            //                 //     crossAxisAlignment: CrossAxisAlignment.center,
            //                 //     mainAxisAlignment: MainAxisAlignment.end,
            //                 //     children: [
            //                 //       Padding(
            //                 //         padding: const EdgeInsets.all(8.0),
            //                 //         child: Text(
            //                 //           vendorsList[index].vendorBusinessName,
            //                 //           style: TextStyle(
            //                 //               fontSize: 12.sp,
            //                 //               fontWeight: FontWeight.w700,
            //                 //               color: Colors.white),
            //                 //         ),
            //                 //       ),
            //                 //     ],
            //                 //   ),
            //                 // ),
            //                 ),
            //           ),
            //         );
            //       } else
            //         () {
            //           return Center(
            //             child: Text(
            //               "No Data",
            //               style: TextStyle(color: Colors.black),
            //             ),
            //           );
            //         };
            //       return Text(
            //         "data",
            //         style: TextStyle(color: Colors.black),
            //       );
            //       // return Center(
            //       //   child: Text(
            //       //     "No Data",
            //       //     style: TextStyle(color: Colors.black),
            //       //   ),
            //       // );
            //     },
            //   ),
            // ),
          ],
        ));
  }

  Future<void> fetchData() async {
    try {
      EasyLoading.show(
          dismissOnTap: false,
          status: 'Please Wait...',
          maskType: EasyLoadingMaskType.black);
      WalletStoreModel walletStoreModel = await getApprovedVendors(
        token: Constants().token,
        pageNo: pageNo,
        pageCount: pageCount,
        classificationID: widget.selectedVendorClassificationId,
        context: context,
      );
      if (walletStoreModel != null && walletStoreModel.vendors != null) {
        setState(() {
          vendorsList = walletStoreModel.vendors;
          filteredVendorsList = vendorsList;
        });
        setState(() {});
      }
      // setState(() {
      //   vendorsList = walletStoreModel.vendors;
      // });
      // EasyLoading.dismiss();
      print("vendorsList leng:>>>${vendorsList.length}");
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }

  // Future<void> loadMoreData() async {
  //   setState(() {
  //     isLoadingMore = true;
  //   });

  //   try {
  //     pageNo++;
  //     print("pageno:$pageNo");
  //     // Show loading indicator
  //     EasyLoading.show(
  //       dismissOnTap: true,
  //     );

  //     WalletStoreModel walletStoreModel = await getApprovedVendors(
  //       token: Constants().token,
  //       pageNo: pageNo,
  //       pageCount: pageCount,
  //       classificationID: widget.selectedVendorClassificationId,
  //       context: context,
  //     );

  //     if (walletStoreModel.vendors.isEmpty) {
  //       // No more vendors
  //       // showDialog(
  //       //   barrierDismissible: false,
  //       //   context: context,
  //       //   builder: (context) {
  //       //     return AlertDialog(
  //       //       shape: RoundedRectangleBorder(
  //       //         borderRadius: BorderRadius.circular(20),
  //       //       ),
  //       //       title: Column(
  //       //         children: [
  //       //           Center(child: Text('No more vendors')),
  //       //         ],
  //       //       ),
  //       //       actions: [
  //       //         Center(
  //       //           child: InkWell(
  //       //             onTap: () {
  //       //               Navigator.of(context).pop();
  //       //             },
  //       //             child: Container(
  //       //               height: 51,
  //       //               width: 120,
  //       //               decoration: BoxDecoration(
  //       //                 color: Colors.black,
  //       //                 borderRadius: BorderRadius.circular(8),
  //       //               ),
  //       //               child: Center(
  //       //                 child: Text(
  //       //                   "OK",
  //       //                   style: TextStyle(
  //       //                     color: Colors.white,
  //       //                     fontWeight: FontWeight.w600,
  //       //                     fontSize: 16,
  //       //                   ),
  //       //                 ),
  //       //               ),
  //       //             ),
  //       //           ),
  //       //         ),
  //       //         SizedBox(height: 10),
  //       //       ],
  //       //     );
  //       //   },
  //       // );
  //     } else {
  //       setState(() {
  //         vendorsList.addAll(walletStoreModel.vendors);
  //         print("vendorsList length:>>>${vendorsList.length}");
  //       });
  //       setState(() {});
  //     }
  //   } catch (e) {
  //     print('Error loading more data: $e');
  //   } finally {
  //     setState(() {
  //       isLoadingMore = false;
  //     });
  //     // Dismiss loading indicator
  //     EasyLoading.dismiss();
  //   }
  // }

  // Future<void> loadMoreData() async {

  //     setState(() {
  //       isLoadingMore = true;
  //     });

  //     try {
  //       pageNo++;
  //       print("pageno:$pageNo");
  //       // Show loading indicator
  //       EasyLoading.show();

  //       WalletStoreModel walletStoreModel = await getApprovedVendors(
  //         token: Constants().token,
  //         pageNo: pageNo,
  //         pageCount: pageCount,
  //         classificationID: widget.selectedVendorClassificationId,
  //         context: context,
  //       );

  //       setState(() {
  //         vendorsList.addAll(walletStoreModel.vendors);

  //         print("vendorsList length:>>>${vendorsList.length}");
  //       });

  //       print("vendorsList:>>>${vendorsList.length}");
  //     } catch (e) {
  //       print('Error loading more data: $e');
  //     } finally {
  //       setState(() {
  //         isLoadingMore = false;
  //       });
  //       // Dismiss loading indicator
  //       EasyLoading.dismiss();
  //     }

  // }

  Future<WalletStoreModel> getApprovedVendors({
    required BuildContext context, // Add BuildContext parameter
    required String token,
    required int pageNo,
    required int pageCount,
    required String classificationID,
  }) async {
    final Uri apiUrl = Uri.parse(Urls.storesbyCalssification);

    final Map<String, String> headers = {
      'Token': token,
      'pageno': pageNo.toString(),
      'pagecount': pageCount.toString(),
      'ClassificationID': classificationID,
    };
    print("headers:$headers");

    try {
      final http.Response response = await http.get(apiUrl, headers: headers);

      final Map<String, dynamic> responseData = json.decode(response.body);
      if (responseData['transactionStatus'] == false) {
        // showDialog(
        //   barrierDismissible: false,
        //   context: context,
        //   builder: (context) {
        //     return Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: AlertDialog(
        //         shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(20)),
        //         title: Column(
        //           children: [
        //             Center(child: Text('No Vendors')),
        //             const SizedBox(height: 10),
        //             Center(
        //                 child: Text(
        //               responseData["message"],
        //               style:
        //                   TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        //             ))
        //           ],
        //         ),
        //         actions: [
        //           Center(
        //             child: InkWell(
        //               onTap: () {
        //                 Navigator.of(context).pop();
        //                 // Navigator.of(context).push(MaterialPageRoute(
        //                 //     builder: (context) => BottomNavigationScreen()));
        //               },
        //               child: Container(
        //                 height: 51,
        //                 width: 120,
        //                 decoration: BoxDecoration(
        //                     color: Colors.black,
        //                     borderRadius: BorderRadius.circular(8)),
        //                 child: Center(
        //                   child: Text(
        //                     "OK",
        //                     style: TextStyle(
        //                         color: Colors.white,
        //                         fontWeight: FontWeight.w600,
        //                         fontSize: 16),
        //                   ),
        //                 ),
        //               ),
        //             ),
        //           ),
        //           SizedBox(height: 10)
        //         ],
        //       ),
        //     );
        //   },
        // );
        return WalletStoreModel(
            transactionStatus: false, totalRecords: 0, vendors: []);
      } else if (responseData['transactionStatus'] == true) {
        return WalletStoreModel.fromJson(responseData);
      } else {
        throw Exception('API request failed: ${responseData['message']}');
      }
    } catch (error) {
      throw Exception('Error occurred: $error');
    }
  }

  // void _loadMoreItems() {
  //   if (!isLoadingMore &&
  //       _scrollController.position.pixels ==
  //           _scrollController.position.maxScrollExtent) {
  //     loadMoreData();
  //   }
  // }

  Widget buildVendorItem(dynamic vendor) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            PageTransition(
              type: PageTransitionType.rightToLeft,
              child: WalletStoreDetails(
                storeList: vendor,
              ),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(left: 2, right: 2),
          height: 50,
          width: 122,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: vendor.vendorBusinessPicUrl1 == "null"
                ? const DecorationImage(
                    image: AssetImage("assets/images/store.jpg"),
                    fit: BoxFit.fill,
                  )
                : DecorationImage(
                    image: NetworkImage(vendor.vendorBusinessPicUrl1),
                    fit: BoxFit.fill,
                  ),
          ),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage("assets/images/shadow.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      vendor.vendorBusinessName,
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
        ),
      ),
    );
  }
}
