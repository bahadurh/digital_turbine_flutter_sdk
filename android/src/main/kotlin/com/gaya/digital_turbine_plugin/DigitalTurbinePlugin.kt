// DigitalTurbinePlugin.kt
package com.gaya.digital_turbine_plugin

import android.app.Activity
import android.util.Log
import androidx.annotation.NonNull
import com.fyber.FairBid
import com.fyber.fairbid.ads.Banner
import com.fyber.fairbid.ads.ImpressionData
import com.fyber.fairbid.ads.Rewarded
import com.fyber.fairbid.ads.banner.BannerError
import com.fyber.fairbid.ads.banner.BannerListener
import com.fyber.fairbid.ads.banner.BannerOptions
import com.fyber.fairbid.ads.banner.BannerSize
import com.fyber.fairbid.ads.rewarded.RewardedListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.platform.PlatformViewRegistry

class DigitalTurbinePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private lateinit var binaryMessenger: BinaryMessenger
    private lateinit var viewRegistry: PlatformViewRegistry

    companion object {
        private const val TAG = "DigitalTurbinePlugin"
    }

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        binaryMessenger = flutterPluginBinding.binaryMessenger
        viewRegistry = flutterPluginBinding.platformViewRegistry
        channel = MethodChannel(binaryMessenger, "digital_turbine_plugin")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "initialize" -> handleInitialize(call, result)
            "initializeRewarded" -> handleInitializeRewarded(call, result)
            "initializeBanner" -> handleInitializeBanner(call, result)
            "disableAutoRequesting" -> handleDisableAutoRequesting(call, result)
            "requestRewarded" -> handleRequestRewarded(call, result)
            "showRewarded" -> handleShowRewarded(call, result)
            "isRewardedAvailable" -> handleIsRewardedAvailable(call, result)
            "requestAdBanner" -> handleRequestAdBanner(call, result)
            "showAdBanner" -> handleShowAdBanner(call, result)
            "hideAdBanner" -> handleHideAdBanner(call, result)
            "disposeAdBanner" -> handleDestroyAdBanner(call, result)
            "disposeRewardAd" -> handleDisposeRewardedAd(result)
            "testSuite" -> handleTestSuite(result)
            else -> result.notImplemented()
        }
    }

    private fun handleInitialize(call: MethodCall, result: Result) {
        val appId = call.argument<String>("appId")
        val args = call.arguments as? Map<String, Any>
        initialize(appId, args, result)
    }

    private fun handleInitializeRewarded(call: MethodCall, result: Result) {
        val placementId = call.argument<String>("placementId")
        initializeRewarded(placementId, result)
    }

    private fun handleInitializeBanner(call: MethodCall, result: Result) {
        val placementId = call.argument<String>("placementId")
        initializeBanner(placementId, result)
    }

    private fun handleDisableAutoRequesting(call: MethodCall, result: Result) {
        val adType = call.argument<String>("adType")
        val placementId = call.argument<String>("placementId")
        disableAutoRequesting(adType, placementId, result)
    }

    private fun handleRequestRewarded(call: MethodCall, result: Result) {
        val placementId = call.argument<String>("placementId")
        requestRewarded(placementId, result)
    }

    private fun handleShowRewarded(call: MethodCall, result: Result) {
        val placementId = call.argument<String>("placementId")
        showRewarded(placementId, result)
    }

    private fun handleIsRewardedAvailable(call: MethodCall, result: Result) {
        val placementId = call.argument<String>("placementId")
        isRewardedAvailable(placementId, result)
    }

    private fun handleRequestAdBanner(call: MethodCall, result: Result) {
        val placementId = call.argument<String>("placementId")
        requestAdBanner(placementId, result)
    }

    private fun handleShowAdBanner(call: MethodCall, result: Result) {
        val placementId = call.argument<String>("placementId")
        showAdBanner(placementId, result)
    }

    private fun handleHideAdBanner(call: MethodCall, result: Result) {
        val placementId = call.argument<String>("placementId")
        hideAdBanner(placementId, result)
    }

    private fun handleDestroyAdBanner(call: MethodCall, result: Result) {
        val placementId = call.argument<String>("placementId")
        destroyAdBanner(placementId, result)
    }

    private fun handleDisposeRewardedAd(result: Result) {
        disposeRewarded(result)
    }

    private fun handleTestSuite(result: Result) {
        FairBid.showTestSuite(activity)
        result.success("TEST_SUITE_STARTED")
    }

    private fun initialize(appId: String?, args: Map<String, Any>?, result: Result) {
        if (activity == null) {
            result.error("NO_ACTIVITY", "Activity is not available", null)
            return
        }

        try {
            if (FairBid.hasStarted()) {
                result.success("FairBid SDK has already been initialized")
            } else {
                val autoRequestingEnabled = args?.get("autoRequestingEnabled") as? Boolean ?: true
                val userAsChild = args?.get("isChild") as? Boolean ?: false

                val sdk = FairBid.configureForAppId(appId)
                    .enableLogs()

                if (!autoRequestingEnabled) {
                    sdk.disableAutoRequesting()
                }

                if (userAsChild) {
                    sdk.setUserAChild(true)
                }

                sdk.start(activity)
                result.success("FairBid SDK initialized successfully")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Initialization error: ${e.localizedMessage}", e)
            result.error("INITIALIZE_ERROR", e.localizedMessage, null)
        }
    }

    private fun disableAutoRequesting(adType: String?, placementId: String?, result: Result) {
        if (adType.equals("rewarded", ignoreCase = true)) {
            if (placementId != null) {
                Rewarded.disableAutoRequesting(placementId)
            }
            result.success(null)
        } else {
            result.error("INVALID_AD_TYPE", "Invalid ad type for disableAutoRequesting", null)
        }
    }

    private fun disposeAll() {
        Banner.setBannerListener(null)
        Rewarded.setRewardedListener(null)
    }

    private fun initializeRewarded(placementId: String?, result: Result) {
        if (placementId != null) {
            setRewardedAdListener()
            Rewarded.request(placementId)
        }
        result.success("REWARDED_AD_INITIALIZED")
    }

    private fun requestRewarded(placementId: String?, result: Result) {
        if (placementId != null) {
            Rewarded.request(placementId)
        }
        result.success("REWARDED_AD_REQUESTED")
    }

    private fun showRewarded(placementId: String?, result: Result) {

        if (placementId != null && Rewarded.isAvailable(placementId)) {
            activity?.let { Rewarded.show(placementId, it) }
            result.success("REWARDED_AD_SHOWING")
        } else {
            result.error("UNAVAILABLE", "Rewarded ad is not available", null)
        }
    }

    private fun isRewardedAvailable(placementId: String?, result: Result) {
        result.success(placementId?.let { Rewarded.isAvailable(it) })
    }

    private fun setRewardedAdListener() {
        Rewarded.setRewardedListener(object : RewardedListener {
            override fun onShow(placementId: String, impressionData: ImpressionData) {
                channel.invokeMethod("onRewardedShow", createArguments(placementId, impressionData))
            }

            override fun onShowFailure(placementId: String, impressionData: ImpressionData) {
                channel.invokeMethod("onRewardedShowFail", createArguments(placementId, impressionData))
            }

            override fun onClick(placementId: String) {
                channel.invokeMethod("onRewardedClick", createArguments(placementId, null))
            }

            override fun onHide(placementId: String) {
                channel.invokeMethod("onRewardedDismiss", createArguments(placementId, null))
            }

            override fun onAvailable(placementId: String) {
                channel.invokeMethod("onRewardedAvailable", createArguments(placementId, null))
            }

            override fun onUnavailable(placementId: String) {
                channel.invokeMethod("onRewardedUnavailable", createArguments(placementId, null))
            }

            override fun onCompletion(placementId: String, userRewarded: Boolean) {
                val args = createArguments(placementId, null).toMutableMap().apply {
                    put("userRewarded", userRewarded)
                }
                channel.invokeMethod("onRewardedComplete", args)
            }

            override fun onRequestStart(placementId: String, requestId: String) {
                val args = createArguments(placementId, null).toMutableMap().apply {
                    put("requestId", requestId)
                }
                channel.invokeMethod("onRewardedWillRequest", args)
            }
        })
    }

    private fun disposeRewarded(result: Result) {
        Rewarded.setRewardedListener(null)
        result.success("DISPOSED_REWARDED_AD")
    }

    private fun initializeBanner(placementId: String?, result: Result) {
        setAdBannerListener()
        val options = BannerOptions().withSize(BannerSize.MREC)
        activity?.let {
            if (placementId != null) {
                Banner.show(placementId, options, it)
            }
        }
        result.success("BANNER_AD_INITIALIZED")
    }

    private fun requestAdBanner(placementId: String?, result: Result) {
        val options = BannerOptions().withSize(BannerSize.MREC)

        activity?.let {
            if (placementId != null) {
                Banner.show(placementId, options, it)
            }
        }
        result.success("SHOWING_BANNER_AD")
    }

    private fun showAdBanner(placementId: String?, result: Result) {
        val options = BannerOptions().withSize(BannerSize.MREC)
        activity?.let {
            if (placementId != null) {
                Banner.show(placementId, options, it)
            }
        }
        result.success("SHOWING_BANNER_AD")
    }

    private fun hideAdBanner(placementId: String?, result: Result) {
        if (placementId != null) {
            Banner.hide(placementId)
        }
        result.success("HIDING_BANNER_AD")
    }

    private fun setAdBannerListener() {
        Banner.setBannerListener(object : BannerListener {
            override fun onError(placementId: String, error: BannerError) {
                val args = mapOf(
                    "placementId" to placementId,
                    "error" to error.toString()
                )
                channel.invokeMethod("onBannerError", args)
            }

            override fun onLoad(placementId: String) {
                channel.invokeMethod("onBannerLoad", createArguments(placementId, null))
            }

            override fun onShow(placementId: String, impressionData: ImpressionData) {
                channel.invokeMethod("onBannerShow", createArguments(placementId, impressionData))
            }

            override fun onClick(placementId: String) {
                channel.invokeMethod("onBannerClick", createArguments(placementId, null))
            }

            override fun onRequestStart(placementId: String, requestId: String) {
                val args = mapOf(
                    "placementId" to placementId,
                    "requestId" to requestId
                )
                channel.invokeMethod("onBannerRequestStart", args)
            }
        })
    }

    private fun destroyAdBanner(placementId: String?, result: Result) {
        if (placementId != null) {
            Banner.destroy(placementId)
        }
        Banner.setBannerListener(null)
        result.success("DESTROYING_BANNER_AD")
    }

    private fun createArguments(placementId: String, impressionData: ImpressionData?): Map<String, Any> {
        return mutableMapOf<String, Any>().apply {
            put("placementId", placementId)
            impressionData?.let { put("impressionData", it.jsonString) }
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        // Register the banner view factory
        viewRegistry.registerViewFactory(
            "digital_turbine_banner_view",
            BannerViewFactory(binaryMessenger, activity!!)
        )
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
        disposeAll()
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}