package com.gaya.digital_turbine_plugin;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import android.app.Activity;
import android.util.Log;

import com.fyber.fairbid.ads.OfferWall;
import com.fyber.fairbid.ads.offerwall.OfferWallError;
import com.fyber.fairbid.ads.offerwall.OfferWallListener;
import com.fyber.fairbid.ads.offerwall.ShowOptions;
import com.fyber.fairbid.ads.offerwall.VirtualCurrencyRequestOptions;

import java.util.HashMap;
import java.util.Map;

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
                String userId = call.argument("userId");
                boolean disableAdvertisingId = call.argument("disableAdvertisingId");
                initializeSDK(appId, userId, disableAdvertisingId, result);
                break;
            case "showOfferWall":
                boolean closeOnRedirect = call.argument("closeOnRedirect");
                Map<String, String> customParameters = call.argument("customParameters");
                showOfferWall(closeOnRedirect, customParameters, result);
                break;
            case "requestCurrency":
                boolean showToastOnReward = call.argument("showToastOnReward");
                String currencyId = call.argument("currencyId");
                requestCurrency(showToastOnReward, currencyId, result);
                break;
            case "setLogLevel":
                String logLevel = call.argument("logLevel");
                setLogLevel(logLevel, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void initializeSDK(String appId, String userId, boolean disableAdvertisingId, Result result) {
        try {
            if (activity == null) {
                result.error("NO_ACTIVITY", "Activity is not available", null);
                return;
            }
            OfferWall.setUserId(userId);
            OfferWall.start(activity, appId, createOfferWallListener(), disableAdvertisingId);
            result.success(null);
        } catch (IllegalArgumentException e) {
            Log.d(TAG, e.getLocalizedMessage());
            result.error("INITIALIZE_ERROR", e.getLocalizedMessage(), null);
        }
    }

    private void showOfferWall(boolean closeOnRedirect, Map<String, String> customParameters, Result result) {
        ShowOptions showOptions = new ShowOptions(closeOnRedirect, customParameters);
        OfferWall.show(showOptions);
        result.success(null);
    }

    private void requestCurrency(boolean showToastOnReward, String currencyId, Result result) {
        VirtualCurrencyRequestOptions options = new VirtualCurrencyRequestOptions(showToastOnReward, currencyId);
        OfferWall.requestCurrency(options);
        result.success(null);
    }

    private void setLogLevel(String logLevel, Result result) {
        switch (logLevel) {
            case "verbose":
                OfferWall.setLogLevel(OfferWall.LogLevel.VERBOSE);
                break;
            case "debug":
                OfferWall.setLogLevel(OfferWall.LogLevel.DEBUG);
                break;
            case "info":
                OfferWall.setLogLevel(OfferWall.LogLevel.INFO);
                break;
            case "warning":
                OfferWall.setLogLevel(OfferWall.LogLevel.WARNING);
                break;
            case "error":
                OfferWall.setLogLevel(OfferWall.LogLevel.ERROR);
                break;
            default:
                result.error("INVALID_LOG_LEVEL", "Invalid log level provided", null);
                return;
        }
        result.success(null);
    }

    private OfferWallListener createOfferWallListener() {
        return new OfferWallListener() {
            @Override
            public void onShowError(String placementId, OfferWallError offerWallError) {
                Log.i("OfferWallListener", "offer wall show error: " + offerWallError);
                channel.invokeMethod("onShowError", offerWallError.toString());
            }

            @Override
            public void onShow(String placementId) {
                Log.i("OfferWallListener", "offer wall shown! placement id: " + placementId);
                channel.invokeMethod("onShow", placementId);
            }

            @Override
            public void onClose(String placementId) {
                Log.i("OfferWallListener", "offer wall closed! placement id: " + placementId);
                channel.invokeMethod("onClose", placementId);
            }
        };
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
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}