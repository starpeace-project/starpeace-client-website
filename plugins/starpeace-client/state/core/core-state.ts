import { markRaw } from 'vue';

import BuildingLibrary from '~/plugins/starpeace-client/state/core/library/building-library.coffee';
import ConcreteLibrary from '~/plugins/starpeace-client/state/core/library/concrete-library.js';
import EffectLibrary from '~/plugins/starpeace-client/state/core/library/effect-library.js';
import InventionLibrary from '~/plugins/starpeace-client/state/core/library/invention-library.coffee';
import LandLibrary from '~/plugins/starpeace-client/state/core/library/land-library.js';
import MapLibrary from '~/plugins/starpeace-client/state/core/library/map-library.js';
import NewsLibrary from '~/plugins/starpeace-client/state/core/library/news-library.js';
import OverlayLibrary from '~/plugins/starpeace-client/state/core/library/overlay-library.js';
import PlaneLibrary from '~/plugins/starpeace-client/state/core/library/plane-library.js';
import PlanetLibrary from '~/plugins/starpeace-client/state/core/library/planet-library.js';
import RoadLibrary from '~/plugins/starpeace-client/state/core/library/road-library.js';
import SignLibrary from '~/plugins/starpeace-client/state/core/library/sign-library.js';

import BuildingCache from '~/plugins/starpeace-client/state/core/cache/building-cache.js';
import CompanyCache from '~/plugins/starpeace-client/state/core/cache/company-cache.js';
import CorporationCache from '~/plugins/starpeace-client/state/core/cache/corporation-cache.js';
import GalaxyCache from '~/plugins/starpeace-client/state/core/cache/galaxy-cache.js';
import PlanetCache from '~/plugins/starpeace-client/state/core/cache/planet-cache.coffee';
import TycoonCache from '~/plugins/starpeace-client/state/core/cache/tycoon-cache.coffee';


export class CoreLoadingStatus {
  statusByType: Record<string, boolean>;

  constructor (statusByType: Record<string, boolean>) {
    this.statusByType = statusByType;
  }

  get loadedCount (): number {
    return Object.values(this.statusByType).filter(v => !!v).length;
  }

  get totalCount (): number {
    return Object.keys(this.statusByType).length;
  }

  get loaded (): boolean {
    if (this.loadedCount < this.totalCount) {
      return false;
    }
    return this.loadedCount >= this.totalCount;
  }

  get pendingTypes (): Array<string> {
    return Object.entries(this.statusByType).filter(([_type, status]) => !status).map(([type, _status]) => type).sort();
  }
}

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
      if (library.reset_planet) {
        library.reset_planet();
      }
      else if (library.resetPlanet) {
        library.resetPlanet();
      }
    }
    for (const cache of this.caches()) {
      if (cache.reset_planet) {
        cache.reset_planet();
      }
      else if (cache.resetPlanet) {
        cache.resetPlanet();
      }
    }
  }

  has_assets (languageCode: string, mapId: string, planetType: string): CoreLoadingStatus {
    return new CoreLoadingStatus({
      building: this.building_library.has_assets(),
      concrete: this.concrete_library.has_assets(),
      effect: this.effect_library.has_assets(),
      land: this.land_library.has_assets(planetType),
      map: this.map_library.has_assets(mapId),
      news: this.news_library.has_metadata(languageCode),
      overlay: this.overlay_library.has_assets(),
      plane: this.plane_library.has_assets(),
      road: this.road_library.has_assets(),
      sign: this.sign_library.has_assets()
    });
  }

  has_metadata (): CoreLoadingStatus {
    return new CoreLoadingStatus({
      building: this.building_library.has_metadata(),
      invention: this.invention_library.has_metadata(),
      planet: this.planet_library.has_metadata().loaded
    });
  }
}
