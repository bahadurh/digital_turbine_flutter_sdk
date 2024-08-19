import 'package:digital_turbine_plugin/digital_turbine_plugin.dart';
import 'package:digital_turbine_plugin_example/adaptive_ad_banner.dart';
import 'package:digital_turbine_plugin_example/pages/banner_2_page.dart';
import 'package:digital_turbine_plugin_example/rewarded_ad.dart';
import 'package:flutter/material.dart';

import 'constants.dart';

///
/// Developed by: Bahadur Zaman @ Gaya Communities ltd.
/// Date: 2024-08-10
///
///

main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Turbine Plugin Example',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const MyHomePage(title: 'Digital Turbine Plugin Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _status = 'Not initialized';
  bool _isSDKInitialized = false;

  /// Initialize the SDK with the provided appId.
  ///
  /// This method should be called before showing any ads.
  Future<void> _initializeSDK() async {
    try {
      await DigitalTurbinePlugin.initialize(appId: appId, logLevel: LogLevel.verbose);
      setState(() {
        _status = 'SDK Initialized';
        _isSDKInitialized = true;
      });
    } catch (e) {
      setState(() {
        _status = 'Initialization failed: $e';
      });
    }
  }

  /// This method demonstrates how to show a rewarded ad.
  void _showRewardedAd() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Rewarded Ad')),
        body: Center(
          child: RewardedAd(placementId: rewardedAdPlacementId),
        ),
      ),
    ));
  }

  /// This method demonstrates how to show a banner ad.
  void _showBannerAd() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Banner Ad')),
        body: Center(
          child: AdaptiveAdBanner(placementId: bannerAdPlacementId),
        ),
      ),
    ));
  }

  /// This method demonstrates how to show a banner ad using a platform view in a PageView.
  void _showBannerAdPlatformView() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Banner Ad PlatformView')),
          body: PageView.builder(
            itemCount: 3,
            itemBuilder: (context, index) {
              switch (index) {
                case 0:
                  Center(
                    child: DigitalTurbineBannerView(placementId: bannerAdPlacementId),
                  );
                case 1:
                  Container(
                    color: Colors.red,
                    child: const Center(
                      child: Text('Page 2'),
                    ),
                  );

                case 2:
                  Container(
                    color: Colors.blue,
                    child: const Center(
                      child: Text('Page 3'),
                    ),
                  );
              }
              return const SizedBox();
            },
          ),
        ),
      ),
    );
  }

  void _showBannerAdPlatformView2() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Banner2Page(placementId: bannerAdPlacementId),
      ),
    );
  }

  void _showTestSuite() {
    DigitalTurbinePlugin.showTestSuite();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'SDK Status: $_status',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSDKInitialized ? null : _initializeSDK,
              child: const Text('Initialize SDK'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSDKInitialized ? _showRewardedAd : null,
              child: const Text('Rewarded Ad'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSDKInitialized ? _showBannerAd : null,
              child: const Text('Banner Ad'),
            ),
            ElevatedButton(
              onPressed: _isSDKInitialized ? _showBannerAdPlatformView : null,
              child: const Text('Banner Ad PlatformView'),
            ),
            ElevatedButton(
              onPressed: _isSDKInitialized ? _showBannerAdPlatformView2 : null,
              child: const Text('Banner Ad PlatformView 2'),
            ),

            ElevatedButton(
              onPressed: _isSDKInitialized ? _showTestSuite : null,
              child: const Text('Show Test Suite'),
            ),
          ],
        ),
      ),
    );
  }
}
