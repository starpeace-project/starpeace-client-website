import { Cache, type Texture } from 'pixi.js'

import SpriteBuilding from '~/plugins/starpeace-client/renderer/sprite/sprite-building.js'
import SpriteBuildingConstruction from '~/plugins/starpeace-client/renderer/sprite/sprite-building-construction.js'
import SpriteBuildingFootprint from '~/plugins/starpeace-client/renderer/sprite/sprite-building-footprint.js'
import SpriteConcrete from '~/plugins/starpeace-client/renderer/sprite/sprite-concrete.js'
import SpriteEffect from '~/plugins/starpeace-client/renderer/sprite/sprite-effect.js'
import SpriteLand from '~/plugins/starpeace-client/renderer/sprite/sprite-land.js'
import SpriteOverlay from '~/plugins/starpeace-client/renderer/sprite/sprite-overlay.js'
import SpritePlane from '~/plugins/starpeace-client/renderer/sprite/sprite-plane.js'
import SpriteRoad from '~/plugins/starpeace-client/renderer/sprite/sprite-road.js'
import SpriteSign from '~/plugins/starpeace-client/renderer/sprite/sprite-sign.js'
import SpriteTree from '~/plugins/starpeace-client/renderer/sprite/sprite-tree.js'
import { RenderContext } from '~/plugins/starpeace-client/renderer/layer/layers'

import type TileInfo from '~/plugins/starpeace-client/map/tile-info.js'

import ClientState from '~/plugins/starpeace-client/state/client-state.js'
import Logger from '~/plugins/starpeace-client/logger.js'


export default class TileItemFactory {
  clientState: ClientState;

  constructor (clientState: ClientState) {
    this.clientState = clientState;
  }

  land (tileInfo: TileInfo, context: RenderContext): SpriteLand | undefined {
    if (!tileInfo.land) {
      return undefined;
    }

    const textureId: string | undefined = Object.values(tileInfo.land?.textures?.['0deg']?.[context.currentSeason] ?? {})[0] as string;
    let texture: Texture | undefined = (textureId?.length ?? 0) > 0 ? Cache.get(textureId) : undefined;

    if (!texture) {
      texture = Cache.get(`${context.currentSeason}.255.border.center.1`);
      if (!texture) {
        Logger.debug(`Unable to find ground texture <${textureId}> and no fallback`);
        return undefined;
      }
      Logger.debug(`Unable to find ground texture <${textureId}>, falling back to default`);
    }

    return new SpriteLand(texture, tileInfo.isChunkDataLoaded, tileInfo.zone?.color);
  }

  concrete (tileInfo: TileInfo): SpriteConcrete | undefined {
    if (!tileInfo?.concrete) {
      return undefined;
    }

    const textureId = tileInfo.concrete?.type?.texture_id;
    if (!textureId?.length || !Cache.has(textureId)) {
      Logger.debug(`No concrete texture for ${textureId}`);
      return undefined;
    }

    return new SpriteConcrete(Cache.get(textureId), tileInfo.concrete.type.is_flat == true, tileInfo.concrete.type.is_platform, tileInfo.zone?.color);
  }

  road (tileInfo: TileInfo): SpriteRoad | undefined {
    if (!tileInfo.road) {
      return undefined;
    }

    const textureId = tileInfo.road.is_city ? tileInfo.road.type.city_texture_id : tileInfo.road.type.country_texture_id;
    if (!textureId?.length || !Cache.has(textureId)) {
      Logger.debug(`No road texture for ${tileInfo.road.type?.type || 'unknown'}`);
      return undefined;
    }

    return new SpriteRoad(Cache.get(textureId), tileInfo.road.type.is_bridge || false, tileInfo.road.is_over_water, tileInfo.zone?.color);
  }

  tree (tileInfo: TileInfo, context: RenderContext): SpriteTree | undefined {
    if (!tileInfo.tree) {
      return undefined;
    }

    const textureId = tileInfo.tree?.textures?.[context.currentSeason];
    if (!textureId?.length || !Cache.has(textureId)) {
      Logger.debug(`Unable to find tree texture <${textureId}>`);
      return undefined;
    }

    return new SpriteTree(Cache.get(textureId), tileInfo.isChunkDataLoaded, tileInfo.zone?.color);
  }

  overlay (tileInfo: TileInfo): SpriteOverlay | undefined {
    if (!tileInfo.overlay || !Cache.has('overlay.1')) {
      return undefined;
    }
    return new SpriteOverlay(Cache.get('overlay.1'), tileInfo.overlay.color);
  }

  foundation (tileInfo: TileInfo): SpriteBuildingFootprint | undefined {
    if (!tileInfo.building) {
      return undefined;
    }

    const metadata = this.clientState.core.building_library.metadata_by_id[tileInfo.building.definition_id];
    if (!metadata) {
      Logger.warn(`Unable to load building definition metadata for ${tileInfo.building.definition_id}`);
      return undefined

    }

    const imageMetadata = this.clientState.core.building_library.images_by_id[metadata.imageId];
    if (!imageMetadata) {
      Logger.warn(`Unable to load building image metadata for ${metadata.imageId}`);
      return undefined
    }

    const texture = Cache.get(`overlay.${imageMetadata.w}`);
    if (!texture) {
      Logger.warn(`Unable to find cached overlay texture for size ${imageMetadata.w}`);
      return undefined;
    }

    const zone = metadata.zoneId ? this.clientState.core.planet_library.zone_for_id(metadata.zoneId) : undefined;
    return new SpriteBuildingFootprint(texture, imageMetadata, zone?.color ?? 0);
  }

  building (tileInfo: TileInfo, context: RenderContext): SpriteBuilding | undefined {
    if (!tileInfo.building) {
      return undefined
    }

    const metadata = this.clientState.core.building_library.metadata_by_id[tileInfo.building.definition_id];
    if (!metadata) {
      Logger.warn(`Unable to load building definition metadata for ${tileInfo.building.definition_id}`);
      return undefined
    }

    const imageId = metadata.getImageIdForLevel(tileInfo.building.level) ?? metadata.imageId;
    const currentImageId = !tileInfo.building.constructed || tileInfo.building.upgrading ? metadata.constructionImageId : imageId;
    const imageMetadata = this.clientState.core.building_library.images_by_id[currentImageId];
    if (!imageMetadata) {
      Logger.warn(`Unable to load building image metadata for ${imageId} ${tileInfo.building}`);
      return undefined;
    }

    const textures: Texture[] = (imageMetadata?.frames ?? []).map((textureId: string) => Cache.get(textureId));
    if (!textures.length || textures.some((t: Texture | undefined) => !t)) {
      Logger.warn(`Unable to load building textures for ${imageMetadata.id}`);
      return undefined;
    }

    const effects = [];
    if (imageMetadata.effects && context.renderBuildingEffects) {
      for (const effect of imageMetadata.effects) {
        const effectMetadata = this.clientState.core.effect_library.metadata_by_id[effect.type];
        const effectTextures = (effectMetadata?.frames ?? []).map((textureId: string) => Cache.get(textureId));
        if (effectTextures.length > 0 && effectTextures.every((t: Texture) => !t)) {
          effects.push(new SpriteEffect(effectTextures, effect, effectMetadata))
        }
      }
    }

    const signs = [];
    if (metadata.signId && imageMetadata.sign) {
      const signMetadata = this.clientState.core.sign_library.metadata_by_id[metadata.signId];
      const signTextures = (signMetadata?.frames ?? []).map((textureId: string) => Cache.get(textureId));
      if (!!signMetadata && signTextures.length > 0) {
        signs.push(new SpriteSign(signTextures, imageMetadata.sign, signMetadata));
      }
    }

    const hasSelection = (context.selectedBuildingId?.length ?? 0) > 0;
    const isSelected = hasSelection && context.selectedBuildingId === tileInfo.building.id;
    const isFiltered = hasSelection && (!context.selectedCorporationId?.length || context.selectedCorporationId !== tileInfo.building.corporation_id);

    return new SpriteBuilding(textures, textures.length > 1 && context.renderBuildingAnimations, isSelected, isFiltered, imageMetadata, effects, signs);
  }

  buildingConstruction (buildingId: string, renderBuildingAnimations: boolean, isValidLocation: boolean): SpriteBuildingConstruction | undefined {
    const metadata = this.clientState.core.building_library.metadata_by_id[buildingId];
    if (!metadata) {
      return undefined;
    }

    const imageMetadata = this.clientState.core.building_library.images_by_id[metadata.imageId];
    if (!imageMetadata) {
      return undefined;
    }

    const textures = (imageMetadata?.frames ?? []).map((textureId: string) => Cache.get(textureId));
    if (!textures.length || textures.some((t: Texture | undefined) => !t)) {
      return undefined;
    }

    return new SpriteBuildingConstruction(textures, textures.length > 1 && renderBuildingAnimations, isValidLocation, imageMetadata);
  }

  plane (flightPlan: any): SpritePlane | undefined {
    const textures = (flightPlan.plane_info?.frames ?? []).map((frameId: string) => Cache.get(frameId));
    if (!textures.length || textures.some((t: Texture | undefined) => !t)) {
      return undefined;
    }
    return new SpritePlane(textures, flightPlan);
  }
}
