import { LatLng } from "../models/LatLng";

export interface GetRegionInfoOptions {
  /**
   * @since 2.0.0
   */
  mapId: string;
}

export interface Bounds {
  /**
   * @since 2.0.0
   */
  topLeft: LatLng;
  /**
   * @since 2.0.0
   */
  topRight: LatLng;
  /**
   * @since 2.0.0
   */
  bottomLeft: LatLng;
  /**
   * @since 2.0.0
   */
  bottomRight: LatLng;
}

export interface GetRegionInfoResult {
  /**
   * @since 2.0.0
   */
  bounds: Bounds;
  center: LatLng;
  zoom: number;
}
