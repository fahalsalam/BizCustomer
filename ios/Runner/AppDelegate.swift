import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    let controller = window?.rootViewController as! FlutterViewController
    let channel = FlutterMethodChannel(name: "phone_dialer", binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { (call, result) in
        if call.method == "makeCall" {
            if let args = call.arguments as? [String: Any], 
               let phoneNumber = args["phoneNumber"] as? String {
                
                // Check if device is an iPad
                if UIDevice.current.userInterfaceIdiom == .pad {
                    result(FlutterError(code: "UNAVAILABLE", message: "Calling is not supported on iPad", details: nil))
                    return
                }

                // Proceed with calling on supported devices
                if let url = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                    result(nil) // Successfully opened dialer
                } else {
                    result(FlutterError(code: "UNAVAILABLE", message: "Cannot make a call", details: nil))
                }
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid phone number", details: nil))
            }
        } else {
            result(FlutterMethodNotImplemented)
        }
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
