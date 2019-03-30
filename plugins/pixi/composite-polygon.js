
import * as PIXI from 'pixi.js';

export default class CompositePolygon extends PIXI.Polygon {
  constructor(polygons) {
    super([]);

    if (!Array.isArray(polygons)) {
      throw "consutrctor parameters must be an array of PIXI.Polygon's"
    }

    this.polygons = polygons;
    for (let i = 0; i < this.polygons.length; i++) {
      if (!(this.polygons[i] instanceof PIXI.Polygon)) {
        throw "consutrctor parameters must be an array of PIXI.Polygon's"
      }
    }
  }

  contains(x, y) {
    for (let i = 0; i < this.polygons.length; i++) {
      if (this.polygons[i].contains(x, y)) {
        return true;
      }
    }
    return false;
  }
}
