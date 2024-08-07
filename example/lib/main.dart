import 'package:digital_turbine_plugin/digital_turbine_plugin.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Turbine Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Digital Turbine Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver implements DigitalTurbineRewardedListener {
  String _status = 'Not initialized';
  bool _isSDKInitialized = false;
  String rewardedAdPlacementId = "2200790";
  String interstitialAdPlacementId = "2200351";

  bool _isRewardAvailable = false;
  bool _isRewardLoading = false;
  bool _isRewardWatchSuccess = false;




  bool get isRewardWatchSuccess => _isRewardWatchSuccess;
  set isRewardWatchSuccess(bool value) {
    if (_isRewardWatchSuccess != value) {
      _isRewardWatchSuccess = value;
      setStateCustom();
    }
  }
  bool get isRewardLoading => _isRewardLoading;
  set isRewardLoading(bool value) {
    if (_isRewardLoading != value) {
      _isRewardLoading = value;
      setStateCustom();
    }
  }
  bool get isRewardAvailable => _isRewardAvailable;
  set isRewardAvailable(bool value) {
    if (_isRewardAvailable != value) {
      _isRewardAvailable = value;
      setStateCustom();
    }
  }



  void setStateCustom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }




  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    DigitalTurbinePlugin.setRewardedListener(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isSDKInitialized) {
      _initializeSDK();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _initializeSDK() async {
    try {
      await DigitalTurbinePlugin.initialize(appId: "195099", userId: "1");
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

  Future<void> _showRewarded() async {
    try {

      // Check if a Rewarded ad is available
      bool isAvailable = await DigitalTurbinePlugin.isRewardedAvailable(rewardedAdPlacementId);

      // Show a Rewarded ad
      if (isAvailable) {
        await DigitalTurbinePlugin.showRewarded(rewardedAdPlacementId);
      }
    } catch (e) {
      setState(() {
        _status = 'Failed to show Rewarded: $e';
      });
    }
  }

  Future<void> _dipose() async {
    try {
      await DigitalTurbinePlugin.dispose();
      setState(() {
        _status = 'SDK disposed';
        _isSDKInitialized = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Dispose failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(),
            if (_isRewardLoading) const CircularProgressIndicator(),
            if(_isRewardWatchSuccess) Column(
              children: [
                Icon(Icons.check, color: Colors.green, size: 30,),
                const Text('Reward watch success'),
              ],
            ),
            Spacer(),
            Text(
              'Status: $_status',
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSDKInitialized ? null : _initializeSDK,
              child: const Text('Initialize SDK'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => DigitalTurbinePlugin.requestRewarded(rewardedAdPlacementId),
              child: const Text('Request Reward'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed:_isRewardAvailable? _showRewarded : null,
              child: const Text('Show Rewarded'),
            ), const SizedBox(height: 10),
            ElevatedButton(
              onPressed: isRewardWatchSuccess ? _dipose : null,
              child: const Text('Dipose'),
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }

  @override
  void onRewardedAvailable(String placementId) {
    print('Rewarded available: $placementId');
    /// set reward available
    isRewardAvailable = true;
    /// stop loading
    isRewardLoading = false;
  }

  @override
  void onRewardedClick(String placementId) {
    print('Rewarded click: $placementId');
  }

  @override
  void onRewardedComplete(String placementId, bool userRewarded) {
    print('Rewarded complete: $placementId, userRewarded: $userRewarded');
    /// set reward watch success
    isRewardWatchSuccess = true;
  }

  @override
  void onRewardedDismiss(String placementId) {
    print('Rewarded dismiss: $placementId');
  }

  @override
  void onRewardedShow(String placementId, String impressionData) {
    print('Rewarded show: $placementId, impressionData: $impressionData');
  }

  @override
  void onRewardedShowFail(String placementId, String error, String impressionData) {
    print('Rewarded show fail: $placementId, error: $error, impressionData: $impressionData');
  }

  @override
  void onRewardedUnavailable(String placementId) {
    print('Rewarded unavailable: $placementId');
    /// stop loading
    isRewardLoading = false;
  }

  @override
  void onRewardedWillRequest(String placementId, String requestId) {
    isRewardLoading = true;
    print('Rewarded will request: $placementId, requestId: $requestId');
  }
}
