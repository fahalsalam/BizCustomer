import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchDetailsByVendor extends StatefulWidget {
  final int placeId;
  const SearchDetailsByVendor({super.key, required this.placeId});

  @override
  State<SearchDetailsByVendor> createState() => _SearchDetailsByVendorState();
}

class _SearchDetailsByVendorState extends State<SearchDetailsByVendor> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("PlaceId:>>>${widget.placeId}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
