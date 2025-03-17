import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:page_transition/page_transition.dart';
import 'package:reward_hub_customer/Utils/constants.dart';
import 'package:reward_hub_customer/search/AdvancedSearchFilterScreen.dart';
import 'package:reward_hub_customer/store/StoreDetailScreen.dart';
import 'package:reward_hub_customer/store/model/categories_m.dart';
import 'package:reward_hub_customer/wallet/store_categories.dart';

// import 'package:reward_hub_customer/store/model/store_model.dart';
// import 'package:reward_hub_customer/store/model/vendor_model.dart';
import '../Utils/toast_widget.dart';
import '../Utils/urls.dart';
import 'model/category_model.dart';
import 'model/filter_model.dart' as filter;
import 'model/store_model.dart';
import 'model/vendor_model.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return StoreScreenState();
  }
}

class StoreScreenState extends State<StoreScreen>
    with SingleTickerProviderStateMixin {
  var isSelectCategories = true;
  var isSelectStrores = false;
  List<CategoryModel> categoriesList = [];
  List<StoreModel> storesList = [];
  List<StoreModel> filteredStoresList = [];
  List<StoreModel> masterStoreList = [];
  List<Vendor> vendors = [];
  dynamic? selectedDistrictId;
  dynamic? selectedTownId;
  dynamic? selectedPlaceId;
  dynamic? selectedDistrictName;
  dynamic? selectedTownName;
  dynamic? selectedPlaceName;

  var pageNo = 1;
  var pageCount = 20;
  var filterpageNo = 1;
  var filterpageCount = 20;

  String _searchQuery = '';

  late final TabController _tabController;
  final TextEditingController _textEditingController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  late final FocusNode _searchFocusNode;
  late Future<List<CategoriesM>> categoriesFuture;
  late filter.FilterVendorModel filterVendorModel = filter.FilterVendorModel();

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    // fetchData();
    categoriesFuture = fetchDataCategories();
    getStoreList(context);
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_scrollListener);
    _scrollController.addListener(_scrollListenerForFilterStore);
    _tabController.addListener(() {
      onTabChanged();
    });
  }

  Future<List<CategoriesM>> fetchDataCategories() async {
    try {
      List<CategoriesM> categoriesList1 = await getVendorClassifications();
      return categoriesList1;
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  void onTabChanged() {
    _searchFocusNode.unfocus();
    _textEditingController.clear();
    onSearchTextChanged("");

    if (_tabController.index == 0) {
      filterVendorModel.data = [];
      filterpageNo = 1;
      if (mounted) {
        setState(() {});
      }
    } else if (_tabController.index == 1) {
      loadAllStores();
    }
  }

  void resetPageNo() {
    filterpageNo = 1;
  }

  void _scrollListenerForFilterStore() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _loadfilterMoreItems();
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      setState(() {
        _loadMoreItems();
      });
    }
  }

  void _loadMoreItems() {
    pageNo++;

    getStoreList(context, pageNo: pageNo, pageCount: pageCount)
        .then((response) {});
  }

  Future<filter.FilterVendorModel> getApprovedVendorsByfilter(
    String token,
    int pageNo,
    int pageCount,
    String filterText,
  ) async {
    final String apiUrl = Urls.stores;

    final Map<String, String> headers = {
      'Token': token,
      "pageNo": pageNo.toString(),
      "pageSize": pageCount.toString(),
      // 'fltrText': filterText,
    };
    late http.Response response;
    try {
      EasyLoading.show(status: 'Please wait...', dismissOnTap: true);
      response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return filter.FilterVendorModel.fromJson(jsonResponse);
      } else {
        throw Exception('API call failed with status code ${response.body}');
      }
    } catch (error, stackTrace) {
      print('Error: $error');
      print('Stack trace: $stackTrace');
      print('Response body: ${response.body}');
      throw Exception('Error: $error');
    } finally {
      EasyLoading.dismiss();
    }
  }

  void fetchData() async {
    String token = Constants().token;
    try {
      filter.FilterVendorModel filterVendorModel =
          await getApprovedVendorsByfilter(
              token, pageNo, pageCount, _searchQuery);
      if (mounted) {
        setState(() {});
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void onSearchIconClicked() async {
    if (_tabController.index == 1) {
      filterVendorModel = await getApprovedVendorsByfilter(
          Constants().token, filterpageNo, filterpageCount, _searchQuery);
      if (mounted) {
        setState(() {});
      }
    }
    fetchData();
  }

  void _loadfilterMoreItems() {
    filterpageNo++;

    getApprovedVendorsByfilter(
      Constants().token,
      filterpageNo,
      filterpageCount,
      _searchQuery,
    ).then((filterVendorResponse) {
      if (mounted) {
        setState(() {
          filterVendorModel.data?.addAll(filterVendorResponse.data ?? []);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "CATEGORIES & STORE",
          style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(96.h),
          child: Column(
            children: [
              TabBar(
                indicatorColor: Constants().appColor,
                unselectedLabelColor: Colors.grey,
                labelColor: Colors.black,
                controller: _tabController,
                tabs: [
                  Tab(text: 'Categories'),
                  Tab(text: 'Store'),
                ],
              ),
              Container(
                height: 60.h,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50.h,
                          child: TextFormField(
                            onFieldSubmitted: (value) {
                              resetPageNo();
                              onSearchIconClicked();
                              _searchFocusNode.unfocus();
                              if (_textEditingController.text.isEmpty) {
                                filterVendorModel.data = [];
                              }
                            },
                            focusNode: _searchFocusNode,
                            textInputAction: TextInputAction.search,
                            onChanged: onSearchTextChanged,
                            controller: _textEditingController,
                            decoration: InputDecoration(
                              hintText: 'Search...',
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Constants().appColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Constants().appColor),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              suffixIcon: _tabController.index == 1
                                  ? GestureDetector(
                                      onTap: () {
                                        resetPageNo();
                                        onSearchIconClicked();
                                        _searchFocusNode.unfocus();
                                        if (_textEditingController
                                            .text.isEmpty) {
                                          filterVendorModel.data = [];
                                        }
                                      },
                                      child: Icon(
                                        Icons.search,
                                        color: Constants().appColor,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      // const SizedBox(width: 0),
                      // _tabController.index == 1
                      //     ? InkWell(
                      //         onTap: _navigateToAdvancedSearch,
                      //         // onTap: () {
                      //         //   showModalBottomSheet(
                      //         //       isScrollControlled: true,
                      //         //       context: context,
                      //         //       MaterialPageRoute(
                      //         //           builder: (context) =>
                      //         //               AdvancedSearchFilterScreen())
                      //         //       // builder: (BuildContext context) {
                      //         //       //   return AdvancedSearchFilterScreen();
                      //         //       //   // return BottomSheetContent(
                      //         //       //   //     storesList: storesList);
                      //         //       // },
                      //         //       );
                      //         // },
                      //         child: Container(
                      //           height: 52.h,
                      //           width: 52.w,
                      //           decoration: BoxDecoration(
                      //               border:
                      //                   Border.all(color: Constants().appColor),
                      //               borderRadius: BorderRadius.circular(8)),
                      //           child: Icon(
                      //             Icons.filter_alt_outlined,
                      //             size: 35.sp,
                      //           ),
                      //         ),
                      //       )
                      //     : const SizedBox()
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        physics: NeverScrollableScrollPhysics(),
        controller: _tabController,
        children: <Widget>[
          categoryList(),
          storeList(),
        ],
      ),
    );
  }

  //Fahal

  void _navigateToAdvancedSearch() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdvancedSearchFilterScreen(
          selectedDistrictId: selectedDistrictId,
          selectedTownId: selectedTownId,
          selectedPlaceId: selectedPlaceId,
          selectedDistrictName: selectedDistrictName,
          selectedTownName: selectedTownName,
          selectedPlaceName: selectedPlaceName,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      // Ensure data is correctly structured
      if (result['data'] != null && result['data'] is Map<String, dynamic>) {
        // Assuming the stores list is within the 'data' map
        Map<String, dynamic> data = result['data'];

        // Access and parse the stores list from the 'data' map
        if (data.containsKey('data') && data['data'] is List) {
          List<StoreModel> stores = parseStores(data['data']);

          if (mounted) {
            setState(() {
              // Clear the existing stores and repopulate them
              storesList.clear();
              filteredStoresList.clear();
              masterStoreList.clear();

              storesList.addAll(stores);
              filteredStoresList = storesList;
              masterStoreList = storesList;

              // Update the selected filters
              selectedDistrictId = result['selectedDistrictId'];
              selectedTownId = result['selectedTownId'];
              selectedPlaceId = result['selectedPlaceId'];
              selectedDistrictName = result['selectedDistrictName'];
              selectedTownName = result['selectedTownName'];
              selectedPlaceName = result['selectedPlaceName'];
            });

            // Debugging information to ensure everything is working as expected
            print("Stores list updated: ${stores.length} stores loaded");
            print("Selected District ID: $selectedDistrictId");
            print("Selected Town ID: $selectedTownId");
            print("Selected Place ID: $selectedPlaceId");
            print("Selected District  Name: $selectedDistrictName");
            print("Selected Town Name: $selectedTownName");
            print("Selected Place Name: $selectedPlaceName");
          }
        } else {
          print("Error: No stores found in the data map");
        }
      } else {
        print("Error: result['data'] is null or not a Map<String, dynamic>");
      }
    } else {
      print("Error: result is null or not a Map<String, dynamic>");
    }
  }

  Widget categoryList() {
    return FutureBuilder<List<CategoriesM>>(
        future: categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child:
                  CircularProgressIndicator(), // Show a loading indicator while waiting
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No data available'),
            );
          } else {
            final filteredCategories = snapshot.data!
                .where((category) => category.vendorClassificationName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()))
                .toList();
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 3 / 2,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: filteredCategories.length,
              itemBuilder: (context, index) {
                CategoriesM category = filteredCategories[index];
                return GestureDetector(
                  onTap: () {
                    String selectedVendorClassificationId =
                        category.vendorClassificationId.toString();
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => StoreCategories(
                              selectedVendorClassificationId:
                                  selectedVendorClassificationId,
                              fromCategories: true,
                            )));
                    // print("index id>>>${categoriesList[index].id}");
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: category.vendorClassificationImageUrl != null
                              ? CachedNetworkImageProvider(
                                  category.vendorClassificationImageUrl)
                              : AssetImage("assets/images/shadow.png")
                                  as ImageProvider<Object>,
                          fit: BoxFit.cover,
                        )),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.black.withOpacity(0.4),
                            ),
                            width: MediaQuery.of(context).size.width * .65,
                            child: Text(
                              category.vendorClassificationName,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          }
        });
  }

  Widget storeList() {
    List<filter.Vendor> filteredVendors = filterVendorModel.data ?? [];
    if (_searchQuery.isNotEmpty && filteredVendors.isEmpty) {
      return Center(
        child: Text('Tap to search'),
      );
    }
    return GridView.builder(
      controller: _scrollController,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _searchQuery.isNotEmpty
          ? filteredVendors.length ?? 0
          : storesList.length,
      itemBuilder: (BuildContext ctx, index) {
        return GestureDetector(
          onTap: () {
            if (mounted) {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.rightToLeft,
                  child: StoreDetailScreen(_searchQuery.isEmpty
                      ? storesList[index]
                      : filteredVendors[index]),
                ),
              );
            }
          },
          child: _searchQuery.isEmpty
              ? Container(
                  margin: const EdgeInsets.only(left: 2, right: 2),
                  height: 50,
                  width: 122,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: storesList[index].imageURL1 == "null"
                        ? const DecorationImage(
                            image: AssetImage("assets/images/store.jpg"),
                            fit: BoxFit.fill,
                          )
                        : DecorationImage(
                            image: CachedNetworkImageProvider(
                                storesList[index].imageURL1),
                            fit: BoxFit.fill,
                          ),
                  ),
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
                  margin: const EdgeInsets.only(left: 2, right: 2),
                  height: 50,
                  width: 122,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: filteredVendors[index].vendorBusinessPicUrl1 ==
                            "null"
                        ? const DecorationImage(
                            image:
                                AssetImage("assets/images/ic_sample_image.png"),
                            fit: BoxFit.fill,
                          )
                        : DecorationImage(
                            image: NetworkImage(
                                filteredVendors[index].vendorBusinessPicUrl1),
                            fit: BoxFit.fill,
                          ),
                  ),
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
                            filteredVendors[index].vendorBusinessName,
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
    );
  }

  Future<http.Response> getStoreList(BuildContext context,
      {bool reset = false, int pageNo = 1, int pageCount = 20}) async {
    try {
      if (reset) {
        storesList.clear();
        filteredStoresList.clear();
        masterStoreList.clear();
      }
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);

      final Map<String, String> headers = {
        'Token': Constants().token,
        'pageNo': pageNo.toString(),
        'pageSize': pageCount.toString(),
      };

      final response = await http.get(Uri.parse(Urls.stores), headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("Response:>>> ${response.body}");

        if (data['isSuccess'] == true) {
          List<StoreModel> stores = parseStores(data['data']);
          if (mounted) {
            setState(() {
              storesList.addAll(stores);
              filteredStoresList = storesList;
              masterStoreList = storesList;
            });
            print("MasterList1:>>|||>>>${masterStoreList.length}");
            print("MasterList2:>>|||>>>${storesList.length}");
            print("MasterList3:>>|||>>>${filteredStoresList.length}");
          }
        } else {
          showErrorToast("No vendors found.");
        }
      } else {
        showErrorToast("No Stores...");
      }
      return response;
    } catch (error) {
      showErrorToast("No stores");
      log("an error occure:>>>> $error");
      return http.Response('Error', 500);
    } finally {
      if (mounted) {
        EasyLoading.dismiss();
      }
    }
  }

  List<StoreModel> parseStores(List<dynamic> vendors) {
    return vendors.map<StoreModel>((obj) {
      return StoreModel(
        obj['VendorId']?.toString() ?? '',
        obj['VendorBusinessName']?.toString() ?? '',
        obj['VendorRegisteredMobileNumber']?.toString() ?? '',
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
        obj['VendorPlaceId']?.toString() ?? '',
        obj['VendorPlaceName']?.toString() ?? '',
        obj['VendorBusinessDescription']?.toString() ?? '',
        obj['VendorRegisteredMobileNumber']?.toString() ?? '',
        obj['LandMark']?.toString() ?? '',
      );
    }).toList();
  }

  void showErrorToast(String message) {
    ToastWidget().showToastError(message);
  }

  void onSearchTextChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
      if (_searchQuery.isEmpty) {
        filterVendorModel.data = [];
      }
    });
  }

  void handleCategoryTap(String vendorClassificationId) {
    int classificationId = int.tryParse(vendorClassificationId) ?? 0;
    if (classificationId > 0) {
      List<StoreModel> filteredStores = masterStoreList
          .where(
              (store) => store.classificationID == classificationId.toString())
          .toList();

      if (filteredStores.isNotEmpty) {
        storesList = filteredStores;
      } else {
        // Handle the case where no stores match the selected category.
      }
    } else {
      storesList = masterStoreList;
    }
    _textEditingController.clear();
    onSearchTextChanged("");
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textEditingController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void loadAllStores() {
    storesList = masterStoreList;
  }

  Future<List<CategoriesM>> getVendorClassifications() async {
    final String token = Constants().token;
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Token': token,
    };

    try {
      final response = await http.get(
        Uri.parse(Urls.categories),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<CategoriesM> categoriesList =
            data.map((e) => CategoriesM.fromJson(e)).toList();
        return categoriesList;
      } else {
        throw Exception('Failed to load vendor classifications');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Widget filterStoreList() {
    return ListView.builder(
      itemCount: filterVendorModel.data?.length ?? 0,
      itemBuilder: (context, index) {
        filter.Vendor vendor = filterVendorModel.data![index];
        return ListTile(
          title: Text(vendor.vendorBusinessName),
        );
      },
    );
  }
}
