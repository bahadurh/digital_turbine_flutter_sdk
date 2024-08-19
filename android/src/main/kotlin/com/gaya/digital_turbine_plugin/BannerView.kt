// BannerView.kt
package com.gaya.digital_turbine_plugin

import android.app.Activity
import android.content.Context
import android.view.View
import com.fyber.fairbid.ads.banner.BannerView as FairBidBannerView
import com.fyber.fairbid.ads.banner.BannerListener
import com.fyber.fairbid.ads.banner.BannerOptions
import com.fyber.fairbid.ads.ImpressionData
import com.fyber.fairbid.ads.banner.BannerError
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class BannerViewWrapper(
    context: Context,
    private val activity: Activity,
    viewId: Int,
    creationParams: Map<String, Any>?,
    messenger: BinaryMessenger
) : PlatformView, MethodChannel.MethodCallHandler {

    private val bannerView: FairBidBannerView
    private val methodChannel: MethodChannel
    private val placementId: String

    init {
        placementId = creationParams?.get("placementId") as? String ?: ""
        bannerView = FairBidBannerView(context, placementId)
        methodChannel = MethodChannel(messenger, "digital_turbine_banner_view_1")
        methodChannel.setMethodCallHandler(this)
        setupBannerListener()
    }

    override fun getView(): View = bannerView

    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
        bannerView.destroy()
    }

    override fun onMethodCall(call : MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "loadAd" -> {
                loadAd()
                result.success(null)
            }
            "disposeAd" -> {
                dispose()
                result.success("BANNER_DISPOSED")
            }
            else -> result.notImplemented()
        }
    }

    private fun setupBannerListener() {
        bannerView.bannerListener = object : BannerListener {
            override fun onError(placementId: String, error: BannerError) {
                val args = mapOf(
                    "placementId" to placementId,
                    "error" to error.toString()
                )
                methodChannel.invokeMethod("onBannerError", args)
            }

            override fun onLoad(placementId: String) {
                methodChannel.invokeMethod("onBannerLoad", mapOf("placementId" to placementId))
            }

            override fun onShow(placementId: String, impressionData: ImpressionData) {
                methodChannel.invokeMethod("onBannerShow", mapOf(
                    "placementId" to placementId,
                    "impressionData" to impressionData.jsonString
                ))
            }

            override fun onClick(placementId: String) {
                methodChannel.invokeMethod("onBannerClick", mapOf("placementId" to placementId))
            }

            override fun onRequestStart(placementId: String, requestId: String) {
                val args = mapOf(
                    "placementId" to placementId,
                    "requestId" to requestId
                )
                methodChannel.invokeMethod("onBannerRequestStart", args)
            }
        }
    }

    private fun loadAd() {
        val options = BannerOptions()
        bannerView.load(options)
    }
}
