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

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver implements DigitalTurbineListener {
  String _status = 'Not initialized';
  bool _isSDKInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    DigitalTurbinePlugin.instance.setListener(this);
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
      await DigitalTurbinePlugin.instance.initialize(
        appId: "<paste app id>",
        userId: "<unique user id>",
      );
      await DigitalTurbinePlugin.instance.setLogLevel(LogLevel.info);
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

  Future<void> _showOfferWall() async {
    try {
      await DigitalTurbinePlugin.instance.showOfferWall(
        closeOnRedirect: false,
        customParameters: {'key': 'value'},
      );
      setState(() {
        _status = 'Showing OfferWall';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to show OfferWall: $e';
      });
    }
  }

  Future<void> _requestCurrency() async {
    try {
      await DigitalTurbinePlugin.instance.requestCurrency(
        showToastOnReward: true,
        currencyId: 'coins',
      );
      setState(() {
        _status = 'Requesting Currency';
      });
    } catch (e) {
      setState(() {
        _status = 'Failed to request currency: $e';
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
              onPressed: _isSDKInitialized ? _showOfferWall : null,
              child: const Text('Show OfferWall'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isSDKInitialized ? _requestCurrency : null,
              child: const Text('Request Currency'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onShowError(String error) {
    setState(() {
      _status = 'OfferWall show error: $error';
    });
  }

  @override
  void onShow(String? placementId) {
    setState(() {
      _status = 'OfferWall shown with placement ID: $placementId';
    });
  }

  @override
  void onClose(String? placementId) {
    setState(() {
      _status = 'OfferWall closed with placement ID: $placementId';
    });
  }
}