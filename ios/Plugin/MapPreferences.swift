import Capacitor

class MapPreferences {
    public var gestures: MapPreferencesGestures!
    public var controls: MapPreferencesControls!
    public var appearance: MapPreferencesAppearance!
    public var minZoom: Float!
    public var maxZoom: Float!

    public init() {
        self.gestures = MapPreferencesGestures();
        self.controls = MapPreferencesControls();
        self.appearance = MapPreferencesAppearance();
    }

    open func updateFromJSObject(_ preferences: JSObject!) {
        if preferences != nil {
            //  update gestures
            let gesturesObject: JSObject! = preferences["gestures"] as? JSObject ?? JSObject();
            self.gestures.updateFromJSObject(object: gesturesObject);
            //  update controls
            let controlsObject: JSObject! = preferences["controls"] as? JSObject ?? JSObject();
            self.controls.updateFromJSObject(object: controlsObject);
            //  update appearance
            let appearanceObject: JSObject! = preferences["appearance"] as? JSObject ?? JSObject();
            self.appearance.updateFromJSObject(object: appearanceObject);
            //  update zoom
            self.minZoom = preferences["minZoom"] as? Float ?? 1.0;
            self.maxZoom = preferences["maxZoom"] as? Float ?? 21.0;
        }
    }
}
