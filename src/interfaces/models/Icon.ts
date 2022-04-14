import { Size } from "./Size";

/**
 * A data class representing icon/marker.
 */
export interface Icon {
  /**
   * URL path to icon
   *
   * @since x.x.x
   */
  url: string;
  
  /**
   * Target icon size in millimeters
   *
   * @since x.x.x
   */
  targetSizeMm?: Size;
  
  /**
   * Target icon size in pixels
   *
   * @since x.x.x
   */
  targetSizePx?: Size;
}