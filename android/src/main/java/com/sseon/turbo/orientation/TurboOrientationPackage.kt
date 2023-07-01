package com.sseon.turbo.orientation;

import com.facebook.react.TurboReactPackage
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.module.model.ReactModuleInfo
import com.facebook.react.module.model.ReactModuleInfoProvider

class TurboOrientationPackage : TurboReactPackage() {
    override fun getModule(name: String?, reactContext: ReactApplicationContext): NativeModule? =
        if (name == TurboOrientationModule.NAME) {
            TurboOrientationModule(reactContext)
        } else {
            null
        }

    override fun getReactModuleInfoProvider() = ReactModuleInfoProvider {
        mapOf(
            TurboOrientationModule.NAME to ReactModuleInfo(
                TurboOrientationModule.NAME,
                TurboOrientationModule.NAME,
                false, // canOverrideExistingModule
                false, // needsEagerInit
                true, // hasConstants
                false, // isCxxModule
                true // isTurboModule
            )
        )
    }
}
