import Foundation
import Capacitor
import GoogleMaps

@objc(CapacitorGoogleMaps)
public class CapacitorGoogleMaps: CustomMapViewEvents {

    var GOOGLE_MAPS_KEY: String = "";

    var customMarkers = [String : CustomMarker]();
    
    var customPolygons = [String: CustomPolygon]();

    var customWebView: CustomWKWebView?

    @objc func initialize(_ call: CAPPluginCall) {
        self.GOOGLE_MAPS_KEY = call.getString("key", "")

        if self.GOOGLE_MAPS_KEY.isEmpty {
            call.reject("GOOGLE MAPS API key missing!")
            return
        }

        GMSServices.provideAPIKey(self.GOOGLE_MAPS_KEY)

        self.customWebView = self.bridge?.webView as? CustomWKWebView

        DispatchQueue.main.async {
            // remove all custom maps views from the main view
            if let values = self.customWebView?.customMapViews.map({ $0.value }) {
                CAPLog.print("mapId \(values)")
                for mapView in values {
                    (mapView as CustomMapView).view.removeFromSuperview()
                }
            }
            // reset custom map views holder
            self.customWebView?.customMapViews = [:]
        }

        call.resolve([
            "initialized": true
        ])
    }

    @objc func createMap(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            let customMapView : CustomMapView = CustomMapView(customMapViewEvents: self)

            self.bridge?.saveCall(call)
            customMapView.savedCallbackIdForCreate = call.callbackId

            let boundingRect = call.getObject("boundingRect", JSObject())
            customMapView.boundingRect.updateFromJSObject(boundingRect)

            let mapCameraPosition = call.getObject("cameraPosition", JSObject())
            customMapView.mapCameraPosition.updateFromJSObject(mapCameraPosition, baseCameraPosition: nil)

            let preferences = call.getObject("preferences", JSObject())
            customMapView.mapPreferences.updateFromJSObject(preferences)

            self.customWebView?.scrollView.addSubview(customMapView.view)

            if (customMapView.GMapView == nil) {
                call.reject("Map could not be created. Did you forget to update the class in Main.storyboard? If you do not know what that is, please read the documentation.")
                return
            }

            self.customWebView?.scrollView.sendSubviewToBack(customMapView.view)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                self.setupWebView()
            }

            customMapView.GMapView.delegate = customMapView;
            self.customWebView?.customMapViews[customMapView.id] = customMapView

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.setupWebView()
            }
        }
    }
    
    @objc func updateMap(_ call: CAPPluginCall) {
        let mapId: String = call.getString("mapId", "")

        DispatchQueue.main.async {
            guard let customMapView = self.customWebView?.customMapViews[mapId] else {
                call.reject("map not found")
                return
            }
            
            let preferences = call.getObject("preferences", JSObject());
            customMapView.mapPreferences.updateFromJSObject(preferences);
            
            let result = customMapView.invalidateMap()
            
            call.resolve(result)
        }

    }


    @objc func removeMap(_ call: CAPPluginCall) {
        let mapId: String = call.getString("mapId", "")

        DispatchQueue.main.async {
            guard let customMapView = self.customWebView?.customMapViews[mapId] else {
                call.reject("map not found")
                return
            }
            
            (customMapView).view.removeFromSuperview()
            self.customWebView?.customMapViews.removeValue(forKey: mapId)

            call.resolve()
        }
    }
    
    @objc func getMap(_ call: CAPPluginCall) {
        let mapId: String = call.getString("mapId", "")

        DispatchQueue.main.async {
            guard let customMapView = self.customWebView?.customMapViews[mapId] else {
                call.reject("map not found")
                return
            }
            
            let result = customMapView.getMap()
            
            call.resolve(result)
        }

    }
    
    @objc func clearMap(_ call: CAPPluginCall) {
        let mapId: String = call.getString("mapId", "")
        let hide: Bool = call.getBool("hide", false)

        DispatchQueue.main.async {
            guard let customMapView = self.customWebView?.customMapViews[mapId] else {
                call.reject("map not found")
                return
            }

            let result = customMapView.clearMap(hide: hide)
            
            call.resolve()
        }

    }

    @objc func moveCamera(_ call: CAPPluginCall) {
        let mapId: String = call.getString("mapId", "")

        DispatchQueue.main.async {
            guard let customMapView = self.customWebView?.customMapViews[mapId] else {
                call.reject("map not found")
                return
            }

            let mapCameraPosition = customMapView.mapCameraPosition

            var currentCameraPosition: GMSCameraPosition?;

            let useCurrentCameraPositionAsBase = call.getBool("useCurrentCameraPositionAsBase", true)

            if (useCurrentCameraPositionAsBase) {
                currentCameraPosition = customMapView.getCameraPosition()
            }

            let cameraPosition = call.getObject("cameraPosition", JSObject())
            mapCameraPosition.updateFromJSObject(cameraPosition, baseCameraPosition: currentCameraPosition)

            let duration = call.getInt("duration", 0)

            customMapView.moveCamera(duration)

            call.resolve()
        }
    }

   @objc func getRegionInfo(_ call: CAPPluginCall) {
        let mapId: String = call.getString("mapId", "")

        DispatchQueue.main.async {
            guard let customMapView = self.customWebView?.customMapViews[mapId] else {
                call.reject("map not found")
                return
            }

            let region = customMapView.GMapView.projection.visibleRegion();
            let centerCoords = customMapView.GMapView.projection.coordinate(for: customMapView.GMapView.center)

            call.resolve([
                "bounds": [
                    "topLeft": [
                        "latitude": region.farLeft.latitude as Any,
                        "longitude": region.farLeft.longitude as Any
                    ],
                    "topRight": [
                        "latitude": region.farRight.latitude as Any,
                        "longitude": region.farRight.longitude as Any
                    ],
                    "bottomLeft": [
                        "latitude": region.nearLeft.latitude as Any,
                        "longitude": region.nearLeft.longitude as Any
                    ],
                    "bottomRight": [
                        "latitude": region.nearRight.latitude as Any,
                        "longitude": region.nearRight.longitude as Any
                    ]
                ],
                "center": [
                    "latitude": centerCoords.latitude as Any,
                    "longitude": centerCoords.longitude as Any
                ],
                "zoom": customMapView.GMapView.camera.zoom
            ])
        }
    }

    @objc func addMarker(_ call: CAPPluginCall) {
        let mapId: String = call.getString("mapId", "")

        DispatchQueue.main.async {
            guard let customMapView = self.customWebView?.customMapViews[mapId] else {
                call.reject("map not found")
                return
            }

            let position = call.getObject("position", JSObject())
            let preferences = call.getObject("preferences", JSObject())

            self.addMarker([
                "position": position,
                "preferences": preferences
            ], customMapView: customMapView) { marker in
                call.resolve(CustomMarker.getResultForMarker(marker, mapId: mapId))
            }
        }
    }

    @objc func addMarkers(_ call: CAPPluginCall) {
        let mapId: String = call.getString("mapId", "")

        guard let customMapView = self.customWebView?.customMapViews[mapId] else {
            call.reject("map not found")
            return
        }

        if let markers = call.getArray("markers")?.capacitor.replacingNullValues() as? [JSObject?] {
            // Group markers by icon url and size
            let markersGroupedByIcon = Dictionary(grouping: markers) { (marker) -> String in
                let preferences = marker?["preferences"] as? JSObject ?? JSObject()

                if let icon = preferences["icon"] as? JSObject {
                    if let url = icon["url"] as? String {
                        let size = icon["size"] as? JSObject ?? JSObject()
                        let resizeWidth = size["width"] as? Int ?? 30
                        let resizeHeight = size["height"] as? Int ?? 30
                        
                        // Generate custom key based on the size,
                        // so we can cache the resized variant of the image as well.
                        let groupByKey = "\(url)\(resizeWidth)\(resizeHeight)"
                        
                        return groupByKey
                    }
                }
                
                return ""
            }
            
            for markersGroup in markersGroupedByIcon {
                // Get the icon for this group by using the first marker value
                // (which should be the same as the following ones, since they are grouped by icon).
                if let firstMarker = markersGroup.value[0] {
                    let preferences = firstMarker["preferences"] as? JSObject ?? JSObject()

                    if let icon = preferences["icon"] as? JSObject {
                        if let url = icon["url"] as? String {
                            let size = icon["size"] as? JSObject ?? JSObject()
                            let resizeWidth = size["width"] as? Int ?? 30
                            let resizeHeight = size["height"] as? Int ?? 30

                            // Preload this icon into the cache.
                            self.imageCache.image(at: url, resizeWidth: resizeWidth, resizeHeight: resizeHeight) { image in
                                // Since the icon is already loaded,
                                // it is now possible to quickly render all the markers with this icon.
                                for marker in markersGroup.value {
                                    let position = marker?["position"] as? JSObject ?? JSObject();
                                    let preferences = marker?["preferences"] as? JSObject ?? JSObject();

                                    self.addMarker([
                                        "position": position,
                                        "preferences": preferences
                                    ], customMapView: customMapView) { marker in
                                        // Image is loaded
                                    }
                                }
                            }
                            
                            continue
                        }
                    }
                }
                
                // Render all markers on the map without a custom icon attached to them.
                for marker in markersGroup.value {
                    let position = marker?["position"] as? JSObject ?? JSObject();
                    let preferences = marker?["preferences"] as? JSObject ?? JSObject();

                    self.addMarker([
                        "position": position,
                        "preferences": preferences
                    ], customMapView: customMapView) { marker in
                        // Image is loaded
                    }
                }
            }
        }

        call.resolve()
    }

    @objc func removeMarker(_ call: CAPPluginCall) {
        let markerId: String = call.getString("markerId", "");

        DispatchQueue.main.async {
            let customMarker = self.customMarkers[markerId];

            if (customMarker != nil) {
                customMarker?.map = nil;
                self.customMarkers[markerId] = nil;
                call.resolve();
            } else {
                call.reject("marker not found");
            }
        }
    }
    
    @objc func addPolygon(_ call: CAPPluginCall) {
        let mapId: String = call.getString("mapId", "");

        DispatchQueue.main.async {
            guard let customMapView = self.customWebView?.customMapViews[mapId] else {
                call.reject("map not found")
                return
            }

            if let path = call.getArray("path")?.capacitor.replacingNullValues() as? [JSObject?] {
                let preferences = call.getObject("preferences", JSObject())

                self.addPolygon([
                    "path": path,
                    "preferences": preferences
                ], customMapView: customMapView) { polygon in
                    call.resolve(CustomPolygon.getResultForPolygon(polygon, mapId: mapId))
                }
            }
        }
    }
        
    @objc func removePolygon(_ call: CAPPluginCall) {
        let polygonId: String = call.getString("polygonId", "");

        DispatchQueue.main.async {
            if let customPolygon = self.customPolygons[polygonId] {
                customPolygon.map = nil;
                customPolygon.layer.removeFromSuperlayer()
                self.customPolygons[polygonId] = nil;
                call.resolve();
            } else {
                call.reject("polygon not found");
            }
        }
    }

    @objc func didTapInfoWindow(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_TAP_INFO_WINDOW);
    }

    @objc func didCloseInfoWindow(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_CLOSE_INFO_WINDOW);
    }

    @objc func didTapMap(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_TAP_MAP);
    }

    @objc func didLongPressMap(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_LONG_PRESS_MAP);
    }
    
    @objc func didTapMarker(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_TAP_MARKER);
    }
    
    @objc func didBeginDraggingMarker(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_BEGIN_DRAGGING_MARKER);
    }
    
    @objc func didDragMarker(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_DRAG_MARKER);
    }
    
    @objc func didEndDraggingMarker(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_END_DRAGGING_MARKER);
    }
    
    @objc func didTapMyLocationButton(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_TAP_MY_LOCATION_BUTTON);
    }

    @objc func didTapMyLocationDot(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_TAP_MY_LOCATION_DOT);
    }
    
    @objc func didTapPoi(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_TAP_POI);
    }
    
    @objc func didBeginMovingCamera(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_BEGIN_MOVING_CAMERA);
    }
    
    @objc func didMoveCamera(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_MOVE_CAMERA);
    }
    
    @objc func didEndMovingCamera(_ call: CAPPluginCall) {
        setCallbackIdForEvent(call: call, eventName: CustomMapView.EVENT_DID_END_MOVING_CAMERA);
    }

    func setCallbackIdForEvent(call: CAPPluginCall, eventName: String) {
        let mapId: String = call.getString("mapId", "")

        guard let customMapView = self.customWebView?.customMapViews[mapId] else {
            call.reject("map not found")
            return
        }

        call.keepAlive = true;
        let callbackId = call.callbackId;

        let preventDefault: Bool = call.getBool("preventDefault", false);
        customMapView.setCallbackIdForEvent(callbackId: callbackId, eventName: eventName, preventDefault: preventDefault);
    }

    override func lastResultForCallbackId(callbackId: String, result: PluginCallResultData) {
        let call = bridge?.savedCall(withID: callbackId);
        call?.resolve(result);
        bridge?.releaseCall(call!);
    }

    override func resultForCallbackId(callbackId: String, result: PluginCallResultData?) {
        let call = bridge?.savedCall(withID: callbackId);
        if (result != nil) {
            call?.resolve(result!);
        } else {
            call?.resolve();
        }
    }
}

private extension CapacitorGoogleMaps {
    func addMarker(_ markerData: JSObject, customMapView: CustomMapView, completion: @escaping VoidReturnClosure<GMSMarker>) {
        DispatchQueue.main.async {
            let marker = CustomMarker()

            marker.updateFromJSObject(markerData)

            self.customMarkers[marker.id] = marker

            let preferences = markerData["preferences"] as? JSObject ?? JSObject()

            if let icon = preferences["icon"] as? JSObject {
                if let url = icon["url"] as? String {
                    let size = icon["size"] as? JSObject ?? JSObject()
                    let resizeWidth = size["width"] as? Int ?? 30
                    let resizeHeight = size["height"] as? Int ?? 30
                    DispatchQueue.global(qos: .background).async {
                        self.imageCache.image(at: url, resizeWidth: resizeWidth, resizeHeight: resizeHeight) { image in
                            DispatchQueue.main.async {
                                marker.icon = image
                                marker.map = customMapView.GMapView
                                completion(marker)
                            }
                        }
                    }
                    return
                }
            }

            marker.map = customMapView.GMapView

            completion(marker)
        }
    }
    
    func addPolygon(_ polygonData: JSObject, customMapView: CustomMapView, completion: @escaping VoidReturnClosure<GMSPolygon>) {
        DispatchQueue.main.async {
            let polygon = CustomPolygon()

            polygon.updateFromJSObject(polygonData)

            polygon.map = customMapView.GMapView

            self.customPolygons[polygon.id] = polygon

            completion(polygon)
        }
    }
    
    

    func setupWebView() {
        DispatchQueue.main.async {
            self.customWebView?.isOpaque = false
            self.customWebView?.backgroundColor = .clear

            let javascript = "document.documentElement.style.backgroundColor = 'transparent'"
            self.customWebView?.evaluateJavaScript(javascript)
        }
    }
}

extension CapacitorGoogleMaps: ImageCachable {
    var imageCache: ImageURLLoadable {
        NativeImageCache.shared
    }
}
