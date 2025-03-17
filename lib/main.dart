import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:reward_hub_customer/Utils/constants.dart';
import 'package:reward_hub_customer/provider/user_data_provider.dart';
import 'package:reward_hub_customer/splash/splash_screen.dart';
import 'package:reward_hub_customer/wallet/wallet_screen2.dart';

@pragma('vm:entry-point')
void main() async {
  // Initialize GetStorage
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(430, 932),
      child: ChangeNotifierProvider(
        create: (context) => UserData(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,

          title: 'Bizatom',
          // home: SplashScreen(),
          home: SplashScreen(),
          // home: LoginScreen(),
          //  home:OTPScreen("","","","","","","","","","",""),
          //  home:RegisterScreen(),
          //  home:CreatePasswordScreen("","","","","","","","",""),
          builder: EasyLoading.init(),
          theme: ThemeData(
              // useMaterial3: false,
              colorScheme: ColorScheme.fromSwatch(
                  accentColor: Constants().appColor,
                  backgroundColor: Colors.white),
              inputDecorationTheme: InputDecorationTheme(
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Constants().appColor)),
              )),
        ),
      ),
    );
  }
}
