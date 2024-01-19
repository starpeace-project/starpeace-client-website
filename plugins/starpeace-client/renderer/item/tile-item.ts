import SpriteBuilding from '~/plugins/starpeace-client/renderer/sprite/sprite-building.js'
import SpriteBuildingFootprint from '~/plugins/starpeace-client/renderer/sprite/sprite-building-footprint.js'
import SpriteConcrete from '~/plugins/starpeace-client/renderer/sprite/sprite-concrete.js'
import SpriteLand from '~/plugins/starpeace-client/renderer/sprite/sprite-land.js'
import SpriteOverlay from '~/plugins/starpeace-client/renderer/sprite/sprite-overlay.js'
import SpriteRoad from '~/plugins/starpeace-client/renderer/sprite/sprite-road.js'
import SpriteTree from '~/plugins/starpeace-client/renderer/sprite/sprite-tree.js'

export interface TileSprites {
  land: SpriteLand | undefined;
  concrete: SpriteConcrete | undefined;
  road: SpriteRoad | undefined;
  tree: SpriteTree | undefined;
  foundation: SpriteBuildingFootprint | undefined;
  building: SpriteBuilding | undefined;
  overlay: SpriteOverlay | undefined;
}

export default class TileItem {

  tile: any;
  sprite: TileSprites;

  x: number;
  y: number;

  sprites: Record<string, any> = {};

  constructor (tileInfo: any, x: number, y: number, sprite: TileSprites) {
    this.tile = tileInfo;
    this.x = x;
    this.y = y;
    this.sprite = sprite;
  }
}
