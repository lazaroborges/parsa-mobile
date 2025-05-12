import Flutter
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    
    // Setup method channel for widget data sharing
    let balanceChannel = FlutterMethodChannel(name: "com.parsa.app/balance",
                                              binaryMessenger: controller.binaryMessenger)
    
    balanceChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
      if call.method == "updateWidgetData" {
        guard let args = call.arguments as? [String: Any],
              let availableBalance = args["availableBalance"] as? Double,
              let income = args["income"] as? Double,
              let expense = args["expense"] as? Double,
              let currency = args["currency"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENTS", 
                             message: "Missing or invalid arguments", 
                             details: nil))
          return
        }
        
        // Save the data to UserDefaults (App Group)
        let sharedDefaults = UserDefaults(suiteName: "group.com.parsa.app")
        sharedDefaults?.set(availableBalance, forKey: "availableBalance")
        sharedDefaults?.set(income, forKey: "income")
        sharedDefaults?.set(expense, forKey: "expense") 
        sharedDefaults?.set(currency, forKey: "currency")
        sharedDefaults?.set(Date(), forKey: "lastUpdated")
        
        // Trigger widget refresh
        if #available(iOS 14.0, *) {
          self.reloadWidgets()
        }
        
        result(true)
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  @available(iOS 14.0, *)
  private func reloadWidgets() {
    #if arch(arm64) || arch(i386) || arch(x86_64)
    if let bundleIdentifier = Bundle.main.bundleIdentifier {
      let widgetKind = "\(bundleIdentifier).ParsaWidget"
      WidgetCenter.shared.reloadTimelines(ofKind: widgetKind)
    }
    #endif
  }
}

