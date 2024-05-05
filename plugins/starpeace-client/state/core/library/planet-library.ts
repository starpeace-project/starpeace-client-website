import _ from 'lodash';
import type { CityZone, CompanySeal, IndustryCategory, IndustryType, Level, ResourceType, ResourceUnit } from '@starpeace/starpeace-assets-types';

import Library from '~/plugins/starpeace-client/state/core/library/library'
import { CoreLoadingStatus } from '~/plugins/starpeace-client/state/core/core-state';
import type RankingType from '~/plugins/starpeace-client/corporation/ranking-type';
import OverlayType from '~/plugins/starpeace-client/overlay/overlay-type';

export default class PlanetLibrary extends Library {
  core_metadata: any = undefined;

  city_zones_by_id: Record<string, CityZone> = {};
  city_zones_by_value: Record<string, CityZone> = {};

  industry_categories_by_id: Record<string, IndustryCategory> = {};
  industry_types_by_id: Record<string, IndustryType> = {};

  levels_by_id: Record<string, Level> = {};
  overlayTypeById: Record<string, OverlayType> = {};
  ranking_types_by_id: Record<string, RankingType> = {};

  resource_types_by_id: Record<string, ResourceType> = {};
  resource_units_by_id: Record<string, ResourceUnit> = {};

  company_seals_by_id: Record<string, CompanySeal> = {};

  constructor () {
    super()
    this.reset_planet();
  }

  reset_planet (): void {
    this.city_zones_by_id = {};
    this.city_zones_by_value = {};

    this.industry_categories_by_id = {};
    this.industry_types_by_id = {};
    this.levels_by_id = {};
    this.overlayTypeById = {};
    this.ranking_types_by_id = {};
    this.resource_types_by_id = {};
    this.resource_units_by_id = {};
    this.company_seals_by_id = {};
  }

  has_metadata (): CoreLoadingStatus {
    return new CoreLoadingStatus({
      cityZone: Object.keys(this.city_zones_by_id || {}).length > 0,
      industryCategory: Object.keys(this.industry_categories_by_id || {}).length > 0,
      industryType: Object.keys(this.industry_types_by_id || {}).length > 0,
      level: Object.keys(this.levels_by_id || {}).length > 0,
      overlayType: Object.keys(this.overlayTypeById || {}).length > 0,
      rankingType: Object.keys(this.ranking_types_by_id || {}).length > 0,
      resourceType: Object.keys(this.resource_types_by_id || {}).length > 0,
      resourceUnit: Object.keys(this.resource_units_by_id || {}).length > 0,
      seal: Object.keys(this.company_seals_by_id || {}).length > 0
    });
  }

  zone_for_id (cityZoneId: string): CityZone | undefined {
    return this.city_zones_by_id[cityZoneId];
  }
  zone_for_value (value: string): CityZone | undefined {
    return this.city_zones_by_value[value];
  }
  load_city_zones (cityZones: Array<CityZone>): void {
    for (const zone of (cityZones ?? [])) {
      this.city_zones_by_id[zone.id] = zone;
      this.city_zones_by_value[zone.value] = zone;
    }
  }

  category_for_id (industryCategoryId: string): IndustryCategory | undefined {
    return this.industry_categories_by_id[industryCategoryId];
  }
  categories_for_inventions (): Array<string> {
    return Object.values(this.industry_categories_by_id).map(i => i.id).filter(id => id !== 'NONE');
  }
  load_industry_categories (categories: Array<IndustryCategory>): void {
    for (const category of (categories ?? [])) {
      this.industry_categories_by_id[category.id] = category;
    }
  }

  type_for_id (typeId: string): IndustryType | undefined {
    return this.industry_types_by_id[typeId];
  }
  load_industry_types (types: Array<IndustryType>): void {
    for (const type of (types ?? [])) {
      this.industry_types_by_id[type.id] = type;
    }
  }

  level_for_id (levelId: string): Level | undefined {
    return this.levels_by_id[levelId];
  }
  next_level_for_id (levelId: string): Level | undefined {
    const currentLevel = this.levels_by_id[levelId]?.level
    const orderedLevels = _.orderBy(Object.values(this.levels_by_id), ['level'], ['asc'])
    const index = orderedLevels.findIndex((l) => l.level > currentLevel)
    return index >= 0 ? orderedLevels[index] : undefined;
  }
  load_levels (levels: Array<Level>): void {
    for (const level of (levels ?? [])) {
      this.levels_by_id[level.id] = level
    }
  }

  overlayTypeForId (typeId: string): OverlayType | undefined {
    return this.overlayTypeById[typeId];
  }
  overlayTypeForParentId (parentId: string): Array<OverlayType> {
    return Object.values(this.overlayTypeById ?? {}).filter((type) => type.parentId === parentId);
  }
  overlayTypeRoots (): Array<OverlayType> {
    return Object.values(this.overlayTypeById ?? {}).filter((type) => !type.parentId?.length);
  }
  allOverlayTypes (): Array<OverlayType> {
    return Object.values(this.overlayTypeById ?? {});
  }
  loadOverlayTypes (types: Array<OverlayType>): void {
    for (const type of (types ?? [])) {
      this.overlayTypeById[type.id] = type;
    }
  }

  ranking_type_for_id (typeId: string): RankingType | undefined {
    return this.ranking_types_by_id[typeId];
  }
  ranking_type_for_parent_id (parentId: string): Array<RankingType> {
    return Object.values(this.ranking_types_by_id ?? {}).filter((type) => type.parent_id === parentId);
  }
  ranking_type_roots (): Array<RankingType> {
    return Object.values(this.ranking_types_by_id).filter((type) => !type.parent_id?.length);
  }
  load_ranking_types (types: Array<RankingType>): void {
    for (const type of (types ?? [])) {
      this.ranking_types_by_id[type.id] = type;
    }
  }

  all_resource_types (): Array<ResourceType> {
    return Object.values(this.resource_types_by_id);
  }
  resource_type_for_id (typeId: string): ResourceType | undefined {
    return this.resource_types_by_id[typeId];
  }
  load_resource_types (types: Array<ResourceType>): void {
    for (const type of (types ?? [])) {
      this.resource_types_by_id[type.id] = type;
    }
  }

  resource_unit_for_id (unitId: string): ResourceUnit | undefined {
    return this.resource_units_by_id[unitId];
  }
  load_resource_units (units: Array<ResourceUnit>): void {
    for (const unit of (units ?? [])) {
      this.resource_units_by_id[unit.id] = unit;
    }
  }

  seal_for_id (sealId: string): CompanySeal | undefined {
    return this.company_seals_by_id[sealId];
  }
  all_seal_ids_non_ifel (): Array<string> {
    return Object.values(this.company_seals_by_id).map(s => s.id).filter(id => id !== 'GEN');
  }
  load_company_seals (seals: Array<CompanySeal>): void {
    for (const seal of (seals ?? [])) {
      this.company_seals_by_id[seal.id] = seal;
    }
  }
}
