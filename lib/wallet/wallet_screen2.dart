import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:reward_hub_customer/Utils/SharedPrefrence.dart';
import 'package:reward_hub_customer/Utils/constants.dart';
import 'package:reward_hub_customer/Utils/toast_widget.dart';
import 'package:reward_hub_customer/Utils/urls.dart';
import 'package:reward_hub_customer/profile/profile_screen.dart';
import 'package:reward_hub_customer/provider/user_data_provider.dart';
import 'package:reward_hub_customer/store/model/category_model.dart';
import 'package:reward_hub_customer/store/model/customer_transaction_model.dart.dart';
import 'package:reward_hub_customer/store/model/store_model.dart';
import 'package:reward_hub_customer/store/model/user_model.dart';
import 'package:reward_hub_customer/wallet/api_serviece.dart';
import 'package:reward_hub_customer/wallet/store_categories.dart';

class WalletScreen2 extends StatefulWidget {
  const WalletScreen2({
    super.key,
  });

  @override
  State<WalletScreen2> createState() => _WalletScreen2State();
}

class _WalletScreen2State extends State<WalletScreen2>
    with TickerProviderStateMixin {
  var recentTransactionList = [];
  List<CategoryModel> categoriesList = [];
  List<StoreModel> storesList = [];
  List<StoreModel> masterStoreList = [];

  bool isImageClicked = false;
  late AnimationController _controller;

  UserModel? userModel;
  String balance = "";
  DateTime? currentBackPressTime;

  List<CustomerTransactionModel> transactions = [];

  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  // bool isFinished = false;
  //  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //     notificationServices.requestNotificationPermission();
    // notificationServices.forgroundMessage();
    // notificationServices.firebaseInit(context);
    // notificationServices.setupInteractMessage(context);
    // notificationServices.isTokenRefresh();

    // notificationServices.getDeviceToken().then((value){
    //   if (kDebugMode) {
    //     print('device token');
    //     print(value);
    //   }
    // });
    getFcmToken();
    _initializeFCMToken();
    getCategoryList(context);
    // fetchUserDetails();
    fetchTransactions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchUserDetails();
    });
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this, // Use the vsync property here
    );

    Provider.of<UserData>(context, listen: false)
        .setUserProfilePhotoData(SharedPrefrence().getUserProfilePhoto());
  }

//   Future<String> getWalletBalance() async {
//   final UserModel? user = await UserApiService().getUserDetails(
//     Constants().token,
//     SharedPrefrence().getUserPhone().toString()
//   );

//   // Assuming user.walletbalance is of type String
//   String walletBalance = user?.walletbalance.toString() ?? "0.0";

//   Provider.of<UserData>(context, listen: false).updateUserModel(user as UserModel);

//   return walletBalance;
// }

  // Future<void> getWalletBalance() async {
  //   final UserModel? user = await UserApiService().getUserDetails(
  //       Constants().token, SharedPrefrence().getUserPhone().toString());
  //        Provider.of<UserData>(context, listen: false).updateUserModel(user as UserModel);
  // }

  Future<String> fcmtoken() async {
    String token = await FirebaseMessaging.instance.getToken().toString();
    return token;
  }

  Future<void> _initializeFCMToken() async {
    try {
      // Replace 'yourCustomerId', 'yourMobileNo', and 'yourToken' with actual values
      String token = await fcmtoken();
      log("FCM TOKEN:>>>$token" as num);
      await updateFCMToken(
        userModel!.customerID.toString(),
        userModel!.mobileNumber.toString(),
        token,
      );
    } catch (e) {
      // Handle any errors during initialization
      print('Error during FCM Token initialization: $e');
    }
  }

  Future<void> updateFCMToken(
      String customerId, String mobileNo, String token) async {
    final apiUrl =
        'https://marchandising.azurewebsites.net/fcm/2654/postFCMTokenUpdate';

    try {
      // Prepare the headers
      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'CustomerID': customerId,
        'MobileNo': mobileNo,
        'Token': token,
      };

      // Prepare the request body if needed
      // Map<String, dynamic> requestBody = {
      //   'key1': 'value1',
      //   'key2': 'value2',
      // };

      // Make the POST request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        // body: jsonEncode(requestBody), // Uncomment this line if you have a request body
      );

      // Check the response status
      if (response.statusCode == 200) {
        // Request was successful, handle the response data if needed
        print('FCM Token updated successfully');
      } else {
        // Request failed, handle the error
        print(
            'Failed to update FCM Token. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Handle any exceptions
      print('Error updating FCM Token: $e');
    }
  }

  Future<void> fetchUserDetails() async {
    try {
      final UserModel? user = await UserApiService().getUserDetails(
          Constants().token, SharedPrefrence().getUserPhone().toString());
      SharedPrefrence().setCustomerId(user!.customerID.toString());

      if (user != null) {
        SharedPrefrence().setCustomerId(user.customerID.toString());
        setState(() {
          balance = user.walletbalance.toString();
          userModel = user;
        });

        // balance = user.walletbalance.toString();
        print("Balace:>>>>>>>>>>>>>>>>>>>>>>>>>>>>:$balance");
        Provider.of<UserData>(context, listen: false).updateUserModel(user);

        // Use the updateUserModel method to update the userModel in UserData provider
      }
      // setState(() {
      //   userModel = user;
      // });
    } catch (e) {
      print("xxxxxxxxxxxxx${e.toString()}");
      // ToastWidget().showToastError("Error fetching User details:$e");
    }
  }

  Future<void> fetchTransactions() async {
    setState(() {
      // isLoading = true;
      // errorOccurred = false;
    });

    try {
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);
      final token = Constants().token;
      final mobileNumber = SharedPrefrence().getCard();

      transactions = await getCustomerTransactions(token, mobileNumber);
    } catch (error) {
      setState(() {
        // errorOccurred = true;
      });
    } finally {
      setState(() {
        EasyLoading.dismiss();
        // isLoading = false;
      });
    }
  }

  Future<List<CustomerTransactionModel>> getCustomerTransactions(
      String token, String mobileNumber) async {
    final url = Uri.parse(Urls.getTransactions); // Update the path accordingly
    final headers = {
      'Token': token,
      'cardNumber': SharedPrefrence().getCard(),
    };

    try {
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        List<CustomerTransactionModel> transactions =
            customerTransactionModelFromJson(response.body);
        print("Transaction List:>>>${response.body}");
        return transactions;
      } else {
        // Handle error, you can throw an exception or return an empty list based on your requirement
        throw Exception('Failed to load vendor transactions');
      }
    } catch (error) {
      // Handle network error
      print("Error getting from transaction api :>>>$error");
      throw Exception('Failed to connect to the server');
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? cardRenewalDate = userModel?.cardRenewalDate != null
        ? DateFormat('MM/yyyy').format(userModel!.cardRenewalDate)
        : null;

    // Eligibility Amount Calculation
    final num? walletBalance = userModel?.walletbalance;
    final num? minRedemptionAmount = userModel?.minRedemptionAmount;
    final num v1 = (walletBalance ?? 0) - (minRedemptionAmount ?? 0);
    num v2 = v1 * 0.2;
    num v3 = (v1 - v2) <= 0 ? 0 : (v1 - v2);
    final formattedAmount = NumberFormat('#,##0.00').format(v3);

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
        backgroundColor: Constants().bgGrayColor,
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 50.h,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 0,
                          child: SizedBox(
                            height: 40.h,
                            width: 40.w,
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "DASHBOARD",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 0,
                          child: Padding(
                            padding: EdgeInsets.only(right: 10.w, top: 10.h),
                            child: GestureDetector(
                              onTap: () {
                                //Navigator.pop(context, true);
                                //Navigator.push(context, SlideRightRoute(page: IntroScreen()));
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ProfileScreen()));
                                // Navigator.push(
                                //     context,
                                //     PageTransition(
                                //         type: PageTransitionType.rightToLeft,
                                //         child: ProfileScreen()));
                              },
                              child: Consumer<UserData>(
                                builder: (context, userData, _) {
                                  String profilePhotoPath =
                                      SharedPrefrence().getUserProfilePhoto();
                                  File profilePhotoFile =
                                      File(profilePhotoPath);
                                  return profilePhotoFile.existsSync()
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                          child: Image.file(
                                            profilePhotoFile,
                                            height: 40.h,
                                            width: 40.w,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Image.asset(
                                          "assets/images/ic_profile.png",
                                          height: 40.h,
                                          width: 40.w,
                                        );
                                },
                                // child: Image.asset(
                                //   "assets/images/ic_profile.png",
                                //   height: 40.h,
                                //   width: 40.w,
                                // ),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 33.h),
                  FlipCard(
                    key: cardKey,
                    direction: FlipDirection.VERTICAL,
                    front: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 220.h,
                            width: 340.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image:
                                    AssetImage("assets/images/card_front.png"),
                                fit: BoxFit.fill,
                              ),
                            ),
                            child: Stack(
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 28.0.w, top: 66.h),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(left: 5.w),
                                        child: Consumer<UserData>(
                                            builder: (context, userData, _) {
                                          return Text(
                                            "${SharedPrefrence().getUsername()}",
                                            style: TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              color: Colors.white,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          );
                                        }),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 5.w),
                                        child: Text(
                                          SharedPrefrence().getCard(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Padding(
                                        padding: EdgeInsets.only(left: 5.w),
                                        child: Text(
                                          "Total Rewards",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Consumer<UserData>(
                                          builder: (context, userData, _) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                              bottom: 18.0.h, left: 6.w),
                                          child: Text(
                                              NumberFormat('#,##0.00').format(
                                                  userData.userModel
                                                      ?.walletbalance),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w700,
                                              )),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  left: 140.w,
                                  // Adjust this value as needed to position "Fahal Salam"
                                  bottom: 24.0.h,
                                  child: Text(
                                    "Eligibility for\nclaim : ${formattedAmount} ",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 8.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 80.w,
                                  bottom: 120.0.h,
                                  child: Column(
                                    children: [
                                      Text(
                                        "Expiry Date",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                      Text(
                                        cardRenewalDate ?? "",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                            bottom: 42.h,
                            right: 40.w,
                            child: GestureDetector(
                                onTap: () {
                                  cardKey.currentState!.toggleCard();
                                },
                                child: Image.asset(
                                  "assets/images/ic_sample_qr.png",
                                  height: 46.h,
                                  width: 46.w,
                                )))
                      ],
                    ),
                    back: Container(
                      height: 200.h,
                      width: 340.w,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/Group.png"),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Center(
                          child: SizedBox(
                            height: 150.h,
                            width: 150.h,
                            child: QrImageView(
                              data: SharedPrefrence().getCard(),
                              version: QrVersions.auto,
                              size: 150.h,
                              gapless: false,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 260.h,
                bottom: 0.h,
                left: 0.w,
                right: 0.w,
                child: Container(
                  // height: 100,
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/images/ic_wallet_bg.png"),
                        fit: BoxFit.fill),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: 70.0.h, right: 20.w, left: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SizedBox(height: 70),
                        Center(
                          child: Text(
                            "Store Categories",
                            style: TextStyle(
                              fontSize: 15.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        // InkWell(
                        //   onTap: () {
                        //     showAlert1();
                        //   },
                        //   child: Center(
                        //     child: Text(
                        //       "Store Categories",
                        //       style: TextStyle(
                        //         fontSize: 15.sp,
                        //         color: Colors.blue,
                        //         fontWeight: FontWeight.w700,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        SizedBox(
                          height: 127.h,
                          child: ListView.builder(
                            shrinkWrap: true,
                            // physics: NeverScrollableScrollPhysics(),
                            itemCount: categoriesList.length,
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (context, index) {
                              print("${categoriesList[index].imageUrl}");
                              return GestureDetector(
                                onTap: () {
                                  String selectedVendorClassificationId =
                                      categoriesList[index].id;
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => StoreCategories(
                                          selectedVendorClassificationId:
                                              selectedVendorClassificationId)));
                                  print(
                                      "index id>>>${categoriesList[index].id}");
                                  //  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UpdateEnquiryScreen(enquiryList[index].id)));
                                },
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        left: 1.w,
                                        right: 1.w,
                                      ),
                                      height: 81.h,
                                      width: 127.w,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade200),
                                        borderRadius: BorderRadius.circular(20),
                                        image: categoriesList[index].imageUrl ==
                                                "null"
                                            ? const DecorationImage(
                                                image: AssetImage(
                                                    "assets/images/shadow.png"),
                                                fit: BoxFit.fill,
                                              )
                                            : DecorationImage(
                                                image:
                                                    CachedNetworkImageProvider(
                                                  categoriesList[index]
                                                      .imageUrl,
                                                ),
                                                fit: BoxFit.fill,
                                              ),
                                      ),
                                      // foregroundDecoration: BoxDecoration(
                                      //     borderRadius: BorderRadius.circular(20),
                                      //     image: DecorationImage(
                                      //         image: CachedNetworkImageProvider(
                                      //             categoriesList[index]
                                      //                 .imageUrl
                                      //                 .toString()),
                                      //         fit: BoxFit.fill)),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Text(
                                            categoriesList[index]
                                                .name
                                                .toString(),
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Text("Recent Transactions",
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                            )),
                        SizedBox(height: 10.h),
                        Expanded(
                          child: Theme(
                            data: Theme.of(context)
                                .copyWith(hintColor: Constants().appColor),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: transactions.length == 0
                                  ? 1
                                  : transactions.length,
                              itemBuilder: (context, index) {
                                if (transactions.length == 0) {
                                  return Center(
                                      child: Text(
                                    'No Transactions yet...',
                                    style: TextStyle(color: Colors.grey),
                                  ));
                                } else {
                                  Color valueColor =
                                      transactions[index].transactionType ==
                                              'Redemption'
                                          ? Colors.red
                                          : Colors.green;
                                  return ListTile(
                                    leading: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircleAvatar(
                                            maxRadius: 5,
                                            backgroundColor: valueColor),
                                      ],
                                    ),
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            transactions[index].transactionType,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              fontWeight: FontWeight.w600,
                                            )),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 4.0),
                                          child: Text(
                                              transactions[index].vendorName,
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.w600,
                                              )),
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                          DateFormat('EEE, d MMM yyyy, h:mma')
                                              .format(
                                                  transactions[index].dateTime),
                                          // "Mon, 30 July 2023, 05:28pm",
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w400,
                                          )),
                                    ),
                                    trailing: Text(
                                        transactions[index]
                                            .value
                                            .toStringAsFixed(2),
                                        style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w600,
                                            color: valueColor)),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  QrImageView buildQrCode() {
    String cardValue = SharedPrefrence().getCard();
    return QrImageView(
      data: cardValue,
      version: QrVersions.auto,
      size: 200.0,
      errorStateBuilder: (cxt, err) {
        return const Center(
          child: Text(
            "Uh oh! Something went wrong...",
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  void getCategoryList(BuildContext context) async {
    try {
      EasyLoading.show(
          dismissOnTap: false, maskType: EasyLoadingMaskType.black);
      final request = http.MultipartRequest("GET", Uri.parse(Urls.categories));

      request.headers.addAll({
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Token': Constants().token
        //'Authorization': 'Bearer ${SharedPrefrence().getUserToken()}'
      });

      var response = await request.send();

      var responsed = await http.Response.fromStream(response);

      // log(("RESPONCE categ>>>" + responsed.body) as num);
      // log(response.statusCode.toString());

      if (response.statusCode == 200) {
        categoriesList.clear();
        List<dynamic> value = json.decode(responsed.body);
        print("ResponseBody: ${responsed.body}");

        EasyLoading.dismiss();
        for (int i = 0; i < value.length; i++) {
          var obj = value[i];

          /// check image url local assets or a remote image
          // String imageUrl = obj['vendorClassificationImageURL'].toString();
          // Widget imageWidget;
          // if(imageUrl.startsWith("http")){}
          categoriesList.add(CategoryModel(
              obj['vendorClassificationId'].toString(),
              obj['vendorClassificationName'].toString(),
              obj['vendorClassificationImageURL'].toString()));
          print(">>>${obj['vendorClassificationId'].toString()}");
        }
        if (mounted) {
          setState(() {});
        }
      } else {
        Map<String, dynamic> value = json.decode(responsed.body);
        EasyLoading.dismiss();
        ToastWidget().showToastError(value['message'].toString());
      }
    } catch (e, stackTrace) {
      print(">><<${e.toString()}");
      print(">/>?${stackTrace.toString()}");
      e.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the AnimationController when not needed
    super.dispose();
  }

  Future<void> sendApprovalStatus(String requestId, bool status) async {
    String apiUrl =
        'https://marchandising.azurewebsites.net/fcm/2654/postFCMapproval';

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'RequestId': requestId,
      'status': status.toString(),
      // Add other headers as needed
    };
    print("FCM HEADERS:>>>$headers");

    // Map<String, dynamic> requestBody = {
    //   'RequestId': requestId,
    //   'status': status,
    //   // Add other body parameters as needed
    // };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        // API call successful, handle the response if needed
        print("API call successful: ${response.body}");
      } else {
        // API call failed
        print("API call failed with status: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
    } catch (error) {
      // Error during the API call
      print("Error during API call: $error");
    }
  }

  Future<void> getFcmToken() async {
    if (kIsWeb) return;
    var fcmToken = await FirebaseMessaging.instance.getToken();
    FirebaseMessaging.instance.getInitialMessage().then((event) {
      if (event != null) {
        print("geetInitialMessage ${event.data}");
      }
    });

    FirebaseMessaging.onMessage.listen((event) {
      print("onMessage ${event.data}");
      showAlert(event, context);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      print("onMessageOpenApp ${event.data}");
      showAlert(event, context);
    });

    FirebaseMessaging.onBackgroundMessage((event) {
      return showAlert(event, context);
    });
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> showAlert(RemoteMessage event, BuildContext context) async {
    String capitalLetterName = event.data["vendorName"] ?? "";
    //  DateTime timestamp = DateTime.parse(event.data['timestamp']);

    // // Check if more than one minute has passed since the timestamp
    // if (DateTime.now().difference(timestamp).inMinutes > 1) {
    //   print("More than one minute has passed. Do not show the notification.");
    //   return;
    // }

    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      backgroundColor: Colors.grey[200],
      builder: (BuildContext context) {
        return Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 15.h,
                  width: double.infinity,
                ),
                Container(
                  height: 60.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/play_store_2.png"),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "${event.notification?.title}",
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 18.sp),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  capitalLetterName.toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      color: Constants().appColor),
                ),
                const SizedBox(height: 10),
                Text(
                  "INR ${event.data['amount']}",
                  style:
                      TextStyle(fontWeight: FontWeight.w500, fontSize: 16.sp),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.green,
                              border: Border.all(color: Colors.green.shade900),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextButton(
                            onPressed: () {
                              sendApprovalStatus(event.data["reqId"], true);
                              Navigator.of(context).pop();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Approve",
                                  style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.done,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                              color: Colors.red,
                              border: Border.all(color: Colors.red.shade900),
                              borderRadius: BorderRadius.circular(10)),
                          child: TextButton(
                            onPressed: () {
                              sendApprovalStatus(event.data["reqId"], false);
                              Navigator.of(context).pop();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Reject",
                                  style: TextStyle(color: Colors.white),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Icon(
                                  Icons.close,
                                  color: Colors.white,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
