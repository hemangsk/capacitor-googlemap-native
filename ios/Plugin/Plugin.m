#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(CapacitorGoogleMaps, "CapacitorGoogleMaps",
           CAP_PLUGIN_METHOD(initialize, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(createMap, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(updateMap, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(clearMap, CAPPluginReturnNone);
           CAP_PLUGIN_METHOD(removeMap, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(moveCamera, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getRegionInfo, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(addMarker, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(addMarkers, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(removeMarker, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(addPolygon, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(removePolygon, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(didTapInfoWindow, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(didCloseInfoWindow, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(didTapMap, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(didLongPressMap, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(didTapMarker, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(didBeginDraggingMarker, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(didDragMarker, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(didEndDraggingMarker, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(didTapMyLocationButton, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(didTapMyLocationDot, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(didTapPoi, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(didBeginMovingCamera, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(didMoveCamera, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(didEndMovingCamera, CAPPluginReturnCallback);
)
