// part of 'digital_turbine_plugin.dart';
//
// class MethodChannelDigitalTurbine extends DigitalTurbinePlatform {
//   static const MethodChannel _channel = MethodChannel('digital_turbine_plugin');
//
//   @override
//   Future<void> initialize({
//     required String appId,
//     String? userId,
//     LogLevel? logLevel,
//     bool? autoRequestingEnabled,
//     bool? isChild,
//   }) async {
//     await _channel.invokeMethod('initialize', {
//       'appId': appId,
//       'userId': userId,
//       'logLevel': logLevel?.toString().split('.').last,
//       'autoRequestingEnabled': autoRequestingEnabled,
//       'isChild': isChild,
//     });
//   }
//
//   @override
//   Future<void> showOfferWall({
//     bool closeOnRedirect = false,
//     Map<String, String>? customParameters,
//   }) async {
//     await _channel.invokeMethod('showOfferWall', {
//       'closeOnRedirect': closeOnRedirect,
//       'customParameters': customParameters,
//     });
//   }
//
//   @override
//   Future<void> requestCurrency({
//     bool showToastOnReward = true,
//     String currencyId = 'coins',
//   }) async {
//     await _channel.invokeMethod('requestCurrency', {
//       'showToastOnReward': showToastOnReward,
//       'currencyId': currencyId,
//     });
//   }
//
//   @override
//   Future<void> setLogLevel(LogLevel logLevel) async {
//     await _channel.invokeMethod('setLogLevel', {
//       'logLevel': logLevel.toString().split('.').last,
//     });
//   }
//
//   @override
//   void setListener(DigitalTurbineListener listener) {
//     _channel.setMethodCallHandler((call) async {
//       switch (call.method) {
//         case 'onShowError':
//           listener.onShowError(call.arguments);
//           break;
//         case 'onShow':
//           listener.onShow(call.arguments);
//           break;
//         case 'onClose':
//           listener.onClose(call.arguments);
//           break;
//       }
//     });
//   }
//
//   @override
//   Future<void> disableAutoRequesting(AdType adType, String placementId) async {
//     if (Platform.isIOS) {
//       await _channel.invokeMethod('disableAutoRequesting', {
//         'adType': adType.toString().split('.').last,
//         'placementId': placementId,
//       });
//     }
//   }
//
//   @override
//   Future<void> enableAutoRequesting(AdType adType, String placementId) async {
//     if (Platform.isIOS) {
//       await _channel.invokeMethod('enableAutoRequesting', {
//         'adType': adType.toString().split('.').last,
//         'placementId': placementId,
//       });
//     }
//   }
// }
