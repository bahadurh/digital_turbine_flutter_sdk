import 'package:flutter/material.dart';
import 'package:digital_turbine_plugin/digital_turbine_plugin.dart';

class RewardedAd extends StatefulWidget {
  final String placementId;

  const RewardedAd({super.key, required this.placementId});

  @override
  _RewardedAdState createState() => _RewardedAdState();
}

class _RewardedAdState extends State<RewardedAd> implements DigitalTurbineRewardedListener {
  bool _isRewardAvailable = false;
  bool _isRewardLoading = false;
  bool _isRewardWatchSuccess = false;
  String _status = 'Not initialized';

  @override
  void initState() {
    super.initState();
    _initialize();
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_isRewardLoading) const CircularProgressIndicator(),
        Text('Status: $_status'),
        ElevatedButton(
          onPressed: _requestReward,
          child: const Text('Request Reward'),
        ),
        ElevatedButton(
          onPressed: _isRewardAvailable ? _showReward : null,
          child: const Text('Show Rewarded Ad'),
        ),
        if (_isRewardWatchSuccess)
          const Column(
            children: [
              Icon(Icons.check, color: Colors.green),
              Text('Reward watch success'),
            ],
          ),
      ],
    );
  }

  Future<void> _initialize() async {
    try {
      await DigitalTurbinePlugin.initializeRewarded(widget.placementId);
      DigitalTurbinePlugin.setRewardedListener(this);
      setState(() => _status = 'Rewarded ad initialized');
    } catch (e) {
      setState(() => _status = 'Failed to initialize rewarded ad: $e');
    }
  }

  Future<void> _requestReward() async {
    try {
      await DigitalTurbinePlugin.requestRewarded(widget.placementId);
      setState(() => _status = 'Reward requested');
    } catch (e) {
      setState(() => _status = 'Failed to request reward: $e');
    }
  }

  Future<void> _showReward() async {
    if (_isRewardAvailable) {
      try {
        await DigitalTurbinePlugin.showRewarded(widget.placementId);
        setState(() => _status = 'Showing rewarded ad');
      } catch (e) {
        setState(() => _status = 'Failed to show rewarded ad: $e');
      }
    } else {
      setState(() => _status = 'Rewarded ad not available');
    }
  }


  // DigitalTurbineRewardedListener methods
  @override
  void onRewardedAvailable(String placementId) {
    setState(() {
      _isRewardAvailable = true;
      _isRewardLoading = false;
      _status = 'Rewarded ad available';
    });
  }

  @override
  void onRewardedUnavailable(String placementId) {
    setState(() {
      _isRewardAvailable = false;
      _isRewardLoading = false;
      _status = 'Rewarded ad unavailable';
    });
  }

  @override
  void onRewardedClick(String placementId) {
    setState(() => _status = 'Rewarded ad clicked');
  }

  @override
  void onRewardedComplete(String placementId, bool userRewarded) {
    setState(() {
      _isRewardWatchSuccess = userRewarded;
      _status = 'Rewarded ad complete. User rewarded: $userRewarded';
    });
  }

  @override
  void onRewardedDismiss(String placementId) {
    setState(() => _status = 'Rewarded ad dismissed');
  }

  @override
  void onRewardedShow(String placementId, String impressionData) {
    setState(() => _status = 'Rewarded ad shown');
  }

  @override
  void onRewardedShowFail(String placementId, String error, String impressionData) {
    setState(() => _status = 'Failed to show rewarded ad: $error');
  }

  @override
  void onRewardedWillRequest(String placementId, String requestId) {
    setState(() {
      _isRewardLoading = true;
      _status = 'Rewarded ad will be requested';
    });
  }

  @override
  dispose() {
    DigitalTurbinePlugin.disposeRewardedAd();

    super.dispose();
  }
}