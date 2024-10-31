import {
  MapAppearance,
  MapControls,
  MapGestures,
} from "./../../../definitions";

export interface MapPreferences {
  /**
   * @since 2.0.0
   */
  gestures?: MapGestures;
  /**
   * @since 2.0.0
   */
  controls?: MapControls;
  /**
   * @since 2.0.0
   */
  appearance?: MapAppearance;
  /**
   * @since 2.0.0
   */
  minZoom?: number;
  /**
   * @since 2.0.0
   */
  maxZoom?: number;

  padding?: any; // @todo: Sets padding on the map.

  liteMode?: boolean; // @todo
}
