import Flutter
import UIKit
import FairBidSDK

public class DigitalTurbinePlugin: NSObject, FlutterPlugin {
    static var channel: FlutterMethodChannel?
    static var bannerView: FYBBannerAdView?
    private weak var bannerContainerView: UIView?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "digital_turbine_plugin", binaryMessenger: registrar.messenger())
        let instance = DigitalTurbinePlugin()
        DigitalTurbinePlugin.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // Register the banner view
        let factory = BannerViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "digital_turbine_banner_view")
    }
    
    
    // MARK: - Main Handler For Method Channels
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            handleInitialize(call, result: result)
        case "initializeRewarded":
            handleInitializeRewarded(call, result: result)
        case "initializeBanner":
            handleInitializeBanner(call, result: result)
        case "disableAutoRequesting":
            handleDisableAutoRequesting(call, result: result)
        case "requestRewarded":
            handleRequestRewarded(call, result: result)
        case "showRewarded":
            handleShowRewarded(call, result: result)
        case "isRewardedAvailable":
            handleIsRewardedAvailable(call, result: result)
        case "requestAdBanner":
            handleRequestAdBanner(call, result: result)
        case "showAdBanner":
            handleShowAdBanner(call, result: result)
        case "hideAdBanner":
            handleHideAdBanner(call, result: result)
        case "disposeAdBanner":
            handleDestroyAdBanner(call, result: result)
        case "disposeRewardAd" :
            disposeRewarded(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleInitialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let appId = args["appId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for initialize", details: nil))
            return
        }
        initialize(appId: appId, args: args, result: result)
    }
    
    private func handleInitializeRewarded(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let placementId = args["placementId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for initializeRewarded", details: nil))
            return
        }
        initializeRewarded(placementId: placementId, result: result)
    }
    
    private func handleInitializeBanner(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let placementId = args["placementId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for initializeBanner", details: nil))
            return
        }
        initializeBanner(placementId: placementId, result: result)
    }
    
    private func handleDisableAutoRequesting(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let adType = args["adType"] as? String,
              let placementId = args["placementId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for disableAutoRequesting", details: nil))
            return
        }
        disableAutoRequesting(adType: adType, placementId: placementId, result: result)
    }
    
    private func handleRequestRewarded(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let placementId = args["placementId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for requestRewarded", details: nil))
            return
        }
        requestRewarded(placementId: placementId, result: result)
    }
    
    private func handleShowRewarded(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let placementId = args["placementId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for showRewarded", details: nil))
            return
        }
        showRewarded(placementId: placementId, result: result)
    }
    
    private func handleIsRewardedAvailable(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let placementId = args["placementId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for isRewardedAvailable", details: nil))
            return
        }
        isRewardedAvailable(placementId: placementId, result: result)
    }
    
    private func handleRequestAdBanner(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let placementId = args["placementId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for showAdBanner", details: nil))
            return
        }
        requestAdBanner(placementId: placementId, result: result)
    }
    
    private func handleShowAdBanner(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let placementId = args["placementId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for showAdBanner", details: nil))
            return
        }
        showAdBanner(placementId: placementId, result: result)
    }
    
    private func handleHideAdBanner(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let placementId = args["placementId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for hideAdBanner", details: nil))
            return
        }
        hideAdBanner(placementId: placementId, result: result)
    }
    
    private func handleDestroyAdBanner(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let placementId = args["placementId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments for destroyAdBanner", details: nil))
            return
        }
        destroyAdBanner(placementId: placementId, result: result)
    }
    
    private func initialize(appId: String, args: [String: Any], result: @escaping FlutterResult) {
        if FairBid.isStarted() {
            result(nil)
            return
        }
        
        let options = FYBStartOptions()
        
        if let logLevel = args["logLevel"] as? String {
            options.logLevel = logLevelFromString(logLevel)
        }
        
        if let thirdPartyLogEnabled = args["thirdPartyLogEnabled"] as? Bool {
            options.thirdPartyLoggingEnabled = thirdPartyLogEnabled
        }
        
        if let autoRequestingEnabled = args["autoRequestingEnabled"] as? Bool {
            options.autoRequestingEnabled = autoRequestingEnabled
        }
        
        if let isChild = args["isChild"] as? Bool {
            options.isChild = isChild
        }
        
        FairBid.start(withAppId: appId, options: options)
        result(nil)
    }
    
    private func initializeRewarded(placementId: String, result: @escaping FlutterResult) {
        FYBRewarded.delegate = self
        FYBRewarded.request(placementId)
        result(nil)
    }
    
    private func initializeBanner(placementId: String, result: @escaping FlutterResult) {
        FYBBanner.delegate = self
        let options = FYBBannerOptions(placementId: placementId, size: .MREC)
        FYBBanner.request(with: options)
        result(nil)
    }
    
    private func disableAutoRequesting(adType: String, placementId: String, result: @escaping FlutterResult) {
        switch adType.lowercased() {
        case "rewarded":
            FYBRewarded.disableAutoRequesting(placementId)
        default:
            result(FlutterError(code: "INVALID_AD_TYPE", message: "Invalid ad type for disableAutoRequesting", details: nil))
            return
        }
        result(nil)
    }
    
    private func logLevelFromString(_ logLevel: String) -> FYBLoggingLevel {
        switch logLevel.lowercased() {
        case "verbose": return .verbose
        case "info": return .info
        case "error": return .error
        default: return .info
        }
    }
}


// MARK: - Rewarded Ad Extension

extension DigitalTurbinePlugin {
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
    private func disposeRewarded(result: @escaping FlutterResult) {
        FYBRewarded.delegate = nil
        
        result("DISPOSED_REWARDED")
    }
}



// MARK: - Banner Ad Extension


extension DigitalTurbinePlugin {
    private func requestAdBanner(placementId: String, result: @escaping FlutterResult) {
        FYBBanner.delegate = self
        
        let options = FYBBannerOptions(placementId: placementId, size: .MREC)
        FYBBanner.request(with: options)
        
        result("AD_REQUESTED")
    }
    
    private func showAdBanner(placementId: String, result: @escaping FlutterResult) {
        let options = FYBBannerOptions(placementId: placementId, size: .MREC)
        
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            FYBBanner.show(in: rootViewController.view, options: options)
            result("\(placementId) : Showing Ad Banner")
        } else {
            result(FlutterError(code: "NO_ROOT_VIEW_CONTROLLER", message: "Unable to find root view controller", details: nil))
        }
    }
    
    private func hideAdBanner(placementId: String, result: @escaping FlutterResult) {
        FYBBanner.hide(placementId)
        result("\(placementId) : Ad Banner has been hidden")
    }
    
    private func destroyAdBanner(placementId: String, result: @escaping FlutterResult) {
        FYBBanner.destroy(placementId)
        FYBBanner.delegate = nil
        result("\(placementId) : Ad Banner has been destroyed")
    }
}



// MARK: - FYBRewardedDelegate


extension DigitalTurbinePlugin: FYBRewardedDelegate {
    public func rewardedIsAvailable(_ placementId: String) {
        DigitalTurbinePlugin.channel?.invokeMethod("onRewardedAvailable", arguments: ["placementId": placementId])
    }
    
    public func rewardedIsUnavailable(_ placementId: String) {
        DigitalTurbinePlugin.channel?.invokeMethod("onRewardedUnavailable", arguments: ["placementId": placementId])
    }
    
    public func rewardedDidShow(_ placementId: String, impressionData: FYBImpressionData) {
        DigitalTurbinePlugin.channel?.invokeMethod("onRewardedShow", arguments: ["placementId": placementId, "impressionData": impressionData.description])
    }
    
    public func rewardedDidFail(toShow placementId: String, withError error: Error, impressionData: FYBImpressionData) {
        DigitalTurbinePlugin.channel?.invokeMethod("onRewardedShowFail", arguments: ["placementId": placementId, "error": error.localizedDescription, "impressionData": impressionData.description])
    }
    
    public func rewardedDidClick(_ placementId: String) {
        DigitalTurbinePlugin.channel?.invokeMethod("onRewardedClick", arguments: ["placementId": placementId])
    }
    
    public func rewardedDidComplete(_ placementId: String, userRewarded: Bool) {
        DigitalTurbinePlugin.channel?.invokeMethod("onRewardedComplete", arguments: ["placementId": placementId, "userRewarded": userRewarded])
    }
    
    public func rewardedDidDismiss(_ placementId: String) {
        DigitalTurbinePlugin.channel?.invokeMethod("onRewardedDismiss", arguments: ["placementId": placementId])
    }
    
    public func rewardedWillRequest(_ placementId: String, withRequestId requestId: String) {
        DigitalTurbinePlugin.channel?.invokeMethod("onRewardedWillRequest", arguments: ["placementId": placementId, "requestId": requestId])
    }
}



// MARK: - FYBBannerDelegate


extension DigitalTurbinePlugin: FYBBannerDelegate {
    public func bannerDidLoad(_ banner: FYBBannerAdView, impressionData: FYBImpressionData) {
        let args: [String: Any] = [
            "placementId": banner.options.placementId,
            "impressionData": impressionData.jsonString ?? "unknown"
        ]
        DigitalTurbinePlugin.bannerView = banner
        DigitalTurbinePlugin.channel?.invokeMethod("onBannerLoad", arguments: args)
    }
    
    public func bannerDidFail(toLoad placementId: String, withError error: Error) {
        let args: [String: Any] = [
            "placementId": placementId,
            "error": error.localizedDescription
        ]
        DigitalTurbinePlugin.channel?.invokeMethod("onBannerError", arguments: args)
    }
    
    public func bannerDidShow(_ banner: FYBBannerAdView, impressionData: FYBImpressionData) {
        let args: [String: Any] = [
            "placementId": banner.options.placementId,
            "impressionData": impressionData.jsonString ?? "unknown"
        ]
        DigitalTurbinePlugin.channel?.invokeMethod("onBannerShow", arguments: args)
    }
    
    public func bannerDidClick(_ banner: FYBBannerAdView) {
        let args: [String: Any] = ["placementId": banner.options.placementId]
        DigitalTurbinePlugin.channel?.invokeMethod("onBannerClick", arguments: args)
    }
    
    public func bannerWillRequest(_ placementId: String, withRequestId requestId: String) {
        let args: [String: Any] = [
            "placementId": placementId,
            "requestId": requestId
        ]
        DigitalTurbinePlugin.channel?.invokeMethod("onBannerRequestStart", arguments: args)
    }
}


// MARK: -  Banner View
class BannerView: NSObject, FlutterPlatformView, FYBBannerDelegate {
    private let containerView: UIView
    private let placementId: String
    private let channel: FlutterMethodChannel
    private var bannerView: FYBBannerAdView?
    
    init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        self.containerView = UIView(frame: frame)
        self.placementId = (args as? [String: Any])?["placementId"] as? String ?? ""
        self.channel = FlutterMethodChannel(name: "digital_turbine_banner_view_1", binaryMessenger: messenger)
        
        super.init()
        
        self.channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "loadAd":
                self?.loadAd()
                result(nil)
            case "disposeAd":
                self?.disposeAd()
                result(nil)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
        
        FYBBanner.delegate = self
    }
    
    func view() -> UIView {
        return containerView
    }
    
    private func loadAd() {
        let options = FYBBannerOptions(placementId: placementId, size: .MREC)
         if ((bannerView ?? DigitalTurbinePlugin.bannerView ) != nil ){
            containerView.addSubview((bannerView ?? DigitalTurbinePlugin.bannerView)!)
        } else {
            print("Banner VIEW is EMPTY")
        }
    }
    
    private func disposeAd() {
        bannerView?.removeFromSuperview()
        bannerView = nil
        FYBBanner.destroy(placementId)
        FYBBanner.delegate = nil
    }
    
    // MARK: - FYBBannerDelegate methods
    
    func bannerDidLoad(_ banner: FYBBannerAdView, impressionData: FYBImpressionData) {
        bannerView = banner
        let args: [String: Any] = [
            "placementId": banner.options.placementId,
            "impressionData": impressionData.jsonString ?? ""
        ]
        DigitalTurbinePlugin.channel?.invokeMethod("onBannerLoad", arguments: args)
    }
    
    func bannerDidFail(toLoad placementId: String, withError error: Error) {
        let args: [String: Any] = [
            "placementId": placementId,
            "error": error.localizedDescription
        ]
        DigitalTurbinePlugin.channel?.invokeMethod("onBannerError", arguments: args)
    }
    
    func bannerDidShow(_ banner: FYBBannerAdView, impressionData: FYBImpressionData) {
        let args: [String: Any] = [
            "placementId": banner.options.placementId,
            "impressionData": impressionData.jsonString ?? ""
        ]
        DigitalTurbinePlugin.channel?.invokeMethod("onBannerShow", arguments: args)
    }
    
    func bannerDidClick(_ banner: FYBBannerAdView) {
        let args: [String: Any] = ["placementId": banner.options.placementId]
        DigitalTurbinePlugin.channel?.invokeMethod("onBannerClick", arguments: args)
    }
    
    deinit {
        disposeAd()
    }
}

// MARK: - Banner View Factory

class BannerViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    
    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return BannerView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger
        )
    }
    
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}
