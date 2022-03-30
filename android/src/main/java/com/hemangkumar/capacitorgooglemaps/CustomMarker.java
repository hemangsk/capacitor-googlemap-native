package com.hemangkumar.capacitorgooglemaps;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.getcapacitor.JSObject;
import com.getcapacitor.util.JSONUtils;
import com.google.android.libraries.maps.GoogleMap;
import com.google.android.libraries.maps.model.BitmapDescriptor;
import com.google.android.libraries.maps.model.LatLng;
import com.google.android.libraries.maps.model.Marker;
import com.google.android.libraries.maps.model.MarkerOptions;

import org.json.JSONObject;

import java.util.UUID;

public class CustomMarker {
    // generate id for the just added marker,
    // put this marker into a hashmap with the corresponding id,
    // so we can retrieve the marker by id later on
    public String markerId = UUID.randomUUID().toString();

    private final MarkerOptions markerOptions = new MarkerOptions();
    private JSObject tag = new JSObject();

    public void updateFromJSObject(JSObject marker, @Nullable BitmapDescriptor icon) {
        final JSObject position = JSObjectDefaults.getJSObjectSafe(marker, "position", new JSObject());
        final Double latitude = JSObjectDefaults.getDoubleSafe(position, "latitude", 0d);
        final Double longitude = JSObjectDefaults.getDoubleSafe(position, "longitude", 0d);
        LatLng latLng = new LatLng(latitude, longitude);

        final JSObject preferences = JSObjectDefaults.getJSObjectSafe(marker, "preferences", new JSObject());
        final String title = preferences.getString("title", "");
        final String snippet = preferences.getString("snippet", "");
        final Float opacity = JSObjectDefaults.getFloatSafe(preferences, "opacity", 1f);
        final Boolean isFlat = JSObjectDefaults.getBooleanSafe(preferences,"isFlat", false);
        final Boolean isDraggable = JSObjectDefaults.getBooleanSafe(preferences,"isDraggable", false);
        final Integer zIndex = JSObjectDefaults.getIntegerSafe(preferences,"zIndex", 0);

        final JSObject anchor = JSObjectDefaults.getJSObjectSafe(preferences, "anchor", new JSObject());
        final Float anchorX = JSObjectDefaults.getFloatSafe(anchor, "x", 0.5f);
        final Float anchorY = JSObjectDefaults.getFloatSafe(anchor, "y", 1f);

        this.markerOptions.position(latLng);
        this.markerOptions.title(title);
        this.markerOptions.snippet(snippet);
        this.markerOptions.alpha(opacity);
        this.markerOptions.flat(isFlat);
        this.markerOptions.draggable(isDraggable);
        this.markerOptions.zIndex(zIndex);
        this.markerOptions.anchor(anchorX, anchorY);
        if (icon != null) {
            this.markerOptions.icon(icon);
        }
        this.setMetadata(JSObjectDefaults.getJSObjectSafe(preferences, "metadata", new JSObject()));
    }

    public Marker addToMap(GoogleMap googleMap) {
        Marker marker = googleMap.addMarker(this.markerOptions);
        marker.setTag(this.tag);
        return marker;
    }

    private void setMetadata(@NonNull JSObject jsObject) {
        JSObject tag = new JSObject();
        // set id to tag
        tag.put("markerId", this.markerId);
        // set anchor to tag (because it cannot be retrieved from a marker instance)
        JSObject anchorResult = new JSObject();
        anchorResult.put("x", this.markerOptions.getAnchorU());
        anchorResult.put("y", this.markerOptions.getAnchorV());
        tag.put("anchor", anchorResult);
        // then set metadata to tag
        tag.put("metadata", jsObject);
        // save in tag variable
        this.tag = tag;
    }

    public static JSObject getResultForMarker(Marker marker, String mapId) {
        JSObject tag = null;

        try {
            tag = (JSObject) marker.getTag();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            tag = tag != null ? tag : new JSObject();
        }

        // initialize JSObjects to return
        JSObject result = new JSObject();
        JSObject markerResult = new JSObject();
        JSObject positionResult = new JSObject();
        JSObject preferencesResult = new JSObject();

        result.put("marker", markerResult);
        markerResult.put("position", positionResult);
        markerResult.put("preferences", preferencesResult);

        // get map id
        markerResult.put("mapId", mapId);

        // get id
        String markerId = tag.optString("markerId", marker.getId());
        markerResult.put("markerId", markerId);

        // get position values
        positionResult.put("latitude", marker.getPosition().latitude);
        positionResult.put("longitude", marker.getPosition().longitude);

        // get preferences
        preferencesResult.put("title", marker.getTitle());
        preferencesResult.put("snippet", marker.getSnippet());
        preferencesResult.put("opacity", marker.getAlpha());
        preferencesResult.put("isFlat", marker.isFlat());
        preferencesResult.put("isDraggable", marker.isDraggable());
        preferencesResult.put("zIndex", marker.getZIndex());
        // anchor values
        JSObject anchorResult = JSObjectDefaults.getJSObjectSafe(tag, "anchor", new JSObject());
        preferencesResult.put("anchor", anchorResult);
        // metadata
        JSObject metadata = JSObjectDefaults.getJSObjectSafe(tag, "metadata", new JSObject());
        preferencesResult.put("metadata", metadata);

        return result;
    }

}
