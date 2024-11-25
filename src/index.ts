import { PluginListenerHandle, registerPlugin } from "@capacitor/core";
import {
  CapacitorGoogleMapsPlugin,
  CallbackID,
  InitializeOptions,
  CreateMapOptions,
  CreateMapResult,
  UpdateMapOptions,
  UpdateMapResult,
  RemoveMapOptions,
  ClearMapOptions,
  MoveCameraOptions,
  ElementFromPointResultOptions,
  AddMarkerOptions,
  AddMarkerResult,
  RemoveMarkerOptions,
  DidTapInfoWindowCallback,
  DidCloseInfoWindowCallback,
  DidTapMapCallback,
  DidLongPressMapCallback,
  DidTapMarkerCallback,
  DidBeginDraggingMarkerCallback,
  DidDragMarkerCallback,
  DidEndDraggingMarkerCallback,
  DidTapMyLocationButtonCallback,
  DidTapMyLocationDotCallback,
  DidTapPoiCallback,
  DidBeginMovingCameraCallback,
  DidMoveCameraCallback,
  DidEndMovingCameraCallback,
  DefaultEventOptions,
  DefaultEventWithPreventDefaultOptions,
  DidRequestElementFromPointResult,
} from "./definitions";

const CapacitorGoogleMapsPluginInstance = registerPlugin<CapacitorGoogleMapsPlugin>(
  "CapacitorGoogleMaps",
  {
    web: () => import("./web").then((m) => new m.CapacitorGoogleMapsWeb()),
  }
);

export class CapacitorGoogleMaps  {
  private constructor() {}

  public static async initialize(_options: InitializeOptions): Promise<void> {
    return CapacitorGoogleMapsPluginInstance.initialize(_options);
  }

  public static async addListener(eventName: "didRequestElementFromPoint", listenerFunc: (result: DidRequestElementFromPointResult) => void): Promise<PluginListenerHandle> {
    return CapacitorGoogleMapsPluginInstance.addListener(eventName, listenerFunc);
  }

  public static async createMap(element: HTMLElement, _options: CreateMapOptions = {}): Promise<CreateMapResult> {
    if (element && !_options.boundingRect) {
      // get boundaries of element
      const boundingRect = element.getBoundingClientRect();
      _options.boundingRect = {
        width: Math.round(boundingRect.width),
        height: Math.round(boundingRect.height),
        x: Math.round(boundingRect.x),
        y: Math.round(boundingRect.y),
      }
    }
    return CapacitorGoogleMapsPluginInstance.createMap(_options);
  }

  public static async removeMap(_options: RemoveMapOptions): Promise<void> {
    return CapacitorGoogleMapsPluginInstance.removeMap(_options);
  }

  public static async clearMap(_options: ClearMapOptions): Promise<void> {
    return CapacitorGoogleMapsPluginInstance.clearMap(_options);
  }

  public static async updateMap(_options: UpdateMapOptions): Promise<UpdateMapResult> {
    return CapacitorGoogleMapsPluginInstance.updateMap(_options);
  }

  public static async moveCamera(_options: MoveCameraOptions): Promise<void> {
    return CapacitorGoogleMapsPluginInstance.moveCamera(_options);
  }

  public static async addMarker(_options: AddMarkerOptions): Promise<AddMarkerResult> {
    return CapacitorGoogleMapsPluginInstance.addMarker(_options);
  }

  public static async removeMarker(_options: RemoveMarkerOptions): Promise<void> {
    return CapacitorGoogleMapsPluginInstance.removeMarker(_options);
  }

  public static async didTapInfoWindow(
    _options: DefaultEventOptions,
    _callback: DidTapInfoWindowCallback
  ): Promise<CallbackID> {
    return CapacitorGoogleMapsPluginInstance.didTapInfoWindow(_options, _callback);
  }

  public static async didCloseInfoWindow(
    _options: DefaultEventOptions,
    _callback: DidCloseInfoWindowCallback
  ): Promise<CallbackID> {
    return CapacitorGoogleMapsPluginInstance.didCloseInfoWindow(_options, _callback);
  }

  public static async didTapMap(
    _options: DefaultEventOptions,
    _callback: DidTapMapCallback
  ): Promise<CallbackID> {
    return CapacitorGoogleMapsPluginInstance.didTapMap(_options, _callback);
  }

  public static async didLongPressMap(
    _options: DefaultEventOptions,
    _callback: DidLongPressMapCallback
  ): Promise<CallbackID> {
    return CapacitorGoogleMapsPluginInstance.didLongPressMap(_options, _callback);
  }

  public static async didTapMarker(
    _options: DefaultEventWithPreventDefaultOptions,
    _callback: DidTapMarkerCallback
  ): Promise<CallbackID> {
    return CapacitorGoogleMapsPluginInstance.didTapMarker(_options, _callback);
  }

  public static async didBeginDraggingMarker(
    _options: DefaultEventOptions,
    _callback: DidBeginDraggingMarkerCallback
  ): Promise<CallbackID> {
    return CapacitorGoogleMapsPluginInstance.didBeginDraggingMarker(_options, _callback);
  }

  public static async didDragMarker(
    _options: DefaultEventOptions,
    _callback: DidDragMarkerCallback
  ): Promise<CallbackID> {
    return CapacitorGoogleMapsPluginInstance.didDragMarker(_options, _callback);
  }

  public static async didEndDraggingMarker(
    _options: DefaultEventOptions,
    _callback: DidEndDraggingMarkerCallback
  ): Promise<CallbackID> {
    return CapacitorGoogleMapsPluginInstance.didEndDraggingMarker(_options, _callback);
  }

  public static async didTapMyLocationButton(
    _options: DefaultEventWithPreventDefaultOptions,
    _callback: DidTapMyLocationButtonCallback
  ): Promise<CallbackID> {
    return CapacitorGoogleMapsPluginInstance.didTapMyLocationButton(_options, _callback);
  }

  public static async didTapMyLocationDot(
    _options: DefaultEventWithPreventDefaultOptions,
    _callback: DidTapMyLocationDotCallback
  ): Promise<CallbackID> {
    return CapacitorGoogleMapsPluginInstance.didTapMyLocationDot(_options, _callback);
  }

  public static async didTapPoi(
    _options: DefaultEventOptions,
    _callback: DidTapPoiCallback
  ): Promise<CallbackID> {
    return CapacitorGoogleMapsPluginInstance.didTapPoi(_options, _callback);
  }

  public static async didBeginMovingCamera(
    _options: DefaultEventOptions,
    _callback: DidBeginMovingCameraCallback
  ): Promise<CallbackID> {
    return CapacitorGoogleMapsPluginInstance.didBeginMovingCamera(_options, _callback);
  }

  public static async didMoveCamera(
    _options: DefaultEventOptions,
    _callback: DidMoveCameraCallback
  ): Promise<CallbackID> {
    return CapacitorGoogleMapsPluginInstance.didMoveCamera(_options, _callback);
  }

  public static async didEndMovingCamera(
    _options: DefaultEventOptions,
    _callback: DidEndMovingCameraCallback
  ): Promise<CallbackID> {
    return CapacitorGoogleMapsPluginInstance.didEndMovingCamera(_options, _callback);
  }

  public static async elementFromPointResult(
    _options: ElementFromPointResultOptions
  ): Promise<void> {
    return CapacitorGoogleMapsPluginInstance.elementFromPointResult(_options);
  }
}


CapacitorGoogleMapsPluginInstance.addListener("didRequestElementFromPoint", (data) => {
  const object: ElementFromPointResultOptions = {
    eventChainId: data?.eventChainId,
    mapId: null,
    isSameNode: false,
  };

  const { x, y } = data?.point || {};

  if (x && y) {
    const element = document.elementFromPoint(x, y);

    const mapId = element?.getAttribute?.("data-maps-id");
    if (mapId) {
      // if (ref.isSameNode(element)) {
      //   object.isSameNode = true;
      // }
      object.mapId = mapId;
      object.isSameNode = true;
    }
  }

  CapacitorGoogleMapsPluginInstance.elementFromPointResult(object);
});

export * from "./definitions";