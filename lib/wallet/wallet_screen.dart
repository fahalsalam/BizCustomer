import 'dart:convert';
import 'dart:developer';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:reward_hub_customer/Utils/SharedPrefrence.dart';
import 'package:reward_hub_customer/Utils/constants.dart';
import 'package:reward_hub_customer/Utils/toast_widget.dart';
import 'package:reward_hub_customer/profile/profile_screen.dart';
import 'package:reward_hub_customer/store/model/user_model.dart';
import 'package:reward_hub_customer/wallet/api_serviece.dart';

import '../Utils/urls.dart';
import '../store/model/category_model.dart';

class WalletScreen extends StatefulWidget {
  final String? isProfileImage;

  const WalletScreen({super.key, this.isProfileImage});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return WalletScreenState();
  }
}

class WalletScreenState extends State<WalletScreen>
    with TickerProviderStateMixin {
  var recentTransactionList = [];
  List<CategoryModel> categoriesList = [];

  bool isImageClicked = false;
  late AnimationController _controller;
  DateTime? currentBackPressTime;

  UserModel? userModel;
  GlobalKey<FlipCardState> cardKey = GlobalKey<FlipCardState>();

  @override
  void initState() {
    super.initState();
    getCategoryList(context);
    fetchUserDetails();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this, // Use the `vsync` property here
    );
  }

  Future<void> fetchUserDetails() async {
    try {
      final UserModel? user = await UserApiService().getUserDetails(
          Constants().token, SharedPrefrence().getUserPhone().toString());
      setState(() {
        userModel = user;
      });
    } catch (e) {
      print("xxxxxxxxxxxxx${e.toString()}");
      // ToastWidget().showToastError("Error fetching User details:$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? cardRenewalDate = userModel?.cardRenewalDate != null
        ? DateFormat('dd/MM/yyyy').format(userModel!.cardRenewalDate)
        : null;
    final num eligibleAmount = 0.00;

    @override
    Future<bool> didPopRoute() async {
      if (currentBackPressTime == null ||
          DateTime.now().difference(currentBackPressTime!) >
              Duration(seconds: 1)) {
        currentBackPressTime = DateTime.now();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Press back again to exit'),
            duration: Duration(seconds: 2),
          ),
        );
        return Future.value(true); // Intercept back button
      }
      return Future.value(false); // Let the back button proceed
    }

    // TODO: implement build
    return WillPopScope(
      onWillPop: () async {
        // Your custom logic here
        return false; // Return false if you want to prevent the back action
      },
      child: Scaffold(
        backgroundColor: Constants().bgGrayColor,
        body: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.max,
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
                            Navigator.push(
                                context,
                                PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    child: ProfileScreen()));
                          },
                          child: Image.asset(
                            "assets/images/ic_profile.png",
                            height: 40.h,
                            width: 40.w,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              FlipCard(
                key: cardKey,
                direction: FlipDirection.VERTICAL,
                front: Column(
                  children: [
                    Expanded(
                        flex: 0,
                        child: Container(
                          height: 220.h,
                          child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              height: 300.h,
                              width: 330.w,
                              margin: EdgeInsets.only(top: 15.h),
                              decoration: const BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          "assets/images/ic_card_bg.png"),
                                      fit: BoxFit.fill)),
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          left: 25.w, right: 15.w, top: 10.h),
                                      child: Image.asset(
                                        "assets/images/ic_logo.png",
                                        height: 30.h,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 25.w, right: 20.w, top: 15.h),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  "HI ${SharedPrefrence().getUsername()}",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16.sp,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  SharedPrefrence().getCard(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  "Expiry Date",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12.sp,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  cardRenewalDate ?? "",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        left: 25.w, right: 30.w, top: 1.h),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  "Total Reward",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  SharedPrefrence()
                                                      .getWalletBalance(),
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14.sp,
                                                      fontWeight:
                                                          FontWeight.normal),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    cardKey.currentState!
                                                        .toggleCard();
                                                  },
                                                  child: Image.asset(
                                                    // isImageClicked?"assets/images/Group.png":
                                                    "assets/images/ic_qr_code.png",
                                                    height: 46.h,
                                                    width: 46.w,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
                // back: Container(),
                back: GestureDetector(
                  onTap: () {
                    cardKey.currentState!.toggleCard();
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: AnimatedContainer(
                      duration: const Duration(microseconds: 500),
                      height: 200.h,
                      width: 330.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: const DecorationImage(
                            image: AssetImage("assets/images/Group.png"),
                            fit: BoxFit.cover),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey
                                .withOpacity(0.5), // color of the shadow
                            spreadRadius: 5, // spread radius
                            blurRadius: 7, // blur radius
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Center(
                        child: SizedBox(
                          height: 150,
                          width: 150,
                          child: QrImageView(
                            data: SharedPrefrence().getCard(),
                            version: QrVersions.auto,
                            size: 150,
                            gapless: false,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Column(
              //   children: [
              //     Align(
              //       alignment: Alignment.topCenter,
              //       child: Container(
              //         height: 430,
              //         decoration: BoxDecoration(
              //           image: DecorationImage(image: AssetImage("assets/images/ic_wallet_bg.png"),fit: BoxFit.fill)
              //         ),

              //       ),
              //     )                ],
              // ),
              Expanded(
                flex: 1,
                child: Container(
                  width: 430,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/ic_wallet_bg.png"),
                          fit: BoxFit.fill)),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Expanded(
                          flex: 0,
                          child: SizedBox(
                            height: 50,
                          )),
                      const Expanded(
                        flex: 0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Text(
                            "Store Categories",
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 0,
                        child: SizedBox(
                          height: 100,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 10, right: 10, left: 10),
                            child: ListView.builder(
                                itemCount: categoriesList.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      //  Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UpdateEnquiryScreen(enquiryList[index].id)));
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          left: 2, right: 2),
                                      height: 50,
                                      width: 122,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image:
                                            categoriesList[index].imageUrl == ""
                                                ? const DecorationImage(
                                                    image: AssetImage(
                                                        "assets/images/ic_sample_image.png"),
                                                    fit: BoxFit.cover,
                                                  )
                                                : DecorationImage(
                                                    image: NetworkImage(
                                                      categoriesList[index]
                                                          .imageUrl,
                                                    ),
                                                    fit: BoxFit.cover,
                                                  ),
                                      ),
                                      foregroundDecoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  categoriesList[index]
                                                      .imageUrl
                                                      .toString()),
                                              fit: BoxFit.cover)),
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Text(
                                            categoriesList[index]
                                                .name
                                                .toString(),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ),
                      const Expanded(
                        flex: 0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 10, left: 15),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Recent Transactions",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10, right: 10, left: 10),
                          child: recentTransactionList.isEmpty
                              ? const Align(
                                  alignment: Alignment.center,
                                  child: Text("No Transactions found..."),
                                )
                              : ListView.builder(
                                  itemCount: 10,
                                  scrollDirection: Axis.vertical,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        //Navigator.push(context, PageTransition(type: PageTransitionType.rightToLeft, child: UpdateEnquiryScreen(enquiryList[index].id)));
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 10,
                                            bottom: 10),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              flex: 0,
                                              child: Image.asset(
                                                  "assets/images/ic_ellipse_green.png"),
                                            ),
                                            const Expanded(
                                              flex: 1,
                                              child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 10, right: 10),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(
                                                        "Store Name, Category, Place Name",
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 5),
                                                        child: Text(
                                                          "Mon, 30 July 2023, 05:28pm",
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .normal),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 0,
                                              child: Text(
                                                "+134",
                                                style: TextStyle(
                                                    color: Constants().green,
                                                    fontSize: 13),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
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
      EasyLoading.show();
      final request = http.MultipartRequest("GET", Uri.parse(Urls.categories));

      request.headers.addAll({
        'Content-type': 'application/json',
        'Accept': 'application/json',
        'Token': Constants().token
        //'Authorization': 'Bearer ${SharedPrefrence().getUserToken()}'
      });

      var response = await request.send();

      var responsed = await http.Response.fromStream(response);

      log("RESPONCE categ>>>" + responsed.body.toString());
      log(response.statusCode.toString());

      if (response.statusCode == 200) {
        categoriesList.clear();
        List<dynamic> value = json.decode(responsed.body);

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
        }
        if (mounted) {
          setState(() {});
        }
      } else {
        Map<String, dynamic> value = json.decode(responsed.body);
        EasyLoading.dismiss();
        ToastWidget().showToastError(value['message']);
      }
    } catch (e, stackTrace) {
      print(e.toString());
      print(stackTrace.toString());
      e.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose of the AnimationController when not needed
    super.dispose();
  }
}
