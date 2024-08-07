part of 'digital_turbine_plugin.dart';

abstract class DigitalTurbinePlatform extends PlatformInterface {
  DigitalTurbinePlatform() : super(token: _token);

  static final Object _token = Object();

  static DigitalTurbinePlatform _instance = MethodChannelDigitalTurbine();

  static DigitalTurbinePlatform get instance => _instance;

  static set instance(DigitalTurbinePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> initialize({
    required String appId,
    required String userId,
    bool disableAdvertisingId = false,
  });

  Future<void> showOfferWall({
    bool closeOnRedirect = false,
    Map<String, String>? customParameters,
  });

  Future<void> requestCurrency({
    bool showToastOnReward = true,
    String currencyId = 'coins',
  });

  Future<void> setLogLevel(LogLevel logLevel);

  void setListener(DigitalTurbineListener listener);
}

abstract class DigitalTurbineListener {
  void onShowError(String error);

  void onShow(String? placementId);

  void onClose(String? placementId);
}
