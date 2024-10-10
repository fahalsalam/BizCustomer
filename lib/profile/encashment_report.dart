import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:super_banners/super_banners.dart';

class EncashmentReport extends StatefulWidget {
  const EncashmentReport({super.key});

  @override
  State<EncashmentReport> createState() => _EncashmentReportState();
}

class _EncashmentReportState extends State<EncashmentReport> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          "Encashment Requests",
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black,fontSize: 18.sp),
        ),
        centerTitle: true,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        leading: Padding(
            padding: const EdgeInsets.only(
              left: 10,
            ),
            child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Image.asset("assets/images/ic_back_img.png"))),
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: 20,
                itemBuilder: (context, index) {
                  final double requestedAmount = 100.00;
                  String formattedAmount = NumberFormat.currency(symbol: '₹ ')
                      .format(requestedAmount);

                  return Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 8.0.w),
                    child: Stack(
                      children: [
                        Card(
                          elevation: 4,
                          // color: Color.fromARGB(255, 218, 223, 227).withOpacity(0.5),
                          child: ListTile(
                            title: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Requested Date : 01/01/24",style: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500),),
                                Text("Requested Amount : ${formattedAmount}",style: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500),),
                                Text("Approved Amount : $formattedAmount",style: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500),),
                                Text("Approved By : ABC",style: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500),),
                                Text("Approved Date : 01/01/24",style: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500),),
                                Text("Status : Approved",style: TextStyle(fontSize: 15.sp,fontWeight: FontWeight.w500),),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 5,
                          top: 5,
                          child: CornerBanner(
                            bannerPosition: CornerBannerPosition.topRight,
                            bannerColor: Colors.green,
                            child: Text(
                              "Approved",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 10.sp,fontWeight: FontWeight.w500),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }),
          )
        ],
      ),
    );
  }
}
