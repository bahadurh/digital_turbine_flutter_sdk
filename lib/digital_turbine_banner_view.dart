import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class DigitalTurbineBannerView extends StatefulWidget {
  final String placementId;
  final double width;
  final double height;

  const DigitalTurbineBannerView({
    Key? key,
    required this.placementId,
    this.width = 300,
    this.height = 250,
  }) : super(key: key);

  @override
  _DigitalTurbineBannerViewState createState() => _DigitalTurbineBannerViewState();
}

class _DigitalTurbineBannerViewState extends State<DigitalTurbineBannerView> {
  MethodChannel? _channel;
  bool _isAdLoaded = false;
  int? _viewId;

  @override
  void initState() {
    super.initState();
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onBannerLoad':
        setState(() {
          _isAdLoaded = true;
        });
        print('Banner ad loaded successfully');
        break;
      case 'onBannerShow':
        print('Banner ad shown');
        break;
      case 'onBannerClick':
        print('Banner ad clicked');
        break;
      case 'onBannerError':
        print('Banner ad error: ${call.arguments['error']}');
        setState(() {
          _isAdLoaded = false;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget platformView;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      platformView = UiKitView(
        viewType: 'digital_turbine_banner_view',
        creationParams: {'placementId': widget.placementId},
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
        gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
        hitTestBehavior: PlatformViewHitTestBehavior.opaque,
      );
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      platformView = AndroidView(
        viewType: 'digital_turbine_banner_view',
        creationParams: {'placementId': widget.placementId},
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      );
    } else {
      platformView = Text('Banner ads not supported on this platform');
    }

    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.transparent,
      child: Stack(
        children: [
          platformView,
          if (!_isAdLoaded)
            Container(
              color: Colors.grey[300],
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  void _onPlatformViewCreated(int id) {
    _viewId = id;
    _channel = MethodChannel('digital_turbine_banner_view_$id');
    _channel!.setMethodCallHandler(_handleMethodCall);
    _loadAd();
  }

  Future<void> _loadAd() async {
    try {
      await _channel?.invokeMethod('loadAd');
    } on PlatformException catch (e) {
      print("Failed to load ad: ${e.message}");
    }
  }

  @override
  void dispose() {
    _disposeAd();
    super.dispose();
  }

  Future<void> _disposeAd() async {
    if (_channel != null && _viewId != null) {
      try {
        await _channel!.invokeMethod('disposeAd');
        _channel!.setMethodCallHandler(null);
        _channel = null;
        _viewId = null;
      } on PlatformException catch (e) {
        print("Failed to dispose ad: ${e.message}");
      }
    }
  }
}