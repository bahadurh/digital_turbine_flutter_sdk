import Flutter
import UIKit
import FairBidSDK  // Ensure the SDK import matches your actual setup

class DigitalTurbinePlugin: NSObject, FlutterPlugin, OfferWallDelegate {
    private var channel: FlutterMethodChannel?

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "digital_turbine_plugin", binaryMessenger: registrar.messenger())
        let instance = DigitalTurbinePlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            guard let args = call.arguments as? [String: Any],
                  let appId = args["appId"] as? String,
                  let userId = args["userId"] as? String,
                  let disableAdvertisingId = args["disableAdvertisingId"] as? Bool else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for initializing SDK", details: nil))
                return
            }
            initialize(appId: appId, userId: userId, disableAdvertisingId: disableAdvertisingId, result: result)
         case "showOfferWall":
             guard let args = call.arguments as? [String: Any],
                   let appId = args["appId"] as? String else {
                 result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for showing Offer Wall", details: nil))
                 return
             }
             showOfferWall(appId: appId, result: result)


        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func initialize(appId: String, userId: String, disableAdvertisingId: Bool, result: @escaping FlutterResult) {
        OfferWall.userId = userId
        FairBid.start(withAppId: appId) // Starting SDK, make sure to handle the delegate setup if needed
        result(nil)
    }

    private func showOfferWall(appId: String, result: @escaping FlutterResult) {
        OfferWall.start(with: appId, delegate: self, settings: nil) { error in
            if let error = error {
                result(FlutterError(code: "ERROR_SHOWING_OFFERWALL", message: "Failed to show offer wall", details: error.localizedDescription))
            } else {
                result(nil)  // Successfully displayed the Offer Wall
            }
        }
    }

    // Offer Wall Delegate methods
    func didShow(_ placementId: String?) {
        channel?.invokeMethod("onShow", arguments: ["placementId": placementId])
    }

    func didFailToShow(_ placementId: String?, error: OfferWallError) {
        channel?.invokeMethod("onShowError", arguments: ["placementId": placementId, "error": error.localizedDescription])
    }

    func didDismiss(_ placementId: String?) {
        channel?.invokeMethod("onClose", arguments: ["placementId": placementId])
    }
}
