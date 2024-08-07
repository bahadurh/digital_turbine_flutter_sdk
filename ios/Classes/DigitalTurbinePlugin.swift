import Flutter
import UIKit
import FairBidSDK

public class DigitalTurbinePlugin: NSObject, FlutterPlugin, FYBInterstitialDelegate, FYBRewardedDelegate, FYBBannerDelegate {
    private var channel: FlutterMethodChannel?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "digital_turbine_plugin", binaryMessenger: registrar.messenger())
        let instance = DigitalTurbinePlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            if let args = call.arguments as? [String: Any],
               let appId = args["appId"] as? String {
                initialize(appId: appId, args: args, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for initialize", details: nil))
            }
        case "disableAutoRequesting":
            if let args = call.arguments as? [String: Any],
               let adType = args["adType"] as? String,
               let placementId = args["placementId"] as? String {
                disableAutoRequesting(adType: adType, placementId: placementId, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for disableAutoRequesting", details: nil))
            }
            //        case "requestInterstitial":
            //            if let args = call.arguments as? [String: Any],
            //               let placementId = args["placementId"] as? String {
            //                requestInterstitial(placementId: placementId, result: result)
            //            } else {
            //                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for requestInterstitial", details: nil))
            //            }
            //        case "showInterstitial":
            //            if let args = call.arguments as? [String: Any],
            //               let placementId = args["placementId"] as? String {
            //                showInterstitial(placementId: placementId, result: result)
            //            } else {
            //                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for showInterstitial", details: nil))
            //            }
            //        case "isInterstitialAvailable":
            //            if let args = call.arguments as? [String: Any],
            //               let placementId = args["placementId"] as? String {
            //                isInterstitialAvailable(placementId: placementId, result: result)
            //            } else {
            //                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for isInterstitialAvailable", details: nil))
            //            }
            //
        case "requestRewarded":
            if let args = call.arguments as? [String: Any],
               let placementId = args["placementId"] as? String {
                requestRewarded(placementId: placementId, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for requestRewarded", details: nil))
            }
        case "showRewarded":
            if let args = call.arguments as? [String: Any],
               let placementId = args["placementId"] as? String {
                showRewarded(placementId: placementId, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for showRewarded", details: nil))
            }
        case "isRewardedAvailable":
            if let args = call.arguments as? [String: Any],
               let placementId = args["placementId"] as? String {
                isRewardedAvailable(placementId: placementId, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for isRewardedAvailable", details: nil))
            }
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initialize(appId: String, args: [String: Any], result: @escaping FlutterResult) {
         if FairBid.isStarted() {
            FYBInterstitial.delegate = self
            FYBRewarded.delegate = self
            result(nil)
        }
        let options = FYBStartOptions()
        
        if let logLevel = args["logLevel"] as? String {
            let _logLevel = logLevelFromString(logLevel)
            options.logLevel = _logLevel
        }
        
        if let thirdPartyLogEnabled = args["thirdPartyLogEnabled"] as? Bool {
            options.thirdPartyLoggingEnabled = thirdPartyLogEnabled
        }
        
        /// By default, DT FairBid SDK starts with auto-request enabled for all placements.
        /// _This means two things:
        /// 1. When a user finishes watching an ad, DT FairBid immediately tries to replace that ad.
        /// 2. When a certain placement has trouble obtaining a fill (no traditional mediated network has available inventory and no programmatic demand is bidding within a predetermined amount of time), DT FairBid continues trying to ensure that placement gets a fill by restarting the entire ad request process. This is performed in exponentially increasing time intervals to optimize the chances of getting a fill while minimizing usage of device resources.
        if let autoRequestingEnabled = args["autoRequestingEnabled"] as? Bool {
            options.autoRequestingEnabled = autoRequestingEnabled
        }
        
        /// The "IsChild" API is designed to help publishers comply with age-related policies such as COPPA, GDPR, and Google Play’s Families Ads Program.
        /// This API enables publishers to flag certain users as children. The term Children refers to individuals under a certain age, as defined under applicable data privacy laws.
        if let isChild = args["isChild"] as? Bool {
            options.isChild = isChild
        }
        
        
        FairBid.start(withAppId: appId, options: options)
        FYBInterstitial.delegate = self
        FYBRewarded.delegate = self
        result(nil)
    }
    
    private func disableAutoRequesting(adType: String, placementId: String, result: @escaping FlutterResult) {
        switch adType.lowercased() {
        case "interstitial":
            FYBInterstitial.disableAutoRequesting(placementId)
        case "rewarded":
            FYBRewarded.disableAutoRequesting(placementId)
        default:
            result(FlutterError(code: "INVALID_AD_TYPE", message: "Invalid ad type for disableAutoRequesting", details: nil))
            return
        }
        result(nil)
    }
    
    private func requestInterstitial(placementId: String, result: @escaping FlutterResult) {
        FYBInterstitial.request(placementId)
        result(nil)
    }
    
    private func showInterstitial(placementId: String, result: @escaping FlutterResult) {
        if FYBInterstitial.isAvailable(placementId) {
            FYBInterstitial.show(placementId)
            result(nil)
        } else {
            result(FlutterError(code: "UNAVAILABLE", message: "Interstitial is not available", details: nil))
        }
    }
    
    private func isInterstitialAvailable(placementId: String, result: @escaping FlutterResult) {
        result(FYBInterstitial.isAvailable(placementId))
    }
    
    private func requestRewarded(placementId: String, result: @escaping FlutterResult) {
        FYBRewarded.request(placementId)
        result(nil)
    }
    
    private func showRewarded(placementId: String, result: @escaping FlutterResult) {
        if FYBRewarded.isAvailable(placementId) {
            FYBRewarded.show(placementId)
            result(nil)
        } else {
            result(FlutterError(code: "UNAVAILABLE", message: "Rewarded ad is not available", details: nil))
        }
    }
    
    private func isRewardedAvailable(placementId: String, result: @escaping FlutterResult) {
        result(FYBRewarded.isAvailable(placementId))
    }
    
    private func logLevelFromString(_ logLevel: String) -> FYBLoggingLevel {
        switch logLevel.lowercased() {
        case "verbose":
            return .verbose
        case "info":
            return .info
        case "error":
            return .error
        default:
            return .info
        }
    }
    
    // MARK: - FYBInterstitialDelegate
    //
    //    public func interstitialIsAvailable(_ placementId: String) {
    //        channel?.invokeMethod("onInterstitialAvailable", arguments: ["placementId": placementId])
    //    }
    //
    //    public func interstitialIsUnavailable(_ placementId: String) {
    //        channel?.invokeMethod("onInterstitialUnavailable", arguments: ["placementId": placementId])
    //    }
    //
    //    public func interstitialDidShow(_ placementId: String, impressionData: FYBImpressionData) {
    //        channel?.invokeMethod("onInterstitialShow", arguments: ["placementId": placementId, "impressionData": impressionData.description])
    //    }
    //
    //    public func interstitialDidFail(toShow placementId: String, withError error: Error, impressionData: FYBImpressionData) {
    //        channel?.invokeMethod("onInterstitialShowFail", arguments: ["placementId": placementId, "error": error.localizedDescription, "impressionData": impressionData.description])
    //    }
    //
    //    public func interstitialDidClick(_ placementId: String) {
    //        channel?.invokeMethod("onInterstitialClick", arguments: ["placementId": placementId])
    //    }
    //
    //    public func interstitialDidDismiss(_ placementId: String) {
    //        channel?.invokeMethod("onInterstitialDismiss", arguments: ["placementId": placementId])
    //    }
    //
    //    public func interstitialWillRequest(_ placementId: String, withRequestId requestId: String) {
    //        channel?.invokeMethod("onInterstitialWillRequest", arguments: ["placementId": placementId, "requestId": requestId])
    //    }
    
    // MARK: - FYBRewardedDelegate
    /// https://developer.digitalturbine.com/hc/en-us/articles/360013525277-iOS-Ad-Formats
    
    public func rewardedIsAvailable(_ placementId: String) {
        channel?.invokeMethod("onRewardedAvailable", arguments: ["placementId": placementId])
    }
    
    public func rewardedIsUnavailable(_ placementId: String) {
        channel?.invokeMethod("onRewardedUnavailable", arguments: ["placementId": placementId])
    }
    
    public func rewardedDidShow(_ placementId: String, impressionData: FYBImpressionData) {
        channel?.invokeMethod("onRewardedShow", arguments: ["placementId": placementId, "impressionData": impressionData.description])
    }
    
    public func rewardedDidFail(toShow placementId: String, withError error: Error, impressionData: FYBImpressionData) {
        channel?.invokeMethod("onRewardedShowFail", arguments: ["placementId": placementId, "error": error.localizedDescription, "impressionData": impressionData.description])
    }
    
    public func rewardedDidClick(_ placementId: String) {
        channel?.invokeMethod("onRewardedClick", arguments: ["placementId": placementId])
    }
    
    public func rewardedDidComplete(_ placementId: String, userRewarded: Bool) {
        channel?.invokeMethod("onRewardedComplete", arguments: ["placementId": placementId, "userRewarded": userRewarded])
    }
    
    public func rewardedDidDismiss(_ placementId: String) {
        channel?.invokeMethod("onRewardedDismiss", arguments: ["placementId": placementId])
    }
    
    public func rewardedWillRequest(_ placementId: String, withRequestId requestId: String) {
        channel?.invokeMethod("onRewardedWillRequest", arguments: ["placementId": placementId, "requestId": requestId])
    }
}
