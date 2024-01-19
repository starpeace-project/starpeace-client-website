import { colord, type RgbaColor } from 'colord';

export default class Sprite {

  width (_viewport: any): number {
    return 0;
  }
  height (_viewport: any): number {
    return 0;
  }

  withinCanvas (canvas: any, viewport: any): boolean {
    const width = this.width(viewport);
    const height = this.height(viewport);

    const xMin = canvas.x - (width - viewport.tile_width) * .5;
    const xMax = xMin + width;
    const yMin = canvas.y - (height - viewport.tile_height);
    const yMax = yMin + height;

    return (xMin <= viewport.canvas_width || xMax >= 0) && (yMin <= viewport.canvas_height || yMax >= 0);
  }

  static adjustTint (tint: number, alpha: number): RgbaColor {
    return colord({ r: (tint & 0xFF0000) >> 16, g: (tint & 0x00FF00) >> 8, b: (tint & 0x0000FF) >> 0 }).alpha(alpha).toRgb();
  }
}
