<template lang='pug'>
.research-container
  .invention-details(v-if="selected_invention != null")
    .invention-selected-details
      .invention-name {{$translate(invention_name)}}
      .invention-description {{$translate(invention_description)}}
      .invention-cost
        span.sp-kv-key {{$translate('ui.menu.research.cost.label')}}:
        span.cost-value {{invention_cost}}
      .invention-level(v-if="invention_level_label != null")
        span.sp-kv-key {{$translate('ui.menu.research.level.label')}}:
        span.level-value {{$translate(invention_level_label)}}

      .invention-requires.is-flex
        span.sp-kv-key.mt-2 {{$translate('ui.menu.research.requires.label')}}:
        span.is-inline-flex.is-flex-direction-column.ml-3
          span.none-value(v-if="invention_requires.length == 0") {{$translate('ui.menu.research.none.label')}}
          ul.inventions
            li(v-for='option in sort_inventions(invention_requires)')
              a(@click.stop.prevent="select_invention(option.id)") {{$translate(option.name)}}

      .invention-allows.is-flex
        span.sp-kv-key.mt-2 {{$translate('ui.menu.research.allows.label')}}:
        span.is-inline-flex.is-flex-direction-column.ml-3
          span.none-value(v-if="invention_allows.length == 0") {{$translate('ui.menu.research.none.label')}}
          ul.inventions
            li(v-for='option in sort_inventions(invention_allows).slice(0, 3)')
              a(@click.stop.prevent="select_invention(option.id)") {{$translate(option.name)}}
            li(v-if='invention_allows.length > 5') {{invention_allows.length - 3}} {{$translate('ui.menu.research.others.label')}}
            li(v-else-if='invention_allows.length > 4') 1 {{$translate('ui.menu.research.other.label')}}

      .invention-properties.inverse-card(v-if='invention_properties.length')
        ul.inventions
          li(v-for='option in invention_properties')
            span.property-label(:class='option.class') {{option.type}}:
            span.property-value(:class='option.class') {{option.text_parts[0]}}{{option.text_parts[1]}}{{option.text_parts[2]}}
        div.is-clearfix

    .actions-container(v-if="invention_status != 'NONE'")
      .action-row.invention-status
        span.sp-kv-key {{$translate('ui.menu.research.status.label')}}:
        span.invention-status-value.available(v-if="invention_status == 'AVAILABLE'") {{$translate('ui.menu.research.details.status.available')}}
        span.invention-status-value.blocked(v-else-if="invention_status == 'AVAILABLE_BUILDING'") {{$translate(first_allowing_building_name)}} {{$translate('ui.menu.research.details.status.building_required')}}
        span.invention-status-value.blocked(v-else-if="invention_status == 'AVAILABLE_LEVEL'") {{$translate('ui.menu.research.details.status.level_required')}}
        span.invention-status-value.blocked(v-else-if="invention_status == 'AVAILABLE_BLOCKED'") {{$translate('ui.menu.research.details.status.dependencies_required')}}
        span.invention-status-value.pending(v-else-if="invention_status == 'PENDING'")
          span(v-if="selected_invention_active") {{$translate('ui.menu.research.details.status.in_progress')}}
          span(v-else-if="selected_invention_pending") {{$translate('ui.menu.research.details.status.queued')}}
          span(v-if="selected_invention_progress > 0 && selected_invention_progress < 100")
            |
            | - {{selected_invention_progress}}%
        span.invention-status-value.completed(v-else-if="invention_status == 'COMPLETED' || invention_status == 'COMPLETED_SUPPORT'") {{$translate('ui.menu.research.details.status.completed')}}

      .action-row
        button.button.is-fullwidth.is-starpeace(v-if="invention_status == 'AVAILABLE'" @click.stop.prevent='queue_invention' :disabled='actions_disabled') {{$translate('ui.menu.research.actions.start.label')}}
        button.button.is-fullwidth.is-starpeace(v-else-if="invention_status == 'AVAILABLE_BUILDING' || invention_status == 'AVAILABLE_LEVEL' || invention_status == 'AVAILABLE_BLOCKED'", disabled=true) {{$translate('ui.menu.research.actions.start.label')}}
        button.button.is-fullwidth.is-starpeace(v-else-if="invention_status == 'PENDING'" @click.stop.prevent='sell_invention' :disabled='actions_disabled') {{$translate('ui.menu.research.actions.cancel.label')}}
        button.button.is-fullwidth.is-starpeace(v-else-if="invention_status == 'COMPLETED'" @click.stop.prevent='sell_invention' :disabled='actions_disabled') {{$translate('ui.menu.research.actions.sell.label')}}
        button.button.is-fullwidth.is-starpeace(v-else-if="invention_status == 'COMPLETED_SUPPORT'" disabled=true) {{$translate('ui.menu.research.actions.sell.label')}}

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default {
  props: {
    ajax_state: Object,
    client_state: { type: ClientState, required: true }
  },

  mounted () {
    this.client_state?.options?.subscribe_options_listener(() => this.$forceUpdate());
  },

  computed: {
    is_ready (): boolean { return this.client_state?.workflow_status === 'ready'; },

    selected_invention_id (): string { return this.client_state.interface.inventions_selected_invention_id; },
    selected_invention (): any | null { return this.selected_invention_id ? this.client_state.core.invention_library.metadata_for_id(this.selected_invention_id) : null; },

    corporation_level_id (): string | null { return this.client_state.current_corporation_metadata()?.level_id; },
    corporation_level (): any { return this.corporation_level_id ? this.client_state.core.planet_library.level_for_id(this.corporation_level_id) : null; },

    invention_name () { return this.selected_invention?.name ?? ''; },
    invention_description () { return this.selected_invention?.description ?? ''; },
    invention_level_id (): string | any { return this.selected_invention?.properties?.levelId; },
    invention_level (): any | null { return this.invention_level_id ? this.client_state.core.planet_library.level_for_id(this.invention_level_id) : null; },
    invention_level_label (): string { return this.invention_level?.label ?? ''; },
    invention_cost () {
      const cost = this.selected_invention?.properties?.price ?? 0;
      return cost > 0 ? `$${Utils.format_money(cost)}` : '';
    },

    invention_allowing_building_ids () {
      if (!this.company_seal || !this.selected_invention_id) return [];
      const building_ids = this.client_state.core.invention_library.allowing_building_by_seal_id[this.company_seal]?.[this.selected_invention_id];
      return building_ids?.size ? Array.from(building_ids) : [];
    },
    first_allowing_building_id () { return this.invention_allowing_building_ids.length ? this.invention_allowing_building_ids[0] : null; },
    first_allowing_building_name () { return this.first_allowing_building_id ? this.client_state.core.building_library.metadata_by_id[this.first_allowing_building_id]?.name : ''; },

    invention_ids_for_company () {
      if (!this.client_state.player.company_id || !this.is_ready) return [];
      return _.map(this.client_state.inventions_for_company(), 'id');
    },

    invention_requires () {
      const upstream = [];
      for (const invention_id of (this.selected_invention ? this.client_state.core.invention_library.upstream_ids_for(this.selected_invention.id) : [])) {
        const metadata = this.client_state.core.invention_library.metadata_for_id(invention_id);
        if (metadata && this.invention_ids_for_company.indexOf(metadata.id) >= 0) {
          upstream.push({
            id: metadata.id,
            name: metadata.name
          });
        }
      }
      return upstream;
    },

    invention_allows () {
      if (!this.selected_invention?.id) return [];
      const downstream = [];
      for (const invention_id of (this.selected_invention ? (this.client_state.core.invention_library.downstream_ids_for(this.selected_invention.id) ?? []) : [])) {
        const metadata = this.client_state.core.invention_library.metadata_for_id(invention_id);
        if (metadata && this.invention_ids_for_company.indexOf(metadata.id) >= 0) {
          downstream.push({
            id: metadata.id,
            name: metadata.name
          });
        }
      }
      return downstream;
    },

    invention_properties () {
      const properties = [];
      if (this.selected_invention) {
        const properties_by_type: Record<string, any> = {}
        for (const [key, value] of Object.entries(this.selected_invention.properties)) {
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

    company_id (): string | null { return this.is_ready && this.client_state.player.company_id ? this.client_state.player.company_id : null; },
    company_seal (): any | null { return this.company_id ? this.client_state.current_company_metadata().seal_id : null; },
    company_inventions () { return this.company_id ? this.client_state.corporation.inventions_metadata_by_company_id[this.company_id] : null; },

    company_building_ids (): Array<any> { return this.company_id ? this.client_state.corporation.buildings_ids_by_company_id[this.company_id] ?? [] : []; },
    company_building_definition_ids (): Set<string> { return new Set(_.compact(_.map(this.company_building_ids, (id) => this.client_state.core.building_cache.building_metadata_by_id[id]?.definition_id))); },

    company_has_allowing_building () {
      if (!this.invention_allowing_building_ids.length || this.company_building_definition_ids.size) return false;
      for (const id of this.invention_allowing_building_ids) {
        if (this.company_building_definition_ids.has(id)) return true;
      }
      return false;
    },

    selected_invention_active (): boolean { return this.company_inventions?.activeInventionId === this.selected_invention_id; },
    selected_invention_pending (): boolean { return this.company_inventions?.pendingIds?.indexOf(this.selected_invention_id) >= 0; },
    selected_invention_progress () {
      if (!this.selected_invention_active || !this.company_inventions) return -1;
      const price = this.client_state.core.invention_library.metadata_for_id(this.selected_invention_id)?.properties?.price ?? 1;
      return Math.round(100 * this.company_inventions.activeInvestment / price);
    },

    invention_status () {
      if (!this.selected_invention || !this.company_inventions || !this.company_seal) return 'NONE';
      if (this.company_inventions?.isQueued(this.selected_invention_id)) {
        return 'PENDING';
      }
      else if (this.company_inventions?.completedIds?.has(this.selected_invention_id)) {
        if (this.invention_allows.find((allows) => this.company_inventions?.isQueued(allows.id)|| this.company_inventions?.isCompleted(allows.id))) {
          return 'COMPLETED_SUPPORT';
        }
        return 'COMPLETED';
      }
      else {
        if (this.invention_level || this.invention_level.level > (this.corporation_level?.level ?? 0)) return 'AVAILABLE_LEVEL';
        if (this.invention_requires.find((requires) => !this.company_inventions?.isCompleted(requires.id))) return 'AVAILABLE_BLOCKED';
        if (!this.company_has_allowing_building) return 'AVAILABLE_BUILDING';
        return 'AVAILABLE';
      }
    },

    actions_disabled () {
      if (!this.is_ready || !this.company_inventions) return true;
      if (this.ajax_state.request_mutex['player.sell_invention']?.[this.client_state.player.company_id] || this.ajax_state.request_mutex['player.queue_invention']?.[this.client_state.player.company_id]) return true;
      return !this.selected_invention_id || this.company_inventions?.canceledIds?.has(this.selected_invention_id);
    }
  },

  methods: {
    sort_inventions (inventions: Array<any>): Array<any> { return _.sortBy(inventions, (invention) => this.$translate(invention.text_key)); },

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

    is_invention_completed (invention_id: string): boolean {
      return this.company_inventions?.completedIds.has(invention_id);
    },

    select_invention (invention_id: string) {
      this.client_state.interface.inventions_selected_invention_id = invention_id;
    },

    async sell_invention () {
      if (!this.selected_invention_id || !this.company_inventions || (this.invention_status !== 'PENDING' && this.invention_status !== 'COMPLETED')) return;
      try {
        await this.$starpeaceClient.managers.invention_manager.sell_invention(this.client_state.player.company_id, this.selected_invention_id);
        this.$forceUpdate();
      }
      catch (err) {
        console.error(err);
      }
    },

    async queue_invention () {
      if (!this.selected_invention_id || !this.company_inventions || this.invention_status !== 'AVAILABLE') return;

      try {
        await this.$starpeaceClient.managers.invention_manager.queue_invention(this.client_state.player.company_id, this.selected_invention_id);
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
  padding: 1rem

  .invention-selected-details
    height: calc(100% - 8rem)

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
    margin-top: 1.5rem
    padding: 1rem

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
    height: 6rem

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
