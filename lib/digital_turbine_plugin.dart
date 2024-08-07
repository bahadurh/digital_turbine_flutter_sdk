library digital_turbine_plugin;

import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

part 'digital_turbine_plugin_method_channel.dart';
part 'digital_turbine_plugin_platform_interface.dart';
part 'log_level.dart';

class DigitalTurbinePlugin extends DigitalTurbinePlatform {
  static DigitalTurbinePlatform _instance = MethodChannelDigitalTurbine();

  static DigitalTurbinePlatform get instance => _instance;

  static set instance(DigitalTurbinePlatform instance) {
    _instance = instance;
  }

  @override
  Future<void> initialize({
    required String appId,
    required String userId,
    bool disableAdvertisingId = false,
  }) {
    return instance.initialize(
      appId: appId,
      userId: userId,
      disableAdvertisingId: disableAdvertisingId,
    );
  }

  @override
  Future<void> requestCurrency({
    bool showToastOnReward = true,
    String currencyId = 'coins',
  }) {
    return instance.requestCurrency(
      showToastOnReward: showToastOnReward,
      currencyId: currencyId,
    );
  }

  @override
  void setListener(DigitalTurbineListener listener) {
    instance.setListener(listener);
  }

  @override
  Future<void> setLogLevel(LogLevel logLevel) {
    return instance.setLogLevel(logLevel);
  }

  @override
  Future<void> showOfferWall({
    bool closeOnRedirect = false,
    Map<String, String>? customParameters,
  }) {
    return instance.showOfferWall(
      closeOnRedirect: closeOnRedirect,
      customParameters: customParameters,
    );
  }
}
