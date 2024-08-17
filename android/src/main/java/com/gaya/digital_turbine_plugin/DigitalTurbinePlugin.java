package com.gaya.digital_turbine_plugin;

import android.app.Activity;
import android.util.Log;

import androidx.annotation.NonNull;

import com.fyber.FairBid;
import com.fyber.fairbid.ads.Banner;
import com.fyber.fairbid.ads.ImpressionData;
import com.fyber.fairbid.ads.Rewarded;
import com.fyber.fairbid.ads.banner.BannerError;
import com.fyber.fairbid.ads.banner.BannerListener;
import com.fyber.fairbid.ads.banner.BannerOptions;
import com.fyber.fairbid.ads.banner.BannerSize;
import com.fyber.fairbid.ads.rewarded.RewardedListener;

import java.util.HashMap;
import java.util.Map;
import android.app.Activity;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformViewRegistry;

public class DigitalTurbinePlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private MethodChannel channel;
    private Activity activity;
    private static final String TAG = "DigitalTurbinePlugin";
    private BinaryMessenger binaryMessenger;
    private PlatformViewRegistry viewRegistry;

    @Override
    public void onAttachedToEngine(FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        binaryMessenger = flutterPluginBinding.getBinaryMessenger();
        viewRegistry = flutterPluginBinding.getPlatformViewRegistry();
        channel = new MethodChannel(binaryMessenger, "digital_turbine_plugin");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "initialize":
                handleInitialize(call, result);
                break;
            case "initializeRewarded":
                handleInitializeRewarded(call, result);
                break;
            case "initializeBanner":
                handleInitializeBanner(call, result);
                break;
            case "disableAutoRequesting":
                handleDisableAutoRequesting(call, result);
                break;
            case "requestRewarded":
                handleRequestRewarded(call, result);
                break;
            case "showRewarded":
                handleShowRewarded(call, result);
                break;
            case "isRewardedAvailable":
                handleIsRewardedAvailable(call, result);
                break;
            case "showAdBanner":
                handleShowAdBanner(call, result);
                break;
            case "hideAdBanner":
                handleHideAdBanner(call, result);
                break;
            case "disposeAdBanner":
                handleDestroyAdBanner(call, result);
                break;
            case "disposeRewardAd":
                handleDisposeRewardedAd(result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    /**
     * Handler Methods
     */
    private void handleInitialize(MethodCall call, Result result) {
        String appId = call.argument("appId");
        Map<String, Object> args = call.arguments();
        initialize(appId, args, result);
    }

    private void handleInitializeRewarded(MethodCall call, Result result) {
        String placementId = call.argument("placementId");
        initializeRewarded(placementId, result);
    }

    private void handleInitializeBanner(MethodCall call, Result result) {
        String placementId = call.argument("placementId");
        initializeBanner(placementId, result);
    }

    private void handleDisableAutoRequesting(MethodCall call, Result result) {
        String adType = call.argument("adType");
        String placementId = call.argument("placementId");
        disableAutoRequesting(adType, placementId, result);
    }

    private void handleRequestRewarded(MethodCall call, Result result) {
        String placementId = call.argument("placementId");
        requestRewarded(placementId, result);
    }

    private void handleShowRewarded(MethodCall call, Result result) {
        String placementId = call.argument("placementId");
        showRewarded(placementId, result);
    }

    private void handleIsRewardedAvailable(MethodCall call, Result result) {
        String placementId = call.argument("placementId");
        isRewardedAvailable(placementId, result);
    }

    private void handleShowAdBanner(MethodCall call, Result result) {
        String placementId = call.argument("placementId");
        showAdBanner(placementId, result);
    }

    private void handleHideAdBanner(MethodCall call, Result result) {
        String placementId = call.argument("placementId");
        hideAdBanner(placementId, result);
    }

    private void handleDestroyAdBanner(MethodCall call, Result result) {
        String placementId = call.argument("placementId");
        destroyAdBanner(placementId, result);
    }

    private void handleDisposeRewardedAd(Result result) {
        disposeRewarded(result);
    }


    /**
     * Common Methods
     */
    private void initialize(String appId, Map<String, Object> args, Result result) {
        if (activity == null) {
            result.error("NO_ACTIVITY", "Activity is not available", null);
            return;
        }

        try {
            if (FairBid.hasStarted()) {
                result.success("FairBid SDK has already been initialized");
            } else {
                boolean autoRequestingEnabled = true;
                if (args.containsKey("autoRequestingEnabled") && args.get("autoRequestingEnabled") != null) {
                    autoRequestingEnabled = (Boolean) args.get("autoRequestingEnabled");
                }

                boolean userAsChild = false;
                if (args.containsKey("isChild") && args.get("isChild") != null) {
                    userAsChild = (Boolean) args.get("isChild");
                }

                FairBid sdk = FairBid.configureForAppId(appId)
                        .enableLogs();

                if (!autoRequestingEnabled) {
                    sdk.disableAutoRequesting();
                }

                if (userAsChild) {
                    sdk.setUserAChild(true);
                }

                sdk.start(activity);
                result.success("FairBid SDK initialized successfully");
            }
        } catch (Exception e) {
            Log.e(TAG, "Initialization error: " + e.getLocalizedMessage(), e);
            result.error("INITIALIZE_ERROR", e.getLocalizedMessage(), null);
        }
    }

    private void disableAutoRequesting(String adType, String placementId, Result result) {
        if ("rewarded".equalsIgnoreCase(adType)) {
            Rewarded.disableAutoRequesting(placementId);
            result.success(null);
        } else {
            result.error("INVALID_AD_TYPE", "Invalid ad type for disableAutoRequesting", null);
        }
    }

    private void disposeAll() {
        Banner.setBannerListener(null);
        Rewarded.setRewardedListener(null);

    }


    /**
     * Rewarded Ad Methods
     */
    private void initializeRewarded(String placementId, Result result) {
        setRewardedAdListener();
        Rewarded.request(placementId);
        result.success("REWARDED_AD_INITIALIZED");
    }

    private void requestRewarded(String placementId, Result result) {
        Rewarded.request(placementId);
        result.success("REWARDED_AD_REQUESTED");
    }

    private void showRewarded(String placementId, Result result) {
        if (Rewarded.isAvailable(placementId)) {
            Rewarded.show(placementId, activity);
            result.success("REWARDED_AD_SHOWING");
        } else {
            result.error("UNAVAILABLE", "Rewarded ad is not available", null);
        }
    }

    private void isRewardedAvailable(String placementId, Result result) {
        result.success(Rewarded.isAvailable(placementId));
    }

    private void setRewardedAdListener() {
        Rewarded.setRewardedListener(new RewardedListener() {
            @Override
            public void onShow(String placementId, ImpressionData impressionData) {
                channel.invokeMethod("onRewardedShow", createArguments(placementId, impressionData));
            }

            @Override
            public void onShowFailure(String placementId, ImpressionData impressionData) {
                channel.invokeMethod("onRewardedShowFail", createArguments(placementId, impressionData));
            }

            @Override
            public void onClick(String placementId) {
                channel.invokeMethod("onRewardedClick", createArguments(placementId, null));
            }

            @Override
            public void onHide(String placementId) {
                channel.invokeMethod("onRewardedDismiss", createArguments(placementId, null));
            }

            @Override
            public void onAvailable(String placementId) {
                channel.invokeMethod("onRewardedAvailable", createArguments(placementId, null));
            }

            @Override
            public void onUnavailable(String placementId) {
                channel.invokeMethod("onRewardedUnavailable", createArguments(placementId, null));
            }

            @Override
            public void onCompletion(String placementId, boolean userRewarded) {
                Map<String, Object> args = createArguments(placementId, null);
                args.put("userRewarded", userRewarded);
                channel.invokeMethod("onRewardedComplete", args);
            }

            @Override
            public void onRequestStart(String placementId, String requestId) {
                Map<String, Object> args = createArguments(placementId, null);
                args.put("requestId", requestId);
                channel.invokeMethod("onRewardedWillRequest", args);
            }
        });
    }

    private void disposeRewarded(Result result) {
        Rewarded.setRewardedListener(null);
        result.success("DISPOSED_REWARDED_AD");
    }

    /**
     * Banner Ad Methods
     */
    private void initializeBanner(String placementId, Result result) {
        setAdBannerListener();
        BannerOptions options = new BannerOptions().withSize(BannerSize.MREC);
        Banner.show(placementId, options, activity);
        result.success("BANNER_AD_INITIALIZED");
    }

    private void showAdBanner(String placementId, Result result) {
        BannerOptions options = new BannerOptions().withSize(BannerSize.MREC);
        Banner.show(placementId, options, activity);
        result.success("SHOWING_BANNER_AD");
    }

    private void hideAdBanner(String placementId, Result result) {
        Banner.hide(placementId);
        result.success("HIDING_BANNER_AD");
    }

    private void setAdBannerListener() {
        Banner.setBannerListener(new BannerListener() {
            @Override
            public void onError(String placementId, BannerError error) {
                Map<String, Object> args = new HashMap<>();
                args.put("placementId", placementId);
                args.put("error", error.toString());
                channel.invokeMethod("onBannerError", args);
            }

            @Override
            public void onLoad(String placementId) {
                channel.invokeMethod("onBannerLoad", createArguments(placementId, null));
            }

            @Override
            public void onShow(String placementId, ImpressionData impressionData) {
                channel.invokeMethod("onBannerShow", createArguments(placementId, impressionData));
            }

            @Override
            public void onClick(String placementId) {
                channel.invokeMethod("onBannerClick", createArguments(placementId, null));
            }

            @Override
            public void onRequestStart(String placementId, String requestId) {
                Map<String, Object> args = new HashMap<>();
                args.put("placementId", placementId);
                args.put("requestId", requestId);
                channel.invokeMethod("onBannerRequestStart", args);
            }
        });
    }

    private void destroyAdBanner(String placementId, Result result) {
        Banner.destroy(placementId);
        Banner.setBannerListener(null);
        result.success("DESTROYING_BANNER_AD");
    }


    private Map<String, Object> createArguments(String placementId, ImpressionData impressionData) {
        Map<String, Object> args = new HashMap<>();
        args.put("placementId", placementId);
        if (impressionData != null) {
            args.put("impressionData", impressionData.getJsonString());
        }
        return args;
    }


    /**
     * Lifecycle methods
     */
    @Override
    public void onAttachedToActivity(ActivityPluginBinding binding) {
        this.activity = binding.getActivity();
        // Register the banner view factory
        if (viewRegistry != null && binaryMessenger != null) {
            viewRegistry.registerViewFactory(
                    "digital_turbine_banner_view",
                    new BannerViewFactory(binaryMessenger, activity)
            );
        }
    }
    @Override
    public void onDetachedFromActivityForConfigChanges() {
        activity = null;
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
    }

    @Override
    public void onDetachedFromActivity() {
        activity = null;
        disposeAll();
    }

    @Override
    public void onDetachedFromEngine(FlutterPlugin.FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
        binaryMessenger = null;
        viewRegistry = null;
    }
}