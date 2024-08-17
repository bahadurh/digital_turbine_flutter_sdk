import 'package:digital_turbine_plugin/digital_turbine_plugin.dart';
import 'package:flutter/material.dart';

class AdaptiveAdBanner extends StatefulWidget {
  final String placementId;
  final int maxRetries;

  const AdaptiveAdBanner({
    super.key,
    required this.placementId,
    this.maxRetries = 3,
  });

  @override
  State<AdaptiveAdBanner> createState() => _AdaptiveAdBannerState();
}

class _AdaptiveAdBannerState extends State<AdaptiveAdBanner> with WidgetsBindingObserver implements DigitalTurbineAdBannerListener {
  bool _isBannerAdLoaded = false;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    DigitalTurbinePlugin.setAdBannerListener(this);
    _initializeAd();
  }

  @override
  void dispose() {
    _destroyAd();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!_isBannerAdLoaded) {
          return Container(
            height: 50,
            color: Colors.transparent,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        return const SizedBox(height: 50); // Placeholder for the ad
      },
    );
  }

  Future<void> _initializeAd() async {
    try {
      await DigitalTurbinePlugin.initializeBanner(widget.placementId);
      await DigitalTurbinePlugin.showAdBanner(widget.placementId);
    } catch (e) {
      print("AdBanner initialization error: $e");
      _retryLoadAd();
    }
  }

  void _retryLoadAd() {
    if (_retryCount < widget.maxRetries) {
      _retryCount++;
      Future.delayed(const Duration(seconds: 1), _initializeAd);
    } else {
      setState(() => _isBannerAdLoaded = false);
      print("AdBanner failed to load after $_retryCount retries");
    }
  }

  Future<void> _destroyAd() async {
    try {
      await DigitalTurbinePlugin.disposeAdBanner(widget.placementId);
    } catch (e) {
      print("AdBanner destruction error: $e");
    }
  }

  @override
  void onAdBannerLoaded(String placementId, String impressionData) {
    print("onAdBannerLoaded: $placementId, impressionData: $impressionData");
    if (mounted) {
      setState(() {
        _isBannerAdLoaded = true;
        _retryCount = 0;
      });
    }
  }

  @override
  void onAdBannerError(String placementId, String error) {
    print("onAdBannerError: $placementId, error: $error");
    if (mounted) {
      setState(() => _isBannerAdLoaded = false);
      _retryLoadAd();
    }
  }

  @override
  void onAdBannerShow(String placementId, String impressionData) {
    if (mounted) {
      setState(() {
        _isBannerAdLoaded = true;
        _retryCount = 0;
      });
    }
    print("onAdBannerShow: $placementId, impressionData: $impressionData");
  }

  @override
  void onAdBannerClick(String placementId) {
    print("onAdBannerClick: $placementId");
  }

  @override
  void onAdBannerRequestStart(String placementId, String requestId) {
    print("onAdBannerRequestStart: $placementId, requestId: $requestId");
  }
}