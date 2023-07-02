package com.sseon.turbo.orientation

import android.annotation.SuppressLint
import android.content.pm.ActivityInfo
import android.os.Build
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.view.OrientationEventListener
import android.view.View
import android.view.Window
import android.view.WindowInsets
import android.view.WindowInsetsController
import com.facebook.react.bridge.Arguments
import com.facebook.react.bridge.LifecycleEventListener
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.modules.core.DeviceEventManagerModule
import kotlin.math.abs


class TurboOrientationModule(reactContext: ReactApplicationContext) : NativeTurboOrientationSpec(reactContext), LifecycleEventListener {

    private val UNKNOWN = "Unknown"
    private val ALL = "All"
    private val PORTRAIT = "Portrait"
    private val PORTRAIT_UPSIDE_DOWN = "PortraitUpsideDown"
    private val LANDSCAPE_LEFT = "LandscapeLeft"
    private val LANDSCAPE_RIGHT = "LandscapeRight"
    private val LANDSCAPE = "Landscape"

    private var listener: OrientationEventListener? = null

    private var deviceOrientation = ""
    private var lastOrientationValue = 0

    companion object {
        const val NAME = "RTNTurboOrientation"

        private val JSEVENT = "TURBO_ORIENTATION"
        private var context: ReactApplicationContext? = null

        private fun sendEvent(map: ReadableMap) {
            if (context?.hasActiveReactInstance() == true) {
                context?.getJSModule<DeviceEventManagerModule.RCTDeviceEventEmitter>(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)?.emit(JSEVENT, map)
            }
        }
    }

    init {
        context = reactContext
        reactContext.addLifecycleEventListener(this);
    }

    fun getWindow(): Window? {
        return context?.currentActivity?.window
    }
    
    override fun addListener(event:String?){
        //ignore
    }

    override fun removeListeners(count:Double){
        //ignore
    }

    override fun getName() = NAME

    override fun lock(orientation: String?) {
        val activity = context?.currentActivity;
        if (VERSION.SDK_INT < VERSION_CODES.GINGERBREAD) return
        if (activity != null && orientation != null) {
            var o = -1;
            if (orientation == PORTRAIT) {
                o = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT;
            } else if (orientation == PORTRAIT_UPSIDE_DOWN) {
                o = ActivityInfo.SCREEN_ORIENTATION_REVERSE_PORTRAIT;
            } else if (orientation == LANDSCAPE_RIGHT) {
                o = ActivityInfo.SCREEN_ORIENTATION_REVERSE_LANDSCAPE;
            } else if (orientation == LANDSCAPE_LEFT) {
                o = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE;
            } else if (orientation == LANDSCAPE) {
                o = ActivityInfo.SCREEN_ORIENTATION_SENSOR_LANDSCAPE;
            } else if (orientation == ALL) {
                o = ActivityInfo.SCREEN_ORIENTATION_FULL_SENSOR;
            }
            if (o != -1) activity.requestedOrientation = o;
        }
    }

    override fun toggleHomeIndicatorOrSinkStatusBar(on: Boolean) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val insetsController = getWindow()?.insetsController
            if (insetsController != null) {
                if (on) {
                    insetsController.show(WindowInsets.Type.statusBars() or WindowInsets.Type.navigationBars())
                } else {
                    insetsController.hide(WindowInsets.Type.statusBars() or WindowInsets.Type.navigationBars())
                    insetsController.systemBarsBehavior = WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
                }
            }
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            getWindow()?.decorView?.systemUiVisibility =
                if (on) (View.SYSTEM_UI_FLAG_FULLSCREEN
                        or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                        or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
                        or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                        or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                        or View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY) else View.SYSTEM_UI_FLAG_VISIBLE
        } else {
            // android 4.4 is not supported
        }
    }

    @SuppressLint("NewApi")
    override fun toggleNativeObserver(on: Boolean) {
        if (on && context?.currentActivity != null) {
            listener = object : OrientationEventListener(context?.currentActivity) {
                override fun onOrientationChanged(orientation: Int) {
                    val o: String = calculateOrientation(orientation)
                    if (deviceOrientation != o) {
                        deviceOrientation = o
                        val map = Arguments.createMap()
                        map.putString("orientation", o)
                        sendEvent(map)
                    }
                }
            }
            listener?.enable()
        } else {
            if (listener != null) {
                listener?.disable();
                listener = null;
            }
        }
    }

    override fun onHostResume() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.CUPCAKE) {
            listener?.enable()
        }
    }

    override fun onHostPause() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.CUPCAKE) {
            listener?.disable()
        }
    }

    override fun onHostDestroy() {
        context?.removeLifecycleEventListener(this);
    }

    fun calculateOrientation(v: Int): String {
        /// 0 - 359
        if (v < 0) return UNKNOWN
        if (v < 45 || v > 315) {
            if (deviceOrientation.isEmpty()) {
                lastOrientationValue = v
                return PORTRAIT
            }
            return if (deviceOrientation != PORTRAIT) {
                val diff = abs(v - lastOrientationValue)
                if (diff >= 20) {
                    //角度差值超过20度、当前方向确实改变为ORIENTATION_PORTRAIT
                    lastOrientationValue = v
                    PORTRAIT
                } else {
                    //误报、保持原方向返回
                    deviceOrientation
                }
            } else {
                lastOrientationValue = v
                PORTRAIT
            }
        }
        // [ 315(360 - 45)  <===> 225(360 - 135) ]
        if (v > 225) {
            return LANDSCAPE_LEFT
        }
        // [ 45 <===> 135 ]
        return if (v <= 135) {
            LANDSCAPE_RIGHT
        } else PORTRAIT_UPSIDE_DOWN
    }
}
