import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

class DigitalTurbinePlugin {
  static const MethodChannel _channel = MethodChannel('digital_turbine_plugin');

  static Future<void> initialize({
    required String appId,
    String? userId,
    LogLevel? logLevel,
    bool? isChild,

    /// Already enabled by default in the SDK
    bool autoRequestingEnabled = true,
  }) async {
    await _channel.invokeMethod('initialize', {
      'appId': appId,
      'logLevel': logLevel?.toString().split('.').last,
      'autoRequestingEnabled': autoRequestingEnabled,
      'isChild': isChild,
    });
  }

  static Future<void> dispose() async {
    await _channel.invokeMethod('dispose');
    _channel.setMethodCallHandler(null);

  }

  static Future<void> disableAutoRequesting(AdType adType, String placementId) async {
    if (Platform.isIOS) {
      await _channel.invokeMethod('disableAutoRequesting', {
        'adType': adType.toString().split('.').last,
        'placementId': placementId,
      });
    }
  }


  /// Rewarded
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


/// Interstitial
/*
  static Future<void> requestInterstitial(String placementId) async {
    await _channel.invokeMethod('requestInterstitial', {'placementId': placementId});
  }

  static Future<void> showInterstitial(String placementId) async {
    await _channel.invokeMethod('showInterstitial', {'placementId': placementId});
  }

  static Future<bool> isInterstitialAvailable(String placementId) async {
    return await _channel.invokeMethod('isInterstitialAvailable', {'placementId': placementId});
  }

  static void setInterstitialListener(DigitalTurbineInterstitialListener listener) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onInterstitialAvailable':
          listener.onInterstitialAvailable(call.arguments['placementId']);
          break;
        case 'onInterstitialUnavailable':
          listener.onInterstitialUnavailable(call.arguments['placementId']);
          break;
        case 'onInterstitialShow':
          listener.onInterstitialShow(call.arguments['placementId'], call.arguments['impressionData']);
          break;
        case 'onInterstitialShowFail':
          listener.onInterstitialShowFail(call.arguments['placementId'], call.arguments['error'], call.arguments['impressionData']);
          break;
        case 'onInterstitialClick':
          listener.onInterstitialClick(call.arguments['placementId']);
          break;
        case 'onInterstitialDismiss':
          listener.onInterstitialDismiss(call.arguments['placementId']);
          break;
        case 'onInterstitialWillRequest':
          listener.onInterstitialWillRequest(call.arguments['placementId'], call.arguments['requestId']);
          break;
      }
    });
  }*/
}

enum LogLevel {
  verbose,
  debug,
  info,
  warning,
  error,
}

enum AdType {
  // interstitial,
  rewarded,
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

/*abstract class DigitalTurbineInterstitialListener {
  void onInterstitialAvailable(String placementId);

  void onInterstitialUnavailable(String placementId);

  void onInterstitialShow(String placementId, String impressionData);

  void onInterstitialShowFail(String placementId, String error, String impressionData);

  void onInterstitialClick(String placementId);

  void onInterstitialDismiss(String placementId);

  void onInterstitialWillRequest(String placementId, String requestId);
}*/

// library digital_turbine_plugin;
//
// import 'dart:io';
//
// import 'package:flutter/services.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';
//
// part 'digital_turbine_plugin_method_channel.dart';
// part 'digital_turbine_plugin_platform_interface.dart';
// part 'log_level.dart';
//
// class DigitalTurbinePlugin extends DigitalTurbinePlatform {
//   static DigitalTurbinePlatform _instance = MethodChannelDigitalTurbine();
//
//   static DigitalTurbinePlatform get instance => _instance;
//
//   static set instance(DigitalTurbinePlatform instance) {
//     _instance = instance;
//   }
//
//   @override
//   Future<void> initialize({
//     required String appId,
//     String? userId,
//     LogLevel? logLevel,
//     bool? autoRequestingEnabled,
//     bool? isChild,
//   }) async {
//     await instance.initialize(
//       appId: appId,
//       userId: userId,
//       logLevel: logLevel,
//       autoRequestingEnabled: autoRequestingEnabled,
//       isChild: isChild,
//     );
//   }
//
//   @override
//   Future<void> requestCurrency({
//     bool showToastOnReward = true,
//     String currencyId = 'coins',
//   }) {
//     return instance.requestCurrency(
//       showToastOnReward: showToastOnReward,
//       currencyId: currencyId,
//     );
//   }
//
//   @override
//   void setListener(DigitalTurbineListener listener) {
//     instance.setListener(listener);
//   }
//
//   @override
//   Future<void> setLogLevel(LogLevel logLevel) {
//     return instance.setLogLevel(logLevel);
//   }
//
//   @override
//   Future<void> showOfferWall({
//     bool closeOnRedirect = false,
//     Map<String, String>? customParameters,
//   }) {
//     return instance.showOfferWall(
//       closeOnRedirect: closeOnRedirect,
//       customParameters: customParameters,
//     );
//   }
//
//   @override
//   Future<void> disableAutoRequesting(AdType adType, String placementId) {
//      return instance.disableAutoRequesting(adType, placementId);
//   }
//
//   @override
//   Future<void> enableAutoRequesting(AdType adType, String placementId) {
//     return instance.enableAutoRequesting(adType, placementId);
//   }
// }
