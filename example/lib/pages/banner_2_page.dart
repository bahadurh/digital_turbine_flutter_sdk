import 'package:flutter/material.dart';

import '../adaptive_ad_banner_2.dart';

class Banner2Page extends StatefulWidget {
  final String placementId;

  const Banner2Page({Key? key, required this.placementId}) : super(key: key);

  @override
  State<Banner2Page> createState() => _Banner2PageState();
}

class _Banner2PageState extends State<Banner2Page> {
  late final DTController _controller;

  List<Widget> pages = [
    Container(
      color: Colors.pink,
      child: const Center(child: Text('Page 1')),
    ),
    Container(
      color: Colors.red,
      child: const Center(child: Text('Page 2')),
    ),
    Container(
      color: Colors.blue,
      child: const Center(child: Text('Page 3')),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = DTController(onAdLoaded: _onAdLoaded, placementId: widget.placementId);
  }

  bool isAdLoadedViaController = false;

  void _onAdLoaded(bool loaded) {
    debugPrint("Ad Loaded with controller");
    isAdLoadedViaController = loaded;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banner Ad Example 2'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.red,
            ),
            onPressed: onAddAd,
          ),

          /// load ad
          IconButton(
            icon: Icon(
              isAdLoadedViaController ? Icons.check : Icons.add,
              color: Colors.green,
            ),
            onPressed: () {
              _controller.loadAd();
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 250,
            width: 300,
            child: PageView.builder(
              itemCount: pages.length,
              itemBuilder: (context, index) {
                return pages[index];
              },
            ),
          ),
        ],
      ),
    );
  }

  void onAddAd() {
    pages.add(
      Column(
        children: [
          SizedBox(
            height: 250,
            width: 300,
            child: DigitalTurbineBannerViewWithController(
              controller: _controller,
            ),
          ),
        ],
      ),
    );
    setState(() {});
  }
}
