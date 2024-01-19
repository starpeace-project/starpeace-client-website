
import { Polygon } from 'pixi.js';

export default class CompositePolygon extends Polygon {
  constructor (polygons) {
    super([]);

    if (!Array.isArray(polygons)) {
      throw "constructor parameters must be an array of Polygon's"
    }

    this.polygons = polygons;
    for (let i = 0; i < this.polygons.length; i++) {
      if (!(this.polygons[i] instanceof Polygon)) {
        throw "constructor parameters must be an array of Polygon's"
      }
    }
  }

  contains (x, y) {
    for (let i = 0; i < this.polygons.length; i++) {
      if (this.polygons[i].contains(x, y)) {
        return true;
      }
    }
    return false;
  }
}
