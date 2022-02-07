//
//  CustomMapViewController.swift
//  Capacitor
//
//  Created by Admin on 27.12.2021.
//

import Capacitor
import GoogleMaps
import GoogleMapsUtils
import UIKit

let kClusterItemCount = 10000


class CustomMapViewController: UIViewController, GMSMapViewDelegate {
    
    var customMapViewEvents: CustomMapViewEvents!;
    
    var id: String!;
    
    var mapView: GMSMapView!;
    
    var locationButton : UIButton!;
    
    
    
    var boundingRect = BoundingRect();
    var mapCameraPosition = MapCameraPosition();
    var mapPreferences = MapPreferences();
    
    
    private var mClusterManager: GMUClusterManager!
    private var mMarkersList: [CustomMarker]!
    
    
    var savedCallbackIdForCreate: String!;
    
    var savedCallbackIdForDidTapInfoWindow: String!;

    var savedCallbackIdForDidCloseInfoWindow: String!;

    var savedCallbackIdForDidTapMap: String!;

    var savedCallbackIdForDidLongPressMap: String!;
    
    var savedCallbackIdForDidTapMarker: String!;
    var preventDefaultForDidTapMarker: Bool = false;
    
    var savedCallbackIdForDidTapCluster: String!;

    var savedCallbackIdForDidTapMyLocationButton: String!;
    var preventDefaultForDidTapMyLocationButton: Bool = false;

    var savedCallbackIdForDidTapMyLocationDot: String!;

    // This allows you to initialise your custom UIViewController without a nib or bundle.
    convenience init(customMapViewEvents: CustomMapViewEvents) {
        self.init(nibName:nil, bundle:nil)
        self.customMapViewEvents = customMapViewEvents
        self.id = NSUUID().uuidString.lowercased()
    }

    
    // This extends the superclass.
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    
    override func loadView() {
        let frame = CGRect(x: self.boundingRect.x, y: self.boundingRect.y, width: self.boundingRect.width, height: self.boundingRect.height);
        
        let camera = GMSCameraPosition.camera(withLatitude: self.mapCameraPosition.latitude, longitude: self.mapCameraPosition.longitude, zoom: self.mapCameraPosition.zoom, bearing: self.mapCameraPosition.bearing, viewingAngle: self.mapCameraPosition.tilt);
        
        self.mapView = GMSMapView.map(withFrame: frame, camera: camera);
        
        self.view = mapView;
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        setupClustering()
        
        mMarkersList = [CustomMarker]();
        
        // Register self to listen to GMSMapViewDelegate events.
        mClusterManager.setMapDelegate(self)
        
        self.invalidateMap();

        self.customMapViewEvents.lastResultForCallbackId(callbackId: savedCallbackIdForCreate, result: [
            "googleMap": [
                "mapId": self.id
            ]
        ]);
    }
    
    private func setupClustering() {
        guard let mapView = self.mapView else { return }

        let iconGenerator = CustomClusterIconGenerator()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self;
        renderer.zIndex = 10;
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        self.mClusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("CustomMapViewController getting touches and event")
//        var uir : UIResponder = UIResponder()
//        uir.touchesBegan(touches, with: event)
        
        self.mapView.point(inside: (touches.first?.location(in: self.view))!, with: event)
//        self.GMapView.touchesBegan(touches, with: event)
//        super.touchesBegan(touches, with: event)
    }
    
    
    func invalidateMap() {
        if (self.mapView == nil) {
            return;
        }
            
        // set gestures
        self.mapView.settings.rotateGestures = self.mapPreferences.gestures.isRotateAllowed;
        self.mapView.settings.scrollGestures = self.mapPreferences.gestures.isScrollAllowed;
        self.mapView.settings.allowScrollGesturesDuringRotateOrZoom = self.mapPreferences.gestures.isScrollAllowedDuringRotateOrZoom;
        self.mapView.settings.tiltGestures = self.mapPreferences.gestures.isTiltAllowed;
        self.mapView.settings.zoomGestures = self.mapPreferences.gestures.isZoomAllowed;

        // set controls
        self.mapView.settings.compassButton = self.mapPreferences.controls.isCompassButtonEnabled;
        self.mapView.settings.indoorPicker = self.mapPreferences.controls.isIndoorLevelPickerEnabled;
        self.mapView.settings.myLocationButton = self.mapPreferences.controls.isMyLocationButtonEnabled;

        // set appearance
        self.mapView.mapType = self.mapPreferences.appearance.type;
        self.mapView.mapStyle = self.mapPreferences.appearance.style;
        self.mapView.isBuildingsEnabled = self.mapPreferences.appearance.isBuildingsShown;
        self.mapView.isIndoorEnabled = self.mapPreferences.appearance.isIndoorShown;
        self.mapView.isMyLocationEnabled = self.mapPreferences.appearance.isMyLocationDotShown;
        self.mapView.isTrafficEnabled = self.mapPreferences.appearance.isTrafficShown;
        
        
        // if we have location button then
        // hide default button
        if(self.mapView.isMyLocationEnabled == true) {
        locationButton = getLocationButtonFromMapView();
        locationButton.isHidden = true;
        }
    }
    
    
    public func setCallbackIdForEvent(callbackId: String!, eventName: String!,
                                      preventDefault: Bool!) {
        if (callbackId != nil && eventName != nil) {
            switch eventName {
            case Events.EVENT_DID_TAP_INFO_WINDOW:
                savedCallbackIdForDidTapInfoWindow = callbackId;
            case Events.EVENT_DID_CLOSE_INFO_WINDOW:
                savedCallbackIdForDidCloseInfoWindow = callbackId;
            case Events.EVENT_DID_TAP_MAP:
                savedCallbackIdForDidTapMap = callbackId;
            case Events.EVENT_DID_LONG_PRESS_MAP:
                savedCallbackIdForDidLongPressMap = callbackId;
            case Events.EVENT_DID_TAP_MARKER:
                savedCallbackIdForDidTapMarker = callbackId
                preventDefaultForDidTapMarker = preventDefault ?? false;
            case Events.EVENT_DID_TAP_CLUSTER:
                savedCallbackIdForDidTapCluster = callbackId
            case Events.EVENT_DID_TAP_MY_LOCATION_BUTTON:
                savedCallbackIdForDidTapMyLocationButton = callbackId;
                preventDefaultForDidTapMyLocationButton = preventDefault ?? false;
            case Events.EVENT_DID_TAP_MY_LOCATION_DOT:
                savedCallbackIdForDidTapMyLocationDot = callbackId
            default:
                return
            }
        
        }
        
    }
    
    public func clear() {
        mapView.clear();
        mClusterManager.clearItems();
    }
    
    public func addMarker(_ customMarker: CustomMarker!) {
        // TO-DO: Implement setting of custom icon
        self.mClusterManager.add(customMarker);
        self.mMarkersList.append(customMarker);
        self.mClusterManager.cluster();
    }
    
    public func addMarkers(_ markerArray: [CustomMarker]!) {
        self.mClusterManager.add(markerArray);
        self.mMarkersList.append(contentsOf: markerArray);
        self.mClusterManager.cluster();
    }
    
    public func updateMarker(_ markerId: String, _ preferences:JSObject) -> Bool {
        for item in self.mMarkersList {
            if(item.markerId == markerId) {
                self.mClusterManager.remove(item);
                item.updateFromJSObject(preferences: preferences);
                self.mClusterManager.add(item);
                self.mClusterManager.cluster();
                return true;
            }
        }
        return false;
    }
    
    public func removeMarker(_ markerId: String) {
        var index : Int = 0;
        for item in self.mMarkersList {
            if(item.markerId == markerId) {
                self.mClusterManager.remove(item);
                self.mMarkersList.remove(at: index);
                self.mClusterManager.cluster();
                return;
            }
            index += 1;
        }
    }
    
    
    // MARK: GMSMapViewDelegate
    
    internal func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if (customMapViewEvents != nil && savedCallbackIdForDidTapInfoWindow != nil) {
            let result: PluginCallResultData = CustomMarker.getResultForMarker(marker);
            customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidTapInfoWindow, result: result);
        }
    }

    internal func mapView(_ mapView: GMSMapView, didCloseInfoWindowOf marker: GMSMarker) {
        if (customMapViewEvents != nil && savedCallbackIdForDidCloseInfoWindow != nil) {
            let result: PluginCallResultData = CustomMarker.getResultForMarker(marker);
            customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidCloseInfoWindow, result: result);
        }
    }
    
    internal func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if (customMapViewEvents != nil && savedCallbackIdForDidTapMap != nil) {
            let result: PluginCallResultData = self.getResultForPosition(coordinate: coordinate);
            customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidTapMap, result: result);
        }
    }
    
    internal func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        if (customMapViewEvents != nil && savedCallbackIdForDidLongPressMap != nil) {
            let result: PluginCallResultData = self.getResultForPosition(coordinate: coordinate);
            customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidLongPressMap, result: result);
        }
    }

    internal func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        mapView.animate(toLocation: marker.position)
        if let cluster = marker.userData as? GMUCluster {
            var bounds : GMSCoordinateBounds = GMSCoordinateBounds()
            for item in cluster.items {
                bounds = bounds.includingCoordinate(item.position)
            }
            var update : GMSCameraUpdate = GMSCameraUpdate.fit(bounds);
            mapView.moveCamera(update)
          NSLog("Did tap cluster")
            if(customMapViewEvents != nil && savedCallbackIdForDidTapCluster != nil) {
                customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidTapCluster, result: nil);
            }
          return true
        }
        NSLog("Did tap marker")
//        return false
        
        if (customMapViewEvents != nil && savedCallbackIdForDidTapMarker != nil) {
            let result: PluginCallResultData = CustomMarker.getResultForMarker(marker);
            customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidTapMarker, result: result);
        }
        return preventDefaultForDidTapMarker;
    }

    internal func mapView(_ mapView: GMSMapView, didTapMyLocation coordinate: CLLocationCoordinate2D) {
        if (customMapViewEvents != nil && savedCallbackIdForDidTapMyLocationDot != nil) {
            let result: PluginCallResultData = self.getResultForPosition(coordinate: coordinate);
            customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidTapMyLocationDot, result: result);
        }
    }

    internal func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        if (customMapViewEvents != nil && savedCallbackIdForDidTapMyLocationButton != nil) {
            customMapViewEvents.resultForCallbackId(callbackId: savedCallbackIdForDidTapMyLocationButton, result: nil);
        }
        return preventDefaultForDidTapMyLocationButton;
    }

    private func getResultForPosition(coordinate: CLLocationCoordinate2D) -> PluginCallResultData {
        return [
            "position": [
                "latitude": coordinate.latitude,
                "longitude": coordinate.longitude
            ]
        ]
    }
    
    
    public func zoomIn() {
        self.mapView.animate(toZoom: mapView.camera.zoom + 1);
    }
    
    public func zoomOut() {
        self.mapView.animate(toZoom: mapView.camera.zoom - 1);
    }
    
    public func myLocationButtonClick() {
        locationButton.sendActions(for: .touchUpInside);
    }
    
    private func getLocationButtonFromMapView() -> UIButton {
        for object in self.mapView.subviews {
            if(String(describing: type(of: object)) == "GMSUISettingsPaddingView") {
                for view in object.subviews {
                    if(String(describing: type(of: view)) == "GMSUISettingsView") {
                        for btn in view.subviews {
                            if(String(describing: type(of: btn)) == "GMSx_MDCFloatingButton") {
                                if btn is UIButton {
                                    let button = btn as! UIButton;
                                    return button;
                                }
                            }
                        }
                    }
                }	
            }
        }
        return UIButton();
    }
}


extension CustomMapViewController: GMUClusterRendererDelegate {
    func renderer(_ renderer: GMUClusterRenderer, willRenderMarker marker: GMSMarker) {
            // if your marker is pointy you can change groundAnchor
//            marker.groundAnchor = CGPoint(x: 0.5, y: 1)
            if  let markerData = (marker.userData as? CustomMarker) {
                let icon = MarkerCategory.markerCategories[markerData.markerCategoryId]?.getIcon ?? nil;
                marker.icon = icon;
                marker.zIndex = 5;
            }
        }
}

