import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reward_hub_customer/Utils/smsType.dart';
import 'package:reward_hub_customer/Utils/toast_widget.dart';
import 'package:reward_hub_customer/login/api_service.dart';

class CustomDialogBox extends StatefulWidget {
  final String title, descriptions, text;
  final String img;

  const CustomDialogBox(
      {Key? key,
      required this.title,
      required this.descriptions,
      required this.text,
      required this.img})
      : super(key: key);

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  TextEditingController dialogueMobileNumberControlller =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding:
              EdgeInsets.only(left: 20, top: 20 + 20, right: 20, bottom: 20),
          margin: EdgeInsets.only(top: 45),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(45),
              boxShadow: [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.asset(
                "assets/images/ic_logo.png",
                height: 60,
              ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20, right: 20, bottom: 5, top: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextField(
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10)
                    ],
                    keyboardType: TextInputType.number,
                    controller: dialogueMobileNumberControlller,
                    enabled: true,
                    decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Color(0xFFE5E7E9), width: 0.0),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFE5E7E9)),
                          borderRadius: BorderRadius.all(
                            Radius.circular(8.0),
                          ),
                        ),
                        filled: true,
                        contentPadding: EdgeInsets.only(left: 10, bottom: 5),
                        hintStyle: TextStyle(fontSize: 15),
                        hintText: "Mobile Number",
                        fillColor: Color(0xFFE5E7E9)),
                  ),
                ),
              ),
              SizedBox(
                height: 22,
              ),
              Padding(
                padding:
                    EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 20),
                child: GestureDetector(
                  onTap: () {
                    if (dialogueMobileNumberControlller.text.isEmpty) {
                      ToastWidget().showToastError("Please fill mobile number");
                    } else {
                      int smsType = getSMSType(SMSType.forgotPassword);
                      ApiService().getResetOtp(
                          dialogueMobileNumberControlller.text.toString(),
                          context,
                          "password",
                          smsType.toString());
                    }
                  },
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.black),
                    child: const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Submit",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        /*Positioned(
          left: 20,
          right: 20,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 40,
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(45)),
                child: Image.asset("assets/images/ic_logo.png",width: 80,)
            ),
          ),
        ),*/
      ],
    );
  }
}
