import NativeTurboOrientation from './NativeTurboOrientation'
import { NativeEventEmitter } from 'react-native';

const Emitter = new NativeEventEmitter(NativeTurboOrientation as any);
const EventName = 'TURBO_ORIENTATION';

export type Orientation = 'All' | 'Portrait' | 'PortraitUpsideDown' | 'LandscapeLeft' | 'LandscapeRight' | 'Landscape'

const TurboOrientation = {
    lock: (orientation: Orientation) => {
        NativeTurboOrientation?.lock(orientation as string)
    },
    toggleHomeIndicatorOrSinkStatusBar: (on: boolean) => {
        NativeTurboOrientation?.toggleHomeIndicatorOrSinkStatusBar(on);
    },
    toggleNativeObserver: (on: boolean) => {
        NativeTurboOrientation?.toggleNativeObserver(on);
    },
    addListener(callback: (orientation: Orientation) => void): { remove: any } {
        return Emitter.addListener(EventName, (event) => {
            callback(event.orientation)
        });
    }
}
export default TurboOrientation;