package com.gaya.digital_turbine_plugin;

import android.app.Activity;
import android.content.Context;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import java.util.Map;

public class BannerViewFactory extends PlatformViewFactory {
    private final BinaryMessenger messenger;
    private final Activity activity;

    public BannerViewFactory(BinaryMessenger messenger, Activity activity) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
        this.activity = activity;
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        Map<String, Object> creationParams = (Map<String, Object>) args;
        return new BannerView(context, activity, viewId, creationParams, messenger);
    }
}