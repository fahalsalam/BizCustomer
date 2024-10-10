import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:reward_hub_customer/Utils/SharedPrefrence.dart';

Future<void>handleBackgroundMessage(RemoteMessage message)async{
  print("Titile:>>>${message.notification?.title}");
  print("Body:>>>${message.notification?.body}");
  print("Payload:>>>${message.data}");
}


class PushNotifications {
  static final _firebaseMessaging = FirebaseMessaging.instance;

  // request notification permission
  static Future<void> init() async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    Future<String> getDeviceToken()async{
      String? token = await _firebaseMessaging.getToken();
      return token!;
    }

    void isTokenRefresh(){
      _firebaseMessaging.onTokenRefresh.listen((event) {
        event.toString();
        print("Refresh Token :>>>${event.toString()}");
      });
    }



    // get device FCM Token
    final token = await _firebaseMessaging.getToken();
    SharedPrefrence().setFcmToken(token.toString());
    print("Device FCM Token: $token");
    print("Device FCM Token from sharedperfereence: ${SharedPrefrence().getFcmToken()}");
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}