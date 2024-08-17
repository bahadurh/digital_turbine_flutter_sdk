import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// A widget that displays a banner ad from Digital Turbine.
/// You can use this widget to display banner ads in your app inside a [Column] or [Row or any other widget.
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
  late MethodChannel _channel;

  @override
  void initState() {
    super.initState();
    _channel = MethodChannel('digital_turbine_banner_view_${widget.placementId}');
  }

  @override
  Widget build(BuildContext context) {
    // This is used for iOS
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return Container(
        color: Colors.red,
        width: widget.width,
        height: widget.height,
        child: UiKitView(
          viewType: 'digital_turbine_banner_view',
          creationParams: {'placementId': widget.placementId},
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        ),
      );
    }
    // For Android, you would use AndroidView here
    else if (defaultTargetPlatform == TargetPlatform.android) {
      return Container(
        color: Colors.red,
        width: widget.width,
        height: widget.height,
        child: AndroidView(
          viewType: 'digital_turbine_banner_view',
          creationParams: {'placementId': widget.placementId},
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
        ),
      );
    }
    // For other platforms, show a placeholder
    else {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: Text('Banner ads not supported on this platform'),
      );
    }
  }

  void _onPlatformViewCreated(int id) {
    _channel = MethodChannel('digital_turbine_banner_view_$id');
    _loadAd();
  }

  Future<void> _loadAd() async {
    try {
      await _channel.invokeMethod('loadAd');
    } on PlatformException catch (e) {
      print("Failed to load ad: ${e.message}");
    }
  }

  @override
  void dispose() {
    // _disposeAd();
    super.dispose();
  }

  Future<void> _disposeAd() async {
    try {
      await _channel.invokeMethod('disposeAd');
    } on PlatformException catch (e) {
      print("Failed to dispose ad: ${e.message}");
    }
  }
}
