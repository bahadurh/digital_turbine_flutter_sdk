import 'dart:io';

// iOS Constants (com.girlz.app)
const String IOS_APP_ID = "195055";
const String IOS_REWARDED_PLACEMENT_ID = "2200011";
const String IOS_AD_BANNER_PLACEMENT_ID = "2220653";

/// Android Constants (com.girlz.app)
const String ANDROID_APP_ID = "195100";
const String ANDROID_REWARDED_PLACEMENT_ID = "2200352";
const String ANDROID_AD_BANNER_PLACEMENT_ID = "2219912";

/// Getter methods for the constants platform specific
String get appId => Platform.isIOS ? IOS_APP_ID : ANDROID_APP_ID;

String get bannerAdPlacementId => Platform.isIOS ? IOS_AD_BANNER_PLACEMENT_ID : ANDROID_AD_BANNER_PLACEMENT_ID;

String get rewardedAdPlacementId => Platform.isIOS ? IOS_REWARDED_PLACEMENT_ID : ANDROID_REWARDED_PLACEMENT_ID;
