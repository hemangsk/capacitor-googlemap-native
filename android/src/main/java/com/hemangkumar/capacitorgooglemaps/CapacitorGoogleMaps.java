package com.hemangkumar.capacitorgooglemaps;

import android.Manifest;
import android.annotation.SuppressLint;
import android.graphics.Color;
import android.graphics.Rect;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import com.getcapacitor.JSArray;
import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.getcapacitor.annotation.Permission;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.VisibleRegion;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.UUID;

@CapacitorPlugin(
        name = "CapacitorGoogleMaps",
        permissions = {
                @Permission(
                        strings = { Manifest.permission.ACCESS_COARSE_LOCATION, Manifest.permission.ACCESS_FINE_LOCATION },
                        alias = "location"
                ),
        }
)
public class CapacitorGoogleMaps extends Plugin implements CustomMapViewEvents {
    private final HashMap<String, CustomMapView> customMapViews = new HashMap<>();
    Float devicePixelRatio;
    private String lastEventChainId;
    public List<MotionEvent> previousEvents = new ArrayList<>();
    private String delegateTouchEventsToMapId;

    @PluginMethod()
    public void elementFromPointResult(PluginCall call) {
        // This method should be called after we requested the WebView through notifyListeners("didRequestElementFromPoint").
        // It should tell us if the exact point that was being touched, is from an element in which a MapView exists.
        // Otherwise it is a 'normal' HTML element, and we should thus not delegate touch events.
        String eventChainId = call.getString("eventChainId");
        if (eventChainId != null && eventChainId.equals(lastEventChainId)) {
            Boolean isSameNode = call.getBoolean("isSameNode", false);
            if (isSameNode != null && isSameNode) {
                // The WebView apparently has decides the touched point belongs to a certain MapView.
                // Now we should find out which one exactly.
                String mapId = call.getString("mapId");
                if (mapId != null) {
                    delegateTouchEventsToMapId = mapId;
                }
            }
        }
        call.resolve();
    }

    @SuppressLint("ClickableViewAccessibility")
    @Override
    public void load() {
        super.load();

        MapsInitializer.initialize(getContext(), MapsInitializer.Renderer.LATEST, null);

        this.getBridge().getWebView().setOnTouchListener(new View.OnTouchListener() {
            @Override
            public boolean onTouch(View view, MotionEvent event) {
                int touchType = event.getActionMasked();

                if (touchType == MotionEvent.ACTION_DOWN) {
                    // Throw away all previous state when starting a new touch gesture.
                    // The framework may have dropped the up or cancel event for the previous gesture
                    // due to an app switch, ANR, or some other state change.
                    delegateTouchEventsToMapId = null;
                    previousEvents.clear();

                    // Initialize JSObjects for resolve().
                    JSObject result = new JSObject();
                    JSObject point = new JSObject();

                    // Generate a UUID, and assign it to lastId.
                    // This way we can make sure we are always referencing the last chain of events.
                    lastEventChainId = UUID.randomUUID().toString();
                    // Then add it to result object, so the WebView can reference the correct events when needed.
                    result.put("eventChainId", lastEventChainId);

                    // Get the touched position.
                    int x = (int) event.getX();
                    int y = (int) event.getY();

                    // Since pixels on a webpage are calculated differently, should convert them first.
                    // Convert it to 'real' pixels in WebView by using devicePixelRatio.
                    if (devicePixelRatio != null && devicePixelRatio > 0) {
                        point.put("x", x / devicePixelRatio);
                        point.put("y", y / devicePixelRatio);

                        // Then add it to result object.
                        result.put("point", point);
                    }

                    // Then notify the listener that we request to let the WebView determine
                    // if the element touched is the same node as where some MapView is attached to.
                    notifyListeners("didRequestElementFromPoint", result);
                }

                if (delegateTouchEventsToMapId != null) {
                    CustomMapView customMapView = customMapViews.get(delegateTouchEventsToMapId);
                    if (customMapView != null) {
                        // Apparently, all touch events should be delegated to a specific MapView.

                        // If previous events exist, we should execute those first
                        if (previousEvents.size() > 0) {
                            for (int i = 0; i < previousEvents.size(); i++) {
                                MotionEvent e = previousEvents.get(i);
                                if (e != null) {
                                    // Delegate this previous event to the MapView.
                                    dispatchTouchEvent(e, customMapView);
                                }
                            }
                            // Since we delegated all previous events, we can now forget about them.
                            previousEvents.clear();
                        }

                        // Finally delegate the current event to the MapView.
                        dispatchTouchEvent(event, customMapView);
                    }
                } else {
                    // If delegateTouchEventsToMapId is not set, but it could still be set later!
                    // So we should save all past events.
                    // That way we can still execute them later on.
                    // It is important that we use MotionEvent.obtain() to copy the event first.
                    // Otherwise the event does not work properly when delegating it later on.
                    MotionEvent clonedEvent = MotionEvent.obtain(event);
                    previousEvents.add(clonedEvent);
                }

                return false;
            }
        });
    }

    private void dispatchTouchEvent(MotionEvent event, CustomMapView customMapView) {
        Rect offsetViewBounds = new Rect();
        // returns the visible bounds
        customMapView.mapView.getDrawingRect(offsetViewBounds);
        // calculates the relative coordinates to the parent
        ViewGroup parentViewGroup = (ViewGroup) bridge.getWebView().getParent();
        parentViewGroup.offsetDescendantRectToMyCoords(customMapView.mapView, offsetViewBounds);

        int relativeTop = offsetViewBounds.top;
        int relativeLeft = offsetViewBounds.left;

        // Set location with offset points,
        // because if a map is positioned with a different top and left point than the WebView,
        // that should be accounted for.
        event.setLocation(event.getX() - relativeLeft, event.getY() - relativeTop);

        customMapView.mapView.dispatchTouchEvent(event);
    }

    @Override
    protected void handleOnStart() {
        super.handleOnStart();
        for (CustomMapView customMapView : customMapViews.values()) {
            if (customMapView != null) {
                customMapView.handleOnStart();
            }
        }
    }

    @Override
    protected void handleOnResume() {
        super.handleOnResume();
        for (CustomMapView customMapView : customMapViews.values()) {
            if (customMapView != null) {
                customMapView.handleOnResume();
            }
        }
    }

    @Override
    protected void handleOnPause() {
        for (CustomMapView customMapView : customMapViews.values()) {
            if (customMapView != null) {
                customMapView.handleOnPause();
            }
        }
        super.handleOnPause();
    }

    @Override
    protected void handleOnStop() {
        super.handleOnStop();
        for (CustomMapView customMapView : customMapViews.values()) {
            if (customMapView != null) {
                customMapView.handleOnStop();
            }
        }
    }

    @Override
    protected void handleOnDestroy() {
        for (CustomMapView customMapView : customMapViews.values()) {
            if (customMapView != null) {
                customMapView.handleOnDestroy();
            }
        }
        super.handleOnDestroy();
    }

    @PluginMethod()
    public void initialize(PluginCall call) {
        /*
         *  TODO: Check API key
         */
        devicePixelRatio = call.getFloat("devicePixelRatio");
        call.resolve();
    }

    @PluginMethod()
    public void createMap(final PluginCall call) {
        final CapacitorGoogleMaps ctx = this;

        bridge.saveCall(call);
        final String callbackId = call.getCallbackId();

        final BoundingRect boundingRect = new BoundingRect();
        boundingRect.updateFromJSObject(call.getObject("boundingRect"));

        final MapCameraPosition mapCameraPosition = new MapCameraPosition();
        mapCameraPosition.updateFromJSObject(call.getObject("cameraPosition"), null);

        final MapPreferences mapPreferences = new MapPreferences();
        mapPreferences.updateFromJSObject(call.getObject("preferences"));

        getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                CustomMapView customMapView = new CustomMapView(getActivity(), ctx);

                customMapViews.put(customMapView.getId(), customMapView);

                customMapView.createMap(callbackId, boundingRect, mapCameraPosition, mapPreferences);

                customMapView.addToView(((ViewGroup) bridge.getWebView().getParent()));

                // Bring the WebView in front of the MapView
                // This allows us to overlay the MapView in HTML/CSS
                bridge.getWebView().bringToFront();

                // Hide the background
                bridge.getWebView().setBackgroundColor(Color.TRANSPARENT);
                bridge.getWebView().loadUrl("javascript:document.documentElement.style.backgroundColor = 'transparent';void(0);");
            }
        });
    }

    @PluginMethod()
    public void updateMap(final PluginCall call) {
        final String mapId = call.getString("mapId");

        getBridge().getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                CustomMapView customMapView = customMapViews.get(mapId);

                if (customMapView != null) {
                    final MapPreferences mapPreferences = customMapView.mapPreferences;
                    mapPreferences.updateFromJSObject(call.getObject("preferences"));

                    JSObject result = customMapView.invalidateMap();

                    call.resolve(result);
                } else {
                    call.reject("updateMap: map not found, mapId: " + mapId);
                }
            }
        });
    }

    @PluginMethod()
    public void getMap(final PluginCall call) {
        final String mapId = call.getString("mapId");

        getBridge().getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                CustomMapView customMapView = customMapViews.get(mapId);

                if (customMapView != null) {
                    JSObject result = customMapView.getMap();

                    call.resolve(result);
                } else {
                    call.reject("getMap: map not found, mapId: " + mapId);
                }
            }
        });
    }

    @PluginMethod(returnType = PluginMethod.RETURN_NONE)
    public void removeMap(final PluginCall call) {
        final String mapId = call.getString("mapId");

        getBridge().getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                CustomMapView customMapView = customMapViews.get(mapId);

                if (customMapView != null) {
                    customMapView.removeFromView(((ViewGroup) bridge.getWebView().getParent()));
                    customMapViews.remove(mapId);
                    call.resolve();
                } else {
                    call.reject("removeMap: map not found, mapId: " + mapId);
                }
            }
        });
    }

    @PluginMethod(returnType = PluginMethod.RETURN_NONE)
    public void clearMap(final PluginCall call) {
        final String mapId = call.getString("mapId");
        final boolean hide = Boolean.TRUE.equals(call.getBoolean("hide", false));

        getBridge().getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                CustomMapView customMapView = customMapViews.get(mapId);

                if (customMapView != null) {
                    customMapView.clear(hide);
                    call.resolve();
                } else {
                    call.reject("clearMap: map not found, mapId: " + mapId);
                }
            }
        });
    }

    @PluginMethod
    public void moveCamera(final PluginCall call) {
        final String mapId = call.getString("mapId");

        getBridge().getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                CustomMapView customMapView = customMapViews.get(mapId);

                if (customMapView != null) {
                    final MapCameraPosition mapCameraPosition = customMapView.mapCameraPosition;

                    CameraPosition currentCameraPosition = null;

                    Boolean useCurrentCameraPositionAsBase = call.getBoolean("useCurrentCameraPositionAsBase", true);

                    if (useCurrentCameraPositionAsBase != null && useCurrentCameraPositionAsBase) {
                        currentCameraPosition = customMapView.getCameraPosition();
                    }

                    mapCameraPosition.updateFromJSObject(call.getObject("cameraPosition"), currentCameraPosition);

                    Integer duration = call.getInt("duration", 0);

                    customMapView.moveCamera(duration);

                    call.resolve();
                } else {
                    call.reject("moveCamera: map not found, mapId: " + mapId);
                }
            }
        });
    }

    @PluginMethod()
    public void getRegionInfo(final PluginCall call) {
        final String mapId = call.getString("mapId");

        getBridge().getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                CustomMapView customMapView = customMapViews.get(mapId);

                if (customMapView != null) {
                    VisibleRegion region = customMapView.googleMap.getProjection().getVisibleRegion();

                    JSObject topLeft = new JSObject();
                    JSObject topRight = new JSObject();
                    JSObject bottomLeft = new JSObject();
                    JSObject bottomRight = new JSObject();

                    topLeft.put("latitude", region.latLngBounds.northeast.latitude);
                    topLeft.put("longitude", region.latLngBounds.southwest.longitude);

                    topRight.put("latitude", region.latLngBounds.northeast.latitude);
                    topRight.put("longitude", region.latLngBounds.northeast.longitude);

                    bottomLeft.put("latitude", region.latLngBounds.southwest.latitude);
                    bottomLeft.put("longitude", region.latLngBounds.southwest.longitude);

                    bottomRight.put("latitude", region.latLngBounds.southwest.latitude);
                    bottomRight.put("longitude", region.latLngBounds.northeast.longitude);

                    JSObject bounds = new JSObject();
                    bounds.put("topLeft", topLeft);
                    bounds.put("topRight", topRight);
                    bounds.put("bottomLeft", bottomLeft);
                    bounds.put("bottomRight", bottomRight);

                    JSObject center = new JSObject();
                    center.put("latitude", region.latLngBounds.getCenter().latitude);
                    center.put("longitude", region.latLngBounds.getCenter().longitude);

                    CameraPosition camera = customMapView.googleMap.getCameraPosition();
                    JSObject result = new JSObject();
                    result.put("bounds", bounds);
                    result.put("center", center);
                    result.put("zoom", camera.zoom);

                    call.resolve(result);
                } else {
                    call.reject("getRegionInfo: map not found, mapId: " + mapId);
                }
            }
        });
    }

    @Override
    public void onMapReady(String callbackId, JSObject result) {
        PluginCall call = bridge.getSavedCall(callbackId);
        call.resolve(result);
        bridge.releaseCall(call);
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void didTapInfoWindow(final PluginCall call) {
        setCallbackIdForEvent(call, CustomMapView.EVENT_DID_TAP_INFO_WINDOW);
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void didCloseInfoWindow(final PluginCall call) {
        setCallbackIdForEvent(call, CustomMapView.EVENT_DID_CLOSE_INFO_WINDOW);
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void didTapMap(final PluginCall call) {
        setCallbackIdForEvent(call, CustomMapView.EVENT_DID_TAP_MAP);
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void didLongPressMap(final PluginCall call) {
        setCallbackIdForEvent(call, CustomMapView.EVENT_DID_LONG_PRESS_MAP);
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void didTapMarker(final PluginCall call) {
        setCallbackIdForEvent(call, CustomMapView.EVENT_DID_TAP_MARKER);
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void didBeginDraggingMarker(final PluginCall call) {
        setCallbackIdForEvent(call, CustomMapView.EVENT_DID_BEGIN_DRAGGING_MARKER);
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void didDragMarker(final PluginCall call) {
        setCallbackIdForEvent(call, CustomMapView.EVENT_DID_DRAG_MARKER);
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void didEndDraggingMarker(final PluginCall call) {
        setCallbackIdForEvent(call, CustomMapView.EVENT_DID_END_DRAGGING_MARKER);
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void didTapMyLocationButton(final PluginCall call) {
        setCallbackIdForEvent(call, CustomMapView.EVENT_DID_TAP_MY_LOCATION_BUTTON);
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void didTapMyLocationDot(final PluginCall call) {
        setCallbackIdForEvent(call, CustomMapView.EVENT_DID_TAP_MY_LOCATION_DOT);
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void didTapPoi(final PluginCall call) {
        setCallbackIdForEvent(call, CustomMapView.EVENT_DID_TAP_POI);
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void didBeginMovingCamera(final PluginCall call) {
        setCallbackIdForEvent(call, CustomMapView.EVENT_DID_BEGIN_MOVING_CAMERA);
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void didMoveCamera(final PluginCall call) {
        setCallbackIdForEvent(call, CustomMapView.EVENT_DID_MOVE_CAMERA);
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void didEndMovingCamera(final PluginCall call) {
        setCallbackIdForEvent(call, CustomMapView.EVENT_DID_END_MOVING_CAMERA);
    }

    public void setCallbackIdForEvent(final PluginCall call, final String eventName) {
        call.setKeepAlive(true);
        final String callbackId = call.getCallbackId();
        String mapId = call.getString("mapId");

        final CustomMapView customMapView = customMapViews.get(mapId);

        if (customMapView != null) {
            final Boolean preventDefault = call.getBoolean("preventDefault", false);


            getBridge().getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    customMapView.setCallbackIdForEvent(callbackId, eventName, preventDefault);
                }
            });
        }
    }

    @Override
    public void resultForCallbackId(String callbackId, JSObject result) {
        PluginCall call = bridge.getSavedCall(callbackId);
        call.resolve(result);
    }

    @PluginMethod()
    public void addMarker(final PluginCall call) {
        final String mapId = call.getString("mapId");

        getBridge().getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                CustomMapView customMapView = customMapViews.get(mapId);

                if (customMapView != null) {
                    CustomMarker customMarker = new CustomMarker();
                    customMarker.updateFromJSObject(call.getData());

                    customMapView.addMarker(
                        customMarker,
                        (Marker marker) -> {
                            call.resolve(CustomMarker.getResultForMarker(marker, mapId));
                        }
                    );
                } else {
                    call.reject("addMarker: map not found, mapId: " + mapId);
                }
            }
        });
    }

    @PluginMethod()
    public void addMarkers(final PluginCall call) {
        final String mapId = call.getString("mapId");
        CustomMapView customMapView = customMapViews.get(mapId);
        if (customMapView == null) {
            call.reject("addMarkers: map not found, mapId: " + mapId);
            return;
        }
        try {
            final JSArray jsMarkers = call.getArray("markers", new JSArray());
            MarkersAppender appender = new MarkersAppender();
            appender.addMarkers(customMapView, jsMarkers, getBridge().getActivity(), call::resolve);
        } catch (MarkersAppender.AppenderException e) {
            call.reject("exception in addMarkers", e);
        }
    }

    @PluginMethod(returnType = PluginMethod.RETURN_NONE)
    public void removeMarker(final PluginCall call) {
        final String mapId = call.getString("mapId");

        getBridge().getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                CustomMapView customMapView = customMapViews.get(mapId);

                if (customMapView != null) {
                    final String markerId = call.getString("markerId");

                    customMapView.removeMarker(markerId);

                    call.resolve();
                } else {
                    call.reject("removeMarker: map not found, mapId: " + mapId);
                }
            }
        });
    }

    @PluginMethod()
    public void addPolygon(final PluginCall call) {
        final String mapId = call.getString("mapId");

        getBridge().getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                CustomMapView customMapView = customMapViews.get(mapId);

                if (customMapView != null) {
                    CustomPolygon customPolygon = new CustomPolygon();
                    customPolygon.updateFromJSObject(call.getData());

                    customMapView.addPolygon(customPolygon, (polygon) -> {
                        call.resolve(customPolygon.getResultForPolygon(polygon, mapId));
                    });
                } else {
                    call.reject("addPolygon: map not found, mapId: " + mapId);
                }
            }
        });
    }

    @PluginMethod(returnType = PluginMethod.RETURN_NONE)
    public void removePolygon(final PluginCall call) {
        final String mapId = call.getString("mapId");

        getBridge().getActivity().runOnUiThread(new Runnable() {
            @Override
            public void run() {
                CustomMapView customMapView = customMapViews.get(mapId);

                if (customMapView != null) {
                    final String polygonId = call.getString("polygonId");

                    customMapView.removePolygon(polygonId);

                    call.resolve();
                } else {
                    call.reject("removePolygon: map not found, mapId: " + mapId);
                }
            }
        });
    }
}
