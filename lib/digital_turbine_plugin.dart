import 'dart:async';

import 'package:flutter/services.dart';

export 'digital_turbine_banner_view.dart';

class DigitalTurbinePlugin {
  static const MethodChannel _channel = MethodChannel('digital_turbine_plugin');

  static Future<void> initialize({
    required String appId,
    LogLevel? logLevel,
    bool? isChild,
    bool autoRequestingEnabled = true,
  }) async {
    await _channel.invokeMethod('initialize', {
      'appId': appId,
      'logLevel': logLevel?.toString().split('.').last,
      'autoRequestingEnabled': autoRequestingEnabled,
      'isChild': isChild,
    });
  }

  static Future<void> initializeRewarded(String placementId) async {
    await _channel.invokeMethod('initializeRewarded', {'placementId': placementId});
  }

  static Future<void> initializeBanner(String placementId) async {
    await _channel.invokeMethod('initializeBanner', {'placementId': placementId});
  }

  static Future<void> disableAutoRequesting(AdType adType, String placementId) async {
    await _channel.invokeMethod('disableAutoRequesting', {
      'adType': adType.toString().split('.').last,
      'placementId': placementId,
    });
  }

  static Future<void> showTestSuite() async {
    await _channel.invokeMethod("testSuite");
  }

  ///
  /// Rewarded Ad Methods
  ///
  static Future<void> requestRewarded(String placementId) async {
    await _channel.invokeMethod('requestRewarded', {'placementId': placementId});
  }

  static Future<void> showRewarded(String placementId) async {
    await _channel.invokeMethod('showRewarded', {'placementId': placementId});
  }

  static Future<bool> isRewardedAvailable(String placementId) async {
    return await _channel.invokeMethod('isRewardedAvailable', {'placementId': placementId});
  }

  static void setRewardedListener(DigitalTurbineRewardedListener listener) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onRewardedAvailable':
          listener.onRewardedAvailable(call.arguments['placementId']);
          break;
        case 'onRewardedUnavailable':
          listener.onRewardedUnavailable(call.arguments['placementId']);
          break;
        case 'onRewardedShow':
          listener.onRewardedShow(call.arguments['placementId'], call.arguments['impressionData']);
          break;
        case 'onRewardedShowFail':
          listener.onRewardedShowFail(call.arguments['placementId'], call.arguments['error'], call.arguments['impressionData']);
          break;
        case 'onRewardedClick':
          listener.onRewardedClick(call.arguments['placementId']);
          break;
        case 'onRewardedComplete':
          listener.onRewardedComplete(call.arguments['placementId'], call.arguments['userRewarded']);
          break;
        case 'onRewardedDismiss':
          listener.onRewardedDismiss(call.arguments['placementId']);
          break;
        case 'onRewardedWillRequest':
          listener.onRewardedWillRequest(call.arguments['placementId'], call.arguments['requestId']);
          break;
      }
    });
  }

  static Future<void> disposeRewardedAd() async {
    await _channel.invokeMethod('disposeRewardAd');
  }

  ///
  /// Banner Ad Methods
  ///
  static Future<void> showAdBanner(String placementId) async {
    await _channel.invokeMethod('showAdBanner', {'placementId': placementId});
  }

  static Future<void> hideAdBanner(String placementId) async {
    await _channel.invokeMethod('hideAdBanner', {'placementId': placementId});
  }

  static Future<void> disposeAdBanner(String placementId) async {
    await _channel.invokeMethod('disposeAdBanner', {'placementId': placementId});
  }
  static Future<void> requestAdBanner(String placementId) async {
    await _channel.invokeMethod('requestAdBanner', {'placementId': placementId});
  }

  static void setAdBannerListener(DigitalTurbineAdBannerListener listener) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onBannerLoad':
          listener.onAdBannerLoaded(call.arguments['placementId'], call.arguments['impressionData']);
          break;
        case 'onBannerError':
          listener.onAdBannerError(call.arguments['placementId'], call.arguments['error']);
          break;
        case 'onBannerShow':
          listener.onAdBannerShow(call.arguments['placementId'], call.arguments['impressionData']);
          break;
        case 'onBannerClick':
          listener.onAdBannerClick(call.arguments['placementId']);
          break;
        case 'onBannerRequestStart':
          listener.onAdBannerRequestStart(call.arguments['placementId'], call.arguments['requestId']);
          break;
      }
    });
  }
}

enum LogLevel {
  verbose,
  info,
  error,
}

enum AdType {
  rewarded,
  banner,
}

abstract class DigitalTurbineRewardedListener {
  void onRewardedAvailable(String placementId);

  void onRewardedUnavailable(String placementId);

  void onRewardedShow(String placementId, String impressionData);

  void onRewardedShowFail(String placementId, String error, String impressionData);

  void onRewardedClick(String placementId);

  void onRewardedComplete(String placementId, bool userRewarded);

  void onRewardedDismiss(String placementId);

  void onRewardedWillRequest(String placementId, String requestId);
}

abstract class DigitalTurbineAdBannerListener {
  void onAdBannerLoaded(String placementId, String impressionData);

  void onAdBannerError(String placementId, String error);

  void onAdBannerShow(String placementId, String impressionData);

  void onAdBannerClick(String placementId);

  void onAdBannerRequestStart(String placementId, String requestId);
}
