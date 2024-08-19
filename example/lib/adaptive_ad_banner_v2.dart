import 'package:digital_turbine_plugin/digital_turbine_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

typedef AdLoadedCallback = void Function(bool loaded);

class DigitalTurbineBannerController implements DigitalTurbineAdBannerListener {
  final AdLoadedCallback onAdLoaded;
  final String placementId;

  DigitalTurbineBannerController({required this.onAdLoaded, required this.placementId});

  bool _isAdLoaded = false;

  bool get isAdLoaded => _isAdLoaded;

  bool get isAdLoading => !_isAdLoaded;

  void _onPlatformViewCreated() {
    DigitalTurbinePlugin.setAdBannerListener(this);
    DigitalTurbinePlugin.requestAdBanner(placementId);
  }

  Future<void> loadAd() async {
    try {
      _onPlatformViewCreated();
      await const MethodChannel('digital_turbine_banner_view_1').invokeMethod("loadAd");
    } on PlatformException catch (e) {
      print("Failed to load ad: ${e.message}");
    }
  }

  void _setAdLoaded(bool loaded) {
    /// New value is different from the current value
    /// then call the callback
    if (_isAdLoaded != loaded) {
      onAdLoaded(loaded);
      _isAdLoaded = loaded;
    }
  }

  @override
  void onAdBannerClick(String placementId) {
    print('Banner ad clicked');
  }

  @override
  void onAdBannerError(String placementId, String error) {
    print('Banner ad error: $error');
    _setAdLoaded(false);
  }

  @override
  void onAdBannerLoaded(String placementId, String impressionData) {
    print('Banner ad loaded successfully');
    _setAdLoaded(true);
  }

  @override
  void onAdBannerRequestStart(String placementId, String requestId) {
    print("Banner ad request started");
    _setAdLoaded(false);
  }

  @override
  void onAdBannerShow(String placementId, String impressionData) {
    print('Banner ad shown');
  }
}

class DigitalTurbineBannerView extends StatefulWidget {
  final String placementId;
  final DigitalTurbineBannerController controller;

  final double width;
  final double height;

  const DigitalTurbineBannerView({
    super.key,
    required this.controller,
    required this.placementId,
    this.width = 300,
    this.height = 250,
  });

  @override
  _DigitalTurbineBannerViewState createState() => _DigitalTurbineBannerViewState();
}

class _DigitalTurbineBannerViewState extends State<DigitalTurbineBannerView> {
  @override
  Widget build(BuildContext context) {
    Widget platformView;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      platformView = UiKitView(
        viewType: 'digital_turbine_banner_view',
        creationParams: {'placementId': widget.placementId},
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      platformView = AndroidView(
        viewType: 'digital_turbine_banner_view',
        creationParams: {'placementId': widget.placementId},
        creationParamsCodec: const StandardMessageCodec(),
        gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      );
    } else {
      platformView = Text('Banner ads not supported on this platform');
    }

    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.purple,
      child: platformView,
    );
  }

  @override
  void dispose() {
    _disposeAd();

    super.dispose();
  }

  Future<void> _disposeAd() async {
    const channel = MethodChannel('digital_turbine_banner_view_1');

    try {
      await channel.invokeMethod('disposeAd');
    } on PlatformException catch (e) {
      print("Failed to dispose ad: ${e.message}");
    }
  }
}
