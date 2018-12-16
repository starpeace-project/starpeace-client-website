
import moment from 'moment'
import Vue from 'vue'

import BuildingLibrary from '~/plugins/starpeace-client/state/core/library/building-library.coffee'
import ConcreteLibrary from '~/plugins/starpeace-client/state/core/library/concrete-library.coffee'
import EffectLibrary from '~/plugins/starpeace-client/state/core/library/effect-library.coffee'
import InventionLibrary from '~/plugins/starpeace-client/state/core/library/invention-library.coffee'
import LandLibrary from '~/plugins/starpeace-client/state/core/library/land-library.coffee'
import MapLibrary from '~/plugins/starpeace-client/state/core/library/map-library.coffee'
import NewsLibrary from '~/plugins/starpeace-client/state/core/library/news-library.coffee'
import OverlayLibrary from '~/plugins/starpeace-client/state/core/library/overlay-library.coffee'
import PlaneLibrary from '~/plugins/starpeace-client/state/core/library/plane-library.coffee'
import RoadLibrary from '~/plugins/starpeace-client/state/core/library/road-library.coffee'
import TranslationsLibrary from '~/plugins/starpeace-client/state/core/library/translations-library.coffee'

import BuildingCache from '~/plugins/starpeace-client/state/core/cache/building-cache.coffee'
import CompanyCache from '~/plugins/starpeace-client/state/core/cache/company-cache.coffee'
import CorporationCache from '~/plugins/starpeace-client/state/core/cache/corporation-cache.coffee'
import PlanetsCache from '~/plugins/starpeace-client/state/core/cache/planets-cache.coffee'
import SystemsCache from '~/plugins/starpeace-client/state/core/cache/systems-cache.coffee'
import TycoonCache from '~/plugins/starpeace-client/state/core/cache/tycoon-cache.coffee'

import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class CoreState
  constructor: (@options) ->
    @building_library = new BuildingLibrary()
    @concrete_library = new ConcreteLibrary()
    @effect_library = new EffectLibrary()
    @invention_library = new InventionLibrary()
    @land_library = new LandLibrary()
    @map_library = new MapLibrary()
    @news_library = new NewsLibrary()
    @overlay_library = new OverlayLibrary()
    @plane_library = new PlaneLibrary()
    @road_library = new RoadLibrary()
    @translations_library = new TranslationsLibrary()

    @building_cache = new BuildingCache()
    @company_cache = new CompanyCache()
    @corporation_cache = new CorporationCache()
    @planets_cache = new PlanetsCache()
    @systems_cache = new SystemsCache()
    @tycoon_cache = new TycoonCache()

    @building_cache.reset_state()
    @company_cache.reset_state()
    @corporation_cache.reset_state()
    @planets_cache.reset_state()
    @systems_cache.reset_state()
    @tycoon_cache.reset_state()

  has_assets: (language_code, map_id, planet_type) ->
    # console.log "#{@building_library.has_assets()} #{@concrete_library.has_assets()} #{@effect_library.has_assets()} #{@invention_library.has_metadata()} #{@land_library.has_assets(planet_type)} #{@map_library.has_assets(map_id)} #{@news_library.has_metadata()} #{@overlay_library.has_assets()} #{@plane_library.has_assets()} #{@road_library.has_assets()} #{@translations_library.has_metadata(language_code)}"
    @building_library.has_assets() && @concrete_library.has_assets() && @effect_library.has_assets() &&
        @invention_library.has_metadata() && @land_library.has_assets(planet_type) && @map_library.has_assets(map_id) &&
        @news_library.has_metadata() && @overlay_library.has_assets() && @plane_library.has_assets() &&
        @road_library.has_assets() && @translations_library.has_metadata(language_code)
