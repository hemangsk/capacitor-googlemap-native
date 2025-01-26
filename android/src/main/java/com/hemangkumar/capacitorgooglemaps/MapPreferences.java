package com.hemangkumar.capacitorgooglemaps;

import androidx.annotation.Nullable;

import com.getcapacitor.JSObject;
import com.google.android.gms.maps.GoogleMapOptions;

public class MapPreferences {
    public MapPreferencesGestures gestures;
    public MapPreferencesControls controls;
    public MapPreferencesAppearance appearance;
    public Integer minZoom;
    public Integer maxZoom;

    public MapPreferences() {
        this.gestures = new MapPreferencesGestures();
        this.controls = new MapPreferencesControls();
        this.appearance = new MapPreferencesAppearance();
    }

    public void updateFromJSObject(@Nullable JSObject preferences) {
        if (preferences != null) {
            // update gestures
            JSObject gesturesObject = preferences.getJSObject("gestures");
            this.gestures.updateFromJSObject(gesturesObject);
            // update controls
            JSObject controlsObject = preferences.getJSObject("controls");
            this.controls.updateFromJSObject(controlsObject);
            // update appearance
            JSObject appearanceObject = preferences.getJSObject("appearance");
            this.appearance.updateFromJSObject(appearanceObject);
            // update zoom
            this.minZoom = preferences.getInteger("minZoom", 1);
            this.maxZoom = preferences.getInteger("maxZoom", 21);
        }
    }

    public GoogleMapOptions generateGoogleMapOptions() {
        GoogleMapOptions googleMapOptions = new GoogleMapOptions();

        // set gestures
        if (this.gestures != null) {
            googleMapOptions.rotateGesturesEnabled(gestures.getBoolean(MapPreferencesGestures.ROTATE_ALLOWED_KEY));
            googleMapOptions.scrollGesturesEnabled(gestures.getBoolean(MapPreferencesGestures.SCROLL_ALLOWED_KEY));
            googleMapOptions.scrollGesturesEnabledDuringRotateOrZoom(gestures.getBoolean(MapPreferencesGestures.SCROLL_ALLOWED_DURING_ROTATE_OR_ZOOM_KEY));
            googleMapOptions.tiltGesturesEnabled(gestures.getBoolean(MapPreferencesGestures.TILT_ALLOWED_KEY));
            googleMapOptions.zoomGesturesEnabled(gestures.getBoolean(MapPreferencesGestures.ZOOM_ALLOWED_KEY));
        }

        // set controls
        if (this.controls != null) {
            googleMapOptions.compassEnabled(controls.getBoolean(MapPreferencesControls.COMPASS_BUTTON_KEY));
            googleMapOptions.mapToolbarEnabled(controls.getBoolean(MapPreferencesControls.MAP_TOOLBAR_KEY));
            googleMapOptions.zoomControlsEnabled(controls.getBoolean(MapPreferencesControls.ZOOM_BUTTONS_KEY));

            // controls.isIndoorLevelPickerEnabled can only be set through `UiSettings`
            // controls.isMyLocationButtonEnabled can only be set through `UiSettings`
        }

        // set appearance
        if (this.appearance != null) {
            // set mapType
            googleMapOptions.mapType(this.appearance.type);

            // appearance.style can only be set through `GoogleMap`
            // appearance.isIndoorShown can only be set through `GoogleMap`
            // appearance.isBuildingsShown can only be set through `GoogleMap`
            // appearance.isMyLocationDotShown can only be set through `GoogleMap`
            // appearance.isTrafficShown can only be set through `GoogleMap`
        }

        return googleMapOptions;
    }
}
