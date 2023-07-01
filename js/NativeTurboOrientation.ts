import type { TurboModule } from 'react-native/Libraries/TurboModule/RCTExport';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
    lock(orientation: string): void;
    toggleHomeIndicatorOrSinkStatusBar(on: boolean): void;
    toggleNativeObserver(on: boolean): void;
    addListener(event: string): void;
    removeListeners(count: number): void;
}
export default TurboModuleRegistry.get<Spec>('RTNTurboOrientation') as Spec | null;
