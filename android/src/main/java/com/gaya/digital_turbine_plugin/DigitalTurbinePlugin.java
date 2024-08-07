package com.gaya.digital_turbine_plugin;

import android.app.Activity;
import android.util.Log;

import androidx.annotation.NonNull;

import com.fyber.FairBid;
import com.fyber.fairbid.ads.ImpressionData;
import com.fyber.fairbid.ads.Rewarded;
import com.fyber.fairbid.ads.rewarded.RewardedListener;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

public class DigitalTurbinePlugin implements FlutterPlugin, MethodCallHandler, ActivityAware {
    private MethodChannel channel;
    private Activity activity;
    private static final String TAG = "DigitalTurbinePlugin";

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "digital_turbine_plugin");
        channel.setMethodCallHandler(this);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
        switch (call.method) {
            case "initialize":
                String appId = call.argument("appId");
                Map<String, Object> args = new HashMap<>();
                args.put("autoRequestingEnabled", call.argument("autoRequestingEnabled"));
                args.put("isChild", call.argument("isChild"));
                initializeSDK(appId, args, result);
                break;

            case "disableAutoRequesting": {
                String _appId = call.argument("appId");
                disableAutoRequesting(_appId, result);
                break;
            }

            case "showRewarded":
                String placement = call.argument("placementId");
                showRewarded(placement, result);
                break;
            case "requestRewarded":
                String placementRequest = call.argument("placementId");
                requestRewarded(placementRequest, result);
                break;
            case "isRewardedAvailable":
                String placementAvailable = call.argument("placementId");
                isRewardedAvailable(placementAvailable, result);
                break;
            case "dispose":
                disposeRewardedAdListener();
                result.success(null);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void initializeSDK(String appId, Map<String, Object> args, Result result) {
        if (activity == null) {
            result.error("NO_ACTIVITY", "Activity is not available", null);
            return;
        }

        try {
            /// Check if the SDK has already been initialized
            if (FairBid.hasStarted()) {
                result.success(null);
            } else {
                /// Initialize the SDK

                // Retrieve settings from args map with default values
                boolean autoRequestingEnabled = true; // Default to true if not specified or if null
                if (args.containsKey("autoRequestingEnabled") && args.get("autoRequestingEnabled") != null) {
                    autoRequestingEnabled = (Boolean) args.get("autoRequestingEnabled");
                }

                boolean userAsChild = false; // Default to false if not specified or if null
                if (args.containsKey("isChild") && args.get("isChild") != null) {
                    userAsChild = (Boolean) args.get("isChild");
                }

                // Configure FairBid SDK with the settings
                FairBid sdk = FairBid.configureForAppId(appId)
                        .enableLogs();  // Always enable logs, as no condition was specified

                if (!autoRequestingEnabled) {
                    sdk.disableAutoRequesting();  // Disable auto-requesting if specified
                }

                if (userAsChild) {
                    sdk.setUserAChild(true);  // Set user as a child if specified
                }

                setRewardedAdListener();  // Set the rewarded ad listener

                // Initialize the SDK with the context of the current activity
                sdk.start(activity);

                result.success(null);  // Notify success
            }

        } catch (Exception e) {
            Log.e(TAG, "Initialization error: " + e.getLocalizedMessage(), e);
            result.error("INITIALIZE_ERROR", e.getLocalizedMessage(), null);
        }
    }

    private void disableAutoRequesting(String appId, Result result) {
        FairBid.configureForAppId(appId).disableAutoRequesting();
        result.success("AUTO_REQUESTING_DISABLED");

    }

    ///
    // Rewarded Ad
    ///
    private void showRewarded(String placement, Result result) {
        if (activity == null) {
            result.error("NO_ACTIVITY", "Activity is not available", null);
            return;
        }

        try {
            if (Rewarded.isAvailable(placement)) {
                Rewarded.show(placement, activity);
                result.success("REWARDED_AD_SHOWING");
            } else {
                result.error("REWARDED_NOT_AVAILABLE", "Rewarded ad is not available", null);
            }
        } catch (Exception e) {
            Log.e(TAG, "Rewarded ad error: " + e.getLocalizedMessage(), e);
            result.error("REWARDED_ERROR", e.getLocalizedMessage(), null);
        }
    }

    private void requestRewarded(String placement, Result result) {
        if (activity == null) {
            result.error("NO_ACTIVITY", "Activity is not available", null);
            return;
        }

        try {
            if (!Rewarded.isAvailable(placement)) {
                Rewarded.request(placement);
                result.success("REWARDED_REQUESTED");
            } else {
                result.success("REWARDED_ALREADY_AVAILABLE");
            }
        } catch (Exception e) {
            Log.e(TAG, "Rewarded ad error: " + e.getLocalizedMessage(), e);
            result.error("REWARDED_ERROR", e.getLocalizedMessage(), null);
        }
    }

    private void isRewardedAvailable(String placement, Result result) {
        if (activity == null) {
            result.error("NO_ACTIVITY", "Activity is not available", null);
            return;
        }

        try {
            result.success(Rewarded.isAvailable(placement));
        } catch (Exception e) {
            Log.e(TAG, "Rewarded ad error: " + e.getLocalizedMessage(), e);
            result.error("REWARDED_ERROR", e.getLocalizedMessage(), null);
        }
    }

    private void setRewardedAdListener() {
        Rewarded.setRewardedListener(new RewardedListener() {

            @Override
            public void onShow(String placement, ImpressionData impressionData) {
                channel.invokeMethod("onRewardedShow", createArguments(placement, impressionData));
            }

            @Override
            public void onShowFailure(String placement, ImpressionData impressionData) {
                channel.invokeMethod("onRewardedShowFail", createArguments(placement, impressionData));
            }

            @Override
            public void onClick(String placement) {
                channel.invokeMethod("onRewardedClick", createArguments(placement, null));
            }

            @Override
            public void onHide(String placement) {
                channel.invokeMethod("onRewardedDismiss", createArguments(placement, null));
            }

            @Override
            public void onAvailable(String placement) {
                channel.invokeMethod("onRewardedAvailable", createArguments(placement, null));
            }

            @Override
            public void onUnavailable(String placement) {
                channel.invokeMethod("onRewardedUnavailable", createArguments(placement, null));
            }

            @Override
            public void onCompletion(String placement, boolean userRewarded) {
                Map<String, Object> args = createArguments(placement, null);
                args.put("userRewarded", userRewarded);
                channel.invokeMethod("onRewardedComplete", args);
            }


            @Override
            public void onRequestStart(String s, String s1) {
                /// Notify the flutter side that the rewarded ad request has started

                Map<String, Object> args = createArguments(s, null);
                args.put("requestId", s1);
                channel.invokeMethod("onRewardedWillRequest", args);

            }
        });
    }

    private void disposeRewardedAdListener() {
        Log.d(TAG, "Disposing Rewarded Ad Listener");
        Rewarded.setRewardedListener(null);
    }


    private Map<String, Object> createArguments(String placement, ImpressionData impressionData) {
        Map<String, Object> args = new HashMap<>();
        args.put("placementId", placement);
        if (impressionData != null) {
            args.put("impressionData", impressionData.getJsonString());
        }
        return args;
    }


    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        activity = binding.getActivity();
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
        disposeRewardedAdListener();
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        disposeRewardedAdListener();
        channel.setMethodCallHandler(null);

    }
}