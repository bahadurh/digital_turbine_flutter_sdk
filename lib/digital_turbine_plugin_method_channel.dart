part of 'digital_turbine_plugin.dart';

class MethodChannelDigitalTurbine extends DigitalTurbinePlatform {
  static const MethodChannel _channel = MethodChannel('digital_turbine_plugin');

  @override
  Future<void> initialize({
    required String appId,
    required String userId,
    bool disableAdvertisingId = false,
  }) async {
    await _channel.invokeMethod('initialize', {
      'appId': appId,
      'userId': userId,
      'disableAdvertisingId': disableAdvertisingId,
    });
  }

  @override
  Future<void> showOfferWall({
    bool closeOnRedirect = false,
    Map<String, String>? customParameters,
  }) async {
    await _channel.invokeMethod('showOfferWall', {
      'closeOnRedirect': closeOnRedirect,
      'customParameters': customParameters,
    });
  }

  @override
  Future<void> requestCurrency({
    bool showToastOnReward = true,
    String currencyId = 'coins',
  }) async {
    await _channel.invokeMethod('requestCurrency', {
      'showToastOnReward': showToastOnReward,
      'currencyId': currencyId,
    });
  }

  @override
  Future<void> setLogLevel(LogLevel logLevel) async {
    await _channel.invokeMethod('setLogLevel', {
      'logLevel': logLevel.toString().split('.').last,
    });
  }

  @override
  void setListener(DigitalTurbineListener listener) {
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onShowError':
          listener.onShowError(call.arguments);
          break;
        case 'onShow':
          listener.onShow(call.arguments);
          break;
        case 'onClose':
          listener.onClose(call.arguments);
          break;
      }
    });
  }
}
