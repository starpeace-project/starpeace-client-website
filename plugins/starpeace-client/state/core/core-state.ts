import { markRaw } from 'vue';

import BuildingLibrary from '~/plugins/starpeace-client/state/core/library/building-library.coffee'
import ConcreteLibrary from '~/plugins/starpeace-client/state/core/library/concrete-library.coffee'
import EffectLibrary from '~/plugins/starpeace-client/state/core/library/effect-library.coffee'
import InventionLibrary from '~/plugins/starpeace-client/state/core/library/invention-library.coffee'
import LandLibrary from '~/plugins/starpeace-client/state/core/library/land-library.coffee'
import MapLibrary from '~/plugins/starpeace-client/state/core/library/map-library.coffee'
import NewsLibrary from '~/plugins/starpeace-client/state/core/library/news-library.coffee'
import OverlayLibrary from '~/plugins/starpeace-client/state/core/library/overlay-library.coffee'
import PlaneLibrary from '~/plugins/starpeace-client/state/core/library/plane-library.coffee'
import PlanetLibrary from '~/plugins/starpeace-client/state/core/library/planet-library.coffee'
import RoadLibrary from '~/plugins/starpeace-client/state/core/library/road-library.coffee'
import SignLibrary from '~/plugins/starpeace-client/state/core/library/sign-library.coffee'

import BuildingCache from '~/plugins/starpeace-client/state/core/cache/building-cache.js'
import CompanyCache from '~/plugins/starpeace-client/state/core/cache/company-cache.coffee'
import CorporationCache from '~/plugins/starpeace-client/state/core/cache/corporation-cache.js'
import GalaxyCache from '~/plugins/starpeace-client/state/core/cache/galaxy-cache.coffee'
import PlanetCache from '~/plugins/starpeace-client/state/core/cache/planet-cache.coffee'
import TycoonCache from '~/plugins/starpeace-client/state/core/cache/tycoon-cache.coffee'

import Options from '~/plugins/starpeace-client/state/options.js';

export default class CoreState {
  building_library: BuildingLibrary;
  concrete_library: ConcreteLibrary;
  effect_library: EffectLibrary;
  invention_library: InventionLibrary;
  land_library: LandLibrary;
  map_library: MapLibrary;
  news_library: NewsLibrary;
  overlay_library: OverlayLibrary;
  plane_library: PlaneLibrary;
  planet_library: PlanetLibrary;
  road_library: RoadLibrary;
  sign_library: SignLibrary;

  building_cache: BuildingCache;
  company_cache: CompanyCache;
  corporation_cache: CorporationCache;
  galaxy_cache: GalaxyCache;
  planet_cache: PlanetCache;
  tycoon_cache: TycoonCache;

  constructor () {
    this.building_library = markRaw(new BuildingLibrary());
    this.concrete_library = markRaw(new ConcreteLibrary());
    this.effect_library = markRaw(new EffectLibrary());
    this.invention_library = markRaw(new InventionLibrary());
    this.land_library = markRaw(new LandLibrary());
    this.map_library = markRaw(new MapLibrary());
    this.news_library = markRaw(new NewsLibrary());
    this.overlay_library = markRaw(new OverlayLibrary());
    this.plane_library = markRaw(new PlaneLibrary());
    this.planet_library = markRaw(new PlanetLibrary());
    this.road_library = markRaw(new RoadLibrary());
    this.sign_library = markRaw(new SignLibrary());

    this.building_cache = new BuildingCache();
    this.company_cache = new CompanyCache();
    this.corporation_cache = new CorporationCache();
    this.galaxy_cache = new GalaxyCache();
    this.planet_cache = new PlanetCache();
    this.tycoon_cache = new TycoonCache();
  }

  libraries (): Array<any> {
    return [this.building_library, this.concrete_library, this.effect_library, this.invention_library, this.land_library, this.map_library, this.news_library, this.overlay_library, this.plane_library, this.planet_library, this.road_library, this.sign_library];
  }
  caches (): Array<any> {
    return [this.building_cache, this.company_cache, this.corporation_cache, this.galaxy_cache, this.planet_cache, this.tycoon_cache];
  }

  reset_multiverse (): void {
    for (const library of this.libraries()) {
      library.reset_multiverse();
    }
    for (const library of this.caches()) {
      library.reset_multiverse();
    }
  }
  reset_planet (): void {
    for (const library of this.libraries()) {
      library.reset_planet();
    }
    for (const library of this.caches()) {
      library.reset_planet();
    }
  }

  has_assets (languageCode: string, mapId: string, planetType: string): boolean {
    return this.building_library.has_assets() && this.concrete_library.has_assets() && this.effect_library.has_assets() &&
        this.land_library.has_assets(planetType) && this.map_library.has_assets(mapId) &&
        this.news_library.has_metadata(languageCode) && this.overlay_library.has_assets() && this.plane_library.has_assets() &&
        this.road_library.has_assets() && this.sign_library.has_assets();
  }

  has_metadata (): boolean {
    return this.building_library.has_metadata() && this.invention_library.has_metadata() && this.planet_library.has_metadata();
  }
}
