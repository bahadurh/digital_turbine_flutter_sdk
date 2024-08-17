package com.gaya.digital_turbine_plugin;

import android.app.Activity;
import android.content.Context;
import android.view.View;
import android.widget.FrameLayout;
import android.view.ViewGroup;
import com.fyber.fairbid.ads.Banner;
import com.fyber.fairbid.ads.ImpressionData;
import com.fyber.fairbid.ads.banner.BannerError;
import com.fyber.fairbid.ads.banner.BannerListener;
import com.fyber.fairbid.ads.banner.BannerOptions;
import com.fyber.fairbid.ads.banner.BannerSize;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.platform.PlatformView;

import java.util.HashMap;
import java.util.Map;

public class BannerView implements PlatformView, MethodChannel.MethodCallHandler {

    private FrameLayout containerView;
    private String placementId;
    private MethodChannel methodChannel;
    private Activity activity;

    BannerView(Context context, Activity activity, int id, Map<String, Object> creationParams, BinaryMessenger messenger) {
        this.activity = activity;
        this.containerView = new FrameLayout(context);
        this.placementId = (String) creationParams.get("placementId");
        this.methodChannel = new MethodChannel(messenger, "digital_turbine_banner_view_" + id);
        this.methodChannel.setMethodCallHandler(this);
        setupBannerListener();
        loadAd();
    }

    @Override
    public View getView() {
        return containerView;
    }

    @Override
    public void dispose() {
        methodChannel.setMethodCallHandler(null);
        Banner.destroy(placementId);
    }

    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        switch (call.method) {
            case "loadAd":
                loadAd();
                result.success(null);
                break;
            case "disposeAd":
                Banner.destroy(placementId);
                result.success(null);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void setupBannerListener() {
        Banner.setBannerListener(new BannerListener() {
            @Override
            public void onError(String placementId, BannerError error) {
                Map<String, Object> args = new HashMap<>();
                args.put("placementId", placementId);
                args.put("error", error.toString());
                methodChannel.invokeMethod("onBannerError", args);
            }

            @Override
            public void onLoad(String placementId) {
                methodChannel.invokeMethod("onBannerLoad", createArguments(placementId, null));
            }

            @Override
            public void onShow(String placementId, ImpressionData impressionData) {
                methodChannel.invokeMethod("onBannerShow", createArguments(placementId, impressionData));
            }

            @Override
            public void onClick(String placementId) {
                methodChannel.invokeMethod("onBannerClick", createArguments(placementId, null));
            }

            @Override
            public void onRequestStart(String placementId, String requestId) {
                Map<String, Object> args = new HashMap<>();
                args.put("placementId", placementId);
                args.put("requestId", requestId);
                methodChannel.invokeMethod("onBannerRequestStart", args);
            }
        });
    }

    private void loadAd() {
        if (activity != null) {
            BannerOptions options = new BannerOptions()
                    .withSize(BannerSize.MREC).placeInContainer(containerView);

            activity.runOnUiThread(() -> {
                Banner.show(placementId, options, activity);
            });
        } else {
            System.err.println("Activity is null, cannot load banner ad");
        }
    }

    private Map<String, Object> createArguments(String placementId, ImpressionData impressionData) {
        Map<String, Object> args = new HashMap<>();
        args.put("placementId", placementId);
        if (impressionData != null) {
            args.put("impressionData", impressionData.getJsonString());
        }
        return args;
    }
}