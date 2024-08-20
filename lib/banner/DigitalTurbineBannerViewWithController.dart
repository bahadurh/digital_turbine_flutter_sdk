
import 'package:digital_turbine_plugin/digital_turbine_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class DigitalTurbineBannerViewWithController extends StatefulWidget {
  final DTController controller;

  const DigitalTurbineBannerViewWithController({super.key, required this.controller});

  @override
  _DigitalTurbineBannerViewWithControllerState createState() => _DigitalTurbineBannerViewWithControllerState();
}

class _DigitalTurbineBannerViewWithControllerState extends State<DigitalTurbineBannerViewWithController> {
  @override
  void initState() {
    super.initState();
  }

  @override
  didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _onPlatformViewCreated(int viewId) {
    widget.controller.showAd();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget platformView;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      platformView = UiKitView(
        viewType: 'digital_turbine_banner_view',
        creationParams: {'placementId': widget.controller.placementId},
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      platformView = AndroidView(
        viewType: 'digital_turbine_banner_view',
        creationParams: {'placementId': widget.controller.placementId},
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else {
      platformView = Text('Banner ads not supported on this platform');
    }

    return Container(
      width: widget.controller.size.width,
      height: widget.controller.size.height,
      color: Colors.transparent,
      child: Stack(
        children: [
          platformView,
          if (!widget.controller.isAdLoaded)
            Container(
              color: Colors.grey[300],
              child: Center(child: CircularProgressIndicator()),
            )
          else
            Text('Ad loaded')
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }
}

class DTController implements DigitalTurbineAdBannerListener {
  final String placementId;
  final Function(bool) onAdLoaded;
  final Size size;

  DTController({required this.placementId, required this.onAdLoaded, this.size = const Size(300, 250)}) {
    DigitalTurbinePlugin.setAdBannerListener(this);
    loadAd();
  }

  final _channel = const MethodChannel('digital_turbine_banner_view_1');
  bool _isAdLoaded = false;

  Future<void> loadAd() async {
    try {
      await DigitalTurbinePlugin.requestAdBanner(placementId);
    } on PlatformException catch (e) {
      print("Failed to load ad: ${e.message}");
    }
  }

  Future<void> showAd() async {
    try {
      await _channel.invokeMethod('loadAd');
    } on PlatformException catch (e) {
      print("Failed to show ad: ${e.message}");
    }
  }

  @override
  void onAdBannerClick(String placementId) {
    debugPrint("onAdBannerClick");
  }

  @override
  void onAdBannerError(String placementId, String error) {
    debugPrint("onAdBannerError: $error");
    isAdLoaded = false;
  }

  @override
  void onAdBannerLoaded(String placementId, String impressionData) {
    debugPrint("onAdBannerLoaded");
    isAdLoaded = true;
  }

  @override
  void onAdBannerRequestStart(String placementId, String requestId) {
    debugPrint("onAdBannerRequestStart, requestId: $requestId");
  }

  @override
  void onAdBannerShow(String placementId, String impressionData) {
    debugPrint("onAdBannerShow");
  }

  void debugPrint(String message) {
    print("$runtimeType: $message");
  }

  MethodChannel get channel => _channel;

  set isAdLoaded(bool value) {
    if (_isAdLoaded == value) return;
    _isAdLoaded = value;
    onAdLoaded(value);
  }

  bool get isAdLoaded => _isAdLoaded;

  void dispose() {
    channel.invokeMethod("disposeAd");
    channel.setMethodCallHandler(null);
  }
}
