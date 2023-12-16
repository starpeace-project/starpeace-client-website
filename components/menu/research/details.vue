<template lang='pug'>
.research-container
  .is-flex.is-flex-direction-column.p-3.invention-details(v-if='selectedInvention')
    .is-flex-grow-0.invention-selected-details
      .invention-name
        span(v-if='selectedInvention') {{ $translate(selectedInvention.name) }}
      .invention-description
        span(v-if='selectedInvention') {{ $translate(selectedInvention.description) }}
      .invention-cost
        span.sp-kv-key {{ $translate('ui.menu.research.cost.label') }}:
        span.cost-value {{ $format_money(inventionCost) }}
      .invention-level(v-if='inventionLevel && inventionLevel.label')
        span.sp-kv-key {{ $translate('ui.menu.research.level.label') }}:
        span.level-value {{ $translate(inventionLevel.label) }}

      .invention-requires.is-flex
        span.sp-kv-key.mt-2 {{ $translate('ui.menu.research.requires.label') }}:
        span.is-inline-flex.is-flex-direction-column.ml-3
          span.none-value(v-if="inventionRequires.length == 0") {{ $translate('ui.menu.research.none.label') }}
          ul.inventions
            li(v-for='option in inventionRequires')
              a(@click.stop.prevent='selectInvention(option.id)') {{ $translate(option.name) }}

      .invention-allows.is-flex
        span.sp-kv-key.mt-2 {{ $translate('ui.menu.research.allows.label') }}:
        span.is-inline-flex.is-flex-direction-column.ml-3
          span.none-value(v-if="inventionAllows.length == 0") {{ $translate('ui.menu.research.none.label') }}
          ul.inventions
            li(v-for='option in inventionAllowsTruncated')
              a(@click.stop.prevent='selectInvention(option.id)') {{ $translate(option.name) }}
            li(v-if='inventionAllows.length > 5') {{ inventionAllows.length - 3 }} {{ $translate('ui.menu.research.others.label') }}
            li(v-else-if='inventionAllows.length > 4') 1 {{ $translate('ui.menu.research.other.label') }}

    .is-flex-grow-1.mt-2.inverse-card.sp-scrollbar.p-3.invention-properties(v-if='inventionProperties.length')
      ul.inventions
        li(v-for='option in inventionProperties')
          span.property-label(:class='option.class') {{ option.type }}:
          span.property-value(:class='option.class') {{ option.text_parts[0] }}{{ option.text_parts[1] }}{{ option.text_parts[2] }}
      div.is-clearfix

    .is-flex-grow-0.mt-2.actions-container(v-if="inventionStatus != 'NONE'")
      .action-row.invention-status
        span.sp-kv-key {{$translate('ui.menu.research.status.label')}}:
        span.invention-status-value.available(v-if="inventionStatus == 'AVAILABLE'") {{ $translate('ui.menu.research.details.status.available') }}
        span.invention-status-value.blocked(v-else-if="inventionStatus == 'AVAILABLE_BUILDING'") {{ $translate(first_allowing_building_name) }} {{ $translate('ui.menu.research.details.status.building_required') }}
        span.invention-status-value.blocked(v-else-if="inventionStatus == 'AVAILABLE_LEVEL'") {{ $translate('ui.menu.research.details.status.level_required') }}
        span.invention-status-value.blocked(v-else-if="inventionStatus == 'AVAILABLE_BLOCKED'") {{ $translate('ui.menu.research.details.status.dependencies_required') }}
        span.invention-status-value.pending(v-else-if="inventionStatus == 'PENDING'")
          span(v-if="selectedInventionActive") {{ $translate('ui.menu.research.details.status.in_progress') }}
          span(v-else-if="selectedInventionPending") {{ $translate('ui.menu.research.details.status.queued') }}
          span(v-if="selectedInventionProgress > 0 && !(selectedInventionProgress >= 100)")
            |
            | - {{selectedInventionProgress}}%
        span.invention-status-value.completed(v-else-if="inventionStatus == 'COMPLETED' || inventionStatus == 'COMPLETED_SUPPORT'") {{ $translate('ui.menu.research.details.status.completed') }}

      .action-row
        button.button.is-fullwidth.is-starpeace(v-if="inventionStatus == 'AVAILABLE'" @click.stop.prevent='queueInvention' :disabled='actionsDisabled') {{ $translate('ui.menu.research.actions.start.label') }}
        button.button.is-fullwidth.is-starpeace(v-else-if="inventionStatus == 'AVAILABLE_BUILDING' || inventionStatus == 'AVAILABLE_LEVEL' || inventionStatus == 'AVAILABLE_BLOCKED'" disabled) {{ $translate('ui.menu.research.actions.start.label') }}
        button.button.is-fullwidth.is-starpeace(v-else-if="inventionStatus == 'PENDING'" @click.stop.prevent='sellInvention' :disabled='actionsDisabled') {{ $translate('ui.menu.research.actions.cancel.label') }}
        button.button.is-fullwidth.is-starpeace(v-else-if="inventionStatus == 'COMPLETED'" @click.stop.prevent='sellInvention' :disabled='actionsDisabled') {{ $translate('ui.menu.research.actions.sell.label') }}
        button.button.is-fullwidth.is-starpeace(v-else-if="inventionStatus == 'COMPLETED_SUPPORT'" disabled) {{ $translate('ui.menu.research.actions.sell.label') }}

</template>

<script lang='ts'>
import { Level } from '@starpeace/starpeace-assets-types';
import _ from 'lodash';

import Company from '~/plugins/starpeace-client/company/company';
import Corporation from '~/plugins/starpeace-client/corporation/corporation';
import CompanyInventions from '~/plugins/starpeace-client/invention/company-inventions';
import ClientState from '~/plugins/starpeace-client/state/client-state';

export default {
  props: {
    clientState: { type: ClientState, required: true },

    corporation: { type: Corporation, required: false },
    company: { type: Company, required: false },

    companyInventions: { type: CompanyInventions, required: false }
  },

  mounted () {
    this.clientState?.options?.subscribe_options_listener(() => this.$forceUpdate());
  },

  computed: {
    selectedInventionId (): string | undefined {
      return this.clientState.interface.inventions_selected_invention_id ?? undefined;
    },
    selectedInvention (): any | undefined {
      return this.selectedInventionId ? this.clientState.core.invention_library.metadata_for_id(this.selectedInventionId) : undefined;
    },

    corporationLevelId (): string | undefined {
      return this.corporation?.level_id ?? undefined;
    },
    corporationLevel (): any | undefined {
      return this.corporationLevelId ? this.clientState.core.planet_library.level_for_id(this.corporationLevelId) : undefined;
    },

    companyId (): string | undefined {
      return this.clientState.player.company_id ?? undefined;
    },
    companySeal (): any | undefined {
      return this.company?.sealId ?? undefined;
    },

    companyBuildingIds (): Array<any> {
      return (this.companyId ? this.clientState.corporation.buildings_ids_by_company_id[this.companyId] : undefined) ?? [];
    },
    company_building_definition_ids (): Set<string> {
      return new Set(_.compact(_.map(this.companyBuildingIds, (id) => this.clientState.core.building_cache.building_for_id(id)?.definition_id)));
    },

    companyHasAllowingBuilding (): boolean {
      if (!this.invention_allowing_building_ids.length) return true;
      for (const id of this.invention_allowing_building_ids) {
        if (this.company_building_definition_ids.has(id)) {
          return true;
        }
      }
      return false;
    },

    inventionLevelId (): string | undefined {
      return this.selectedInvention?.properties?.levelId ?? undefined;
    },
    inventionLevel (): Level | undefined {
      return this.inventionLevelId ? this.clientState.core.planet_library.level_for_id(this.inventionLevelId) : undefined;
    },
    inventionCost (): number {
      return this.selectedInvention?.properties?.price ?? 0;
    },

    invention_allowing_building_ids (): Array<string> {
      if (!this.companySeal || !this.selectedInventionId) return [];
      const building_ids = this.clientState.core.invention_library.allowing_building_by_seal_id[this.companySeal]?.[this.selectedInventionId];
      return building_ids?.size ? Array.from(building_ids) : [];
    },
    first_allowing_building_id (): string | undefined {
      return this.invention_allowing_building_ids.length ? this.invention_allowing_building_ids[0] : undefined;
    },
    first_allowing_building_name (): string {
      return (this.first_allowing_building_id ? this.clientState.core.building_library.metadata_by_id[this.first_allowing_building_id]?.name : undefined) ?? '';
    },

    invention_ids_for_company () {
      if (!this.clientState.player.company_id) return [];
      return _.map(this.clientState.inventions_for_company(), 'id');
    },

    inventionRequires () {
      const upstream = [];
      for (const invention_id of (this.selectedInvention ? this.clientState.core.invention_library.upstream_ids_for(this.selectedInvention.id) : [])) {
        const metadata = this.clientState.core.invention_library.metadata_for_id(invention_id);
        if (metadata && this.invention_ids_for_company.indexOf(metadata.id) >= 0) {
          upstream.push({
            id: metadata.id,
            name: metadata.name
          });
        }
      }
      return _.orderBy(upstream, [(invention) => this.$translate(invention.name)], ['asc']);
    },

    inventionAllows (): Array<any> {
      if (!this.selectedInvention?.id) return [];
      const downstream = [];
      for (const invention_id of (this.selectedInvention ? (this.clientState.core.invention_library.downstream_ids_for(this.selectedInvention.id) ?? []) : [])) {
        const metadata = this.clientState.core.invention_library.metadata_for_id(invention_id);
        if (metadata && this.invention_ids_for_company.indexOf(metadata.id) >= 0) {
          downstream.push({
            id: metadata.id,
            name: metadata.name
          });
        }
      }
      return _.orderBy(downstream, [(invention) => this.$translate(invention.name)], ['asc']);
    },
    inventionAllowsTruncated (): Array<any> {
      return new Array(this.inventionAllows).slice(0, 3);
    },

    inventionProperties (): Array<any> {
      const properties = [];
      if (this.selectedInvention) {
        const properties_by_type: Record<string, any> = {}
        for (const [key, value] of Object.entries(this.selectedInvention.properties)) {
          properties_by_type[key] = value;
        }

        if (properties_by_type.prestige) properties.push(this.property_points('Prestige', properties_by_type.prestige));
        if (properties_by_type.nobility) properties.push(this.property_points('Nobility', properties_by_type.nobility));

        if (properties_by_type.quality) properties.push(this.property_points('Quality', properties_by_type.quality));
        if (properties_by_type.desirability) properties.push(this.property_points('Desirability', properties_by_type.desirability));
        if (properties_by_type.efficiency) properties.push(this.property_percent('Efficiency', properties_by_type.efficiency));

        if (properties_by_type.beauty) properties.push(this.property_percent('Beauty', properties_by_type.beauty));
        if (properties_by_type.environment) properties.push(this.property_percent('Environment', properties_by_type.environment));
        if (properties_by_type.maintenance) properties.push(this.property_percent('Maintenance', properties_by_type.maintenance));
        if (properties_by_type.privacy) properties.push(this.property_percent('Privacy', properties_by_type.privacy));
        if (properties_by_type.security) properties.push(this.property_percent('Security', properties_by_type.security));
      }
      return properties;
    },

    selectedInventionActive (): boolean {
      return this.companyInventions?.activeInventionId === this.selectedInventionId;
    },
    selectedInventionPending (): boolean {
      return !!this.selectedInventionId && (this.companyInventions?.pendingIds?.indexOf(this.selectedInventionId) ?? -1) >= 0;
    },
    selectedInventionProgress (): number {
      if (!this.selectedInventionActive || !this.companyInventions) {
        return -1;
      }
      const price = this.clientState.core.invention_library.metadata_for_id(this.selectedInventionId)?.properties?.price ?? 1;
      return Math.round(100 * this.companyInventions.activeInvestment / price);
    },

    inventionStatus () {
      if (!this.selectedInvention || !this.companyInventions || !this.companySeal) return 'NONE';
      if (this.selectedInventionId && this.companyInventions?.isQueued(this.selectedInventionId)) {
        return 'PENDING';
      }
      else if (this.selectedInventionId && this.companyInventions?.completedIds?.has(this.selectedInventionId)) {
        if (this.inventionAllows.find((allows) => this.companyInventions?.isQueued(allows.id)|| this.companyInventions?.isCompleted(allows.id))) {
          return 'COMPLETED_SUPPORT';
        }
        return 'COMPLETED';
      }
      else {
        if (this.inventionLevel && this.inventionLevel.level > (this.corporationLevel?.level ?? 0)) {
          return 'AVAILABLE_LEVEL';
        }
        if (this.inventionRequires.find((requires) => !this.companyInventions?.isCompleted(requires.id))) {
          return 'AVAILABLE_BLOCKED';
        }
        if (!this.companyHasAllowingBuilding) {
          return 'AVAILABLE_BUILDING';
        }
        return 'AVAILABLE';
      }
    },

    actionsDisabled () {
      if (!this.companyInventions || !this.companyId) return true;
      if (!!this.clientState.ajax_state.requestMutexByTypeKey['player.sell_invention']?.[this.companyId] || !!this.clientState.ajax_state.requestMutexByTypeKey['player.queue_invention']?.[this.companyId]) return true;
      return !this.selectedInventionId || this.companyInventions?.canceledIds?.has(this.selectedInventionId);
    }
  },

  methods: {
    property_points (type: string, value: number): any {
      return {
        type: type,
        text_parts: [(value > 0 ? '+' : ''), value, ' pts'],
        class: value > 0 ? 'positive' : value < 0 ? 'negative' : ''
      };
    },
    property_percent (type: string, value: number): any {
      return {
        type: type,
        text_parts: [(value > 0 ? '+' : ''), value, '%'],
        class: value > 0 ? 'positive' : value < 0 ? 'negative' : ''
      };
    },

    selectInvention (invention_id: string): void {
      this.clientState.interface.inventions_selected_invention_id = invention_id;
    },

    async sellInvention (): Promise<void> {
      if (!this.selectedInventionId || !this.companyInventions || !this.companyId || (this.inventionStatus !== 'PENDING' && this.inventionStatus !== 'COMPLETED')) return;
      try {
        await this.$starpeaceClient.managers.invention_manager.sellInvention(this.companyId, this.selectedInventionId);
        this.$forceUpdate();
      }
      catch (err) {
        console.error(err);
      }
    },

    async queueInvention (): Promise<void> {
      if (!this.selectedInventionId || !this.companyInventions || !this.companyId || this.inventionStatus !== 'AVAILABLE') return;

      try {
        await this.$starpeaceClient.managers.invention_manager.queueInvention(this.companyId, this.selectedInventionId);
        this.$forceUpdate();
      }
      catch (err) {
        console.error(err);
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.research-container
  grid-column: 3 / 4
  grid-row: 1 / 2
  position: relative


.invention-details
  color: lighten($sp-primary, 10%)
  font-size: 1.15rem
  height: 100%

  .invention-name
    color: #ddd
    font-size: 1.5rem
    font-weight: bold
    margin-bottom: .5rem
    min-height: 2rem

  .invention-cost
    margin-top: 1rem
    min-height: 2rem

    .cost-value
      color: #ddd
      font-size: 1.3rem
      font-weight: bold
      margin-left: .75rem

  .invention-level
    margin-top: .25rem
    min-height: 2rem

    .level-value
      font-size: 1.3rem
      font-weight: bold
      margin-left: .75rem
      text-transform: capitalize

  .invention-requires
    margin-top: 1rem
    min-height: 2rem

  .invention-allows
    margin-top: .5rem
    min-height: 2rem

  .invention-requires,
  .invention-allows
    .none-value
      font-weight: lighter
      opacity: .7

    ul
      &.inventions
        li
          &:not(:first-child)
            margin-top: .25rem

        a
          color: lighten($sp-primary, 15%)
          font-size: 1.25rem

  .invention-properties
    background-color: #000D07
    overflow-y: auto

    ul
      li
        font-weight: bold

        &:not(:first-child)
          margin-top: .25rem

    .positive
      color: $color-positive

    .negative
      color: $color-negative

    .property-value
      font-size: 1.3rem
      margin-left: .75rem

  .actions-container
    .action-row
      &.invention-status
        min-height: 4rem
        margin-bottom: 1rem

        .invention-status-value
          font-size: 1.3rem
          margin-left: .75rem

          &.available
            font-weight: bold

          &.blocked
            color: $color-negative

          &.pending
            font-style: italic

          &.completed
            font-weight: bold
            color: $color-positive

      .button
        letter-spacing: .1rem
        text-transform: uppercase

</style>
