
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:reward_hub_customer/login/api_service.dart';

import '../Utils/constants.dart';
import '../Utils/toast_widget.dart';

class ForgotPasswordScreen extends StatefulWidget{
  String mobile = "";
  String otp = "";
  ForgotPasswordScreen(this.mobile,this.otp);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return ForgotPasswprdScreenState();
  }

}
class ForgotPasswprdScreenState extends State<ForgotPasswordScreen>{

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     body: SafeArea(
       child:Column(
         mainAxisSize: MainAxisSize.max,
         children: [
           Expanded(
               flex: 0,
               child: Container(
                 height: 50,
                 child: Row(
                   mainAxisSize: MainAxisSize.max,
                   children: [
                     GestureDetector(
                       onTap:(){
                         Navigator.pop(context);
                       },
                       child: Padding(padding: EdgeInsets.only(left: 20),
                         child: Image.asset("assets/images/ic_back_img.png"),),
                     )
                   ],
                 ),
               )),
           Expanded(flex: 1,
             child: Column(
               mainAxisSize: MainAxisSize.max,
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Image.asset("assets/images/ic_logo.png",
                   height: 130,
                   width: 130,),
                 const Padding(
                   padding: EdgeInsets.all(0.0),
                   child: Text("Create a Password",
                     style: TextStyle(color: Colors.black,
                         fontSize: 20,
                         fontWeight: FontWeight.bold),),
                 ),
                 Padding(padding: const EdgeInsets.only(left: 20,right: 20,bottom: 0,top: 10),
                   child: SizedBox(
                     width: double.infinity,
                     height: 50,
                     child: TextField(
                       keyboardType: TextInputType.text,
                       controller: passwordController,
                       enabled: true,
                       obscureText: true,
                       decoration: const InputDecoration(
                           enabledBorder: OutlineInputBorder(
                             borderSide: BorderSide(color: Color(0xFFE5E7E9), width: 0.0),
                           ),
                           border: OutlineInputBorder(
                             borderSide: BorderSide(color: Color(0xFFE5E7E9)),
                             borderRadius: BorderRadius.all(
                               Radius.circular(8.0),
                             ),
                           ),
                           filled: true,
                           contentPadding: EdgeInsets.only(left: 10,bottom: 5),
                           hintStyle:  TextStyle(fontSize: 15),
                           hintText: "Password",
                           fillColor:  Color(0xFFE5E7E9)),
                     ),
                   ),),
                 Padding(padding: const EdgeInsets.only(left: 20,right: 20,bottom: 0,top: 10),
                   child: SizedBox(
                     width: double.infinity,
                     height: 50,
                     child: TextField(
                       keyboardType: TextInputType.text,
                       controller: confirmPasswordController,
                       enabled: true,
                       obscureText: true,
                       decoration: const InputDecoration(
                           enabledBorder: OutlineInputBorder(
                             borderSide: BorderSide(color: Color(0xFFE5E7E9), width: 0.0),
                           ),
                           border: OutlineInputBorder(
                             borderSide: BorderSide(color: Color(0xFFE5E7E9)),
                             borderRadius: BorderRadius.all(
                               Radius.circular(8.0),
                             ),
                           ),
                           filled: true,
                           contentPadding: EdgeInsets.only(left: 10,bottom: 5),
                           hintStyle:  TextStyle(fontSize: 15),
                           hintText: "Confirm Password",
                           fillColor:  Color(0xFFE5E7E9)),
                     ),
                   ),),
                 Padding(padding: const EdgeInsets.only(left: 20,right: 20,top: 20),
                   child: GestureDetector(
                     onTap: () async{
                       if(passwordController.text.isEmpty){
                         ToastWidget().showToastError("Please fill Password");
                       }
                       else if(confirmPasswordController.text.isEmpty){
                         ToastWidget().showToastError("Please confirm Password");
                       }
                       else if(passwordController.text!=confirmPasswordController.text){
                         ToastWidget().showToastError("Password mismatch");
                       }
                       else{
                         ApiService().resetPassword(widget.mobile,
                             context,
                             passwordController.text.toString());
                       }
                     },
                     child: Container(
                       height: 50,
                       decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(15),
                           color: Constants().appColor
                       ),
                       child: const Align(
                         alignment: Alignment.center,
                         child: Text("SAVE PASSWORD",
                           style: TextStyle(color: Colors.white,
                               fontSize: 16,
                               fontWeight: FontWeight.bold),),
                       ),
                     ),
                   ),),
               ],
             ),)
         ],
       )
     ),
   );
  }

}