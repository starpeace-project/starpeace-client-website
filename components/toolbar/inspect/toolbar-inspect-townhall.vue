<template lang='pug'>
.inspect-details
  template(v-if='loading')
    img.loading-image.starpeace-logo.logo-loading

  template(v-else)
    .inspect-tabs.tabs.is-small.is-marginless
      ul
        li(:class="{ 'is-active': tab_index == 0 }" @click.stop.prevent='tab_index = 0')
          a {{$translate('toolbar.inspect.townhall.tabs.general')}}
        li(:class="{ 'is-active': tab_index == 1 }" @click.stop.prevent='tab_index = 1')
          a {{$translate('toolbar.inspect.townhall.tabs.commerce')}}
        li(:class="{ 'is-active': tab_index == 2 }" @click.stop.prevent='tab_index = 2')
          a {{$translate('toolbar.inspect.townhall.tabs.taxes')}}
        li(:class="{ 'is-active': tab_index == 3 }" @click.stop.prevent='tab_index = 3')
          a {{$translate('toolbar.inspect.townhall.tabs.employment')}}
        li(:class="{ 'is-active': tab_index == 4 }" @click.stop.prevent='tab_index = 4')
          a {{$translate('toolbar.inspect.townhall.tabs.housing')}}

    .inspect-body.columns.is-marginless
      template(v-if='tab_index == 0')
        .column.is-narrow.sp-scrollbar.service-levels
          table.basic-table.condensed
            thead
              tr
                th.sp-kv-key {{$translate('ui.menu.town_search.panel.details.qol.label')}}
                th.has-text-right.sp-kv-value {{$format_percent(.9)}}
            tbody
              tr(v-for='level in service_levels')
                td.sp-kv-key {{label_for_type(level.type)}}
                td.has-text-right.sp-kv-value {{$format_percent(level.value)}}

        .column.is-narrow.extra-padding-left.extra-padding-right.politics
          div
            span.sp-kv-key {{$translate('ui.menu.politics.details.mayor.label')}}:
            span.sp-kv-value
              template(v-if='mayor') {{mayor.name}}
              template(v-else) {{$translate('ui.misc.none')}}

          template(v-if='mayor')
            div
              span.sp-kv-key {{$translate('ui.menu.politics.details.overall_rating.label')}}:
              span.sp-kv-value {{$format_percent(mayor_overall_rating)}}
            div
              span.sp-kv-key {{$translate('ui.menu.politics.details.terms.label')}}:
              span.sp-kv-value {{mayor.terms}}

          div
            span.sp-kv-key {{$translate('ui.menu.politics.details.next_election.label')}}:
            span.sp-kv-value {{next_election_label}}

          a.button.is-fullwidth.is-starpeace(@click.stop.prevent='show_politics') {{$translate('ui.menu.town_search.panel.action.show_politics')}}

        .column.is-narrow.extra-padding-left.population
          table.basic-table
            thead
              tr
                th
                th.has-text-right.sp-kv-key(v-for='population in populations') {{population.type}}
            tbody
              tr
                td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.population')}}
                td.has-text-right.sp-kv-value(v-for='population in populations') {{population.population}}
              tr
                td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.unemployment')}}
                td.has-text-right.sp-kv-value(v-for='population in populations') {{format_unemployment(population)}}
              tr
                td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.homelessness')}}
                td.has-text-right.sp-kv-value(v-for='population in populations') {{format_homelessness(population)}}

      template(v-else-if='tab_index == 1')
        .column.sp-scrollbar.commerce
          table.basic-table.sp-striped.sp-solid-header.sp-sticky-header
            thead
              tr
                th.sp-kv-key {{$translate('toolbar.inspect.townhall.label.name')}}
                th.has-text-right.sp-kv-key {{$translate('toolbar.inspect.townhall.label.demand')}}
                th.has-text-right.sp-kv-key {{$translate('toolbar.inspect.townhall.label.supply')}}
                th.has-text-right.sp-kv-key {{$translate('toolbar.inspect.townhall.label.capacity')}}
                th.has-text-right.sp-kv-key {{$translate('toolbar.inspect.townhall.label.ratio')}}
                th.has-text-right.sp-kv-key {{$translate('toolbar.inspect.townhall.label.ifel_price')}}
                th.has-text-right.sp-kv-key {{$translate('toolbar.inspect.townhall.label.average_price')}}
                th.has-text-right.sp-kv-key {{$translate('toolbar.inspect.townhall.label.quality')}}
            tbody
              tr(v-for='commerce in commerces')
                td.sp-kv-value {{industry_type_label(commerce.industry_type_id)}}
                td.has-text-right.sp-kv-value {{commerce.demand.toLocaleString()}}
                td.has-text-right.sp-kv-value {{commerce.supply.toLocaleString()}}
                td.has-text-right.sp-kv-value {{commerce.capacity.toLocaleString()}}
                td.has-text-right.sp-kv-value {{$format_percent(commerce.ratio)}}
                td.has-text-right.sp-kv-value {{$format_money(commerce.ifel_price)}}
                td.has-text-right.sp-kv-value {{$format_money(commerce.average_price)}} ({{$format_percent(commerce.ifel_price > 0 ? commerce.average_price / commerce.ifel_price : 0)}})
                td.has-text-right.sp-kv-value {{$format_percent(commerce.quality)}}


      template(v-else-if='tab_index == 2')
        .column.sp-scrollbar.taxes
          table.basic-table.sp-striped.sp-solid-header.sp-sticky-header
            thead
              tr
                th.sp-kv-key {{$translate('toolbar.inspect.townhall.label.name')}}
                th.has-text-right.sp-kv-key {{$translate('toolbar.inspect.townhall.label.tax_rate')}}
                th.has-text-right.sp-kv-key {{$translate('toolbar.inspect.townhall.label.last_year')}}
            tbody
              tr(v-for='tax in taxes')
                td.sp-kv-value {{industry_category_label(tax.industry_category_id)}} - {{industry_type_label(tax.industry_type_id)}}
                td.has-text-right.sp-kv-value {{$format_percent(tax.tax_rate)}}
                td.has-text-right.sp-kv-value {{$format_money(tax.last_year)}}

      template(v-else-if='tab_index == 3')
        .column.is-narrow.employment
          table.basic-table
            thead
              tr
                th
                th.has-text-right.sp-kv-key(v-for='employment in employments') {{employment.type}}
            tbody
              tr
                td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.vacancies')}}
                td.has-text-right.sp-kv-value(v-for='employment in employments') {{employment.vacancies}}
              tr
                td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.spending_power')}}
                td.has-text-right.sp-kv-value(v-for='employment in employments') {{$format_percent(employment.spending_power)}}
              tr
                td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.average_wage')}}
                td.has-text-right.sp-kv-value(v-for='employment in employments') {{$format_percent(employment.average_wage)}}
              tr
                td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.minimum_wage')}}
                td.has-text-right.sp-kv-value(v-for='employment in employments')
                  .sp-slider
                    input(type='range' min='0' max='200' value='100' disabled)
                    span {{$format_percent(employment.minimum_wage)}}

      template(v-else-if='tab_index == 4')
        .column.is-narrow.housing
          table.basic-table
            thead
              tr
                th
                th.has-text-right.sp-kv-key(v-for='housing in housings') {{housing.type}}
            tbody
              tr
                td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.vacancies')}}
                td.has-text-right.sp-kv-value(v-for='housing in housings') {{housing.vacancies}}
              tr
                td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.average_rent')}}
                td.has-text-right.sp-kv-value(v-for='housing in housings') {{$format_percent(housing.average_rent)}}
              tr
                td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.quality_index')}}
                td.has-text-right.sp-kv-value(v-for='housing in housings') {{$format_percent(housing.quality_index)}}

</template>

<script lang='ts'>
import _ from 'lodash';

import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';
import ServiceType from '~/plugins/starpeace-client/planet/details/service-type'

declare interface ToolbarInspectTownhallData {
  tab_index: number;
  details_promise: Promise<any> | null;
  details: any;
}

export default {
  props: {
    clientState: { type: ClientState, required: true }
  },

  data (): ToolbarInspectTownhallData {
    return {
      tab_index: 0,
      details_promise: null,
      details: null
    };
  },

  computed: {
    loading () { return !!this.details_promise || !this.details; },

    town () { return _.find(this.clientState?.planet?.towns, (t) => t.building_id === this.clientState?.interface?.selected_building_id); },
    mayor () { return this.details?.current_term?.politician; },
    mayor_overall_rating () { return this.details?.current_term?.overall_rating ?? 0; },
    service_levels () { return this.details?.services ?? []; },

    next_election_label () { return this.details?.next_term?.start?.toFormat('MMM d, yyyy') ?? this.$translate('ui.misc.none'); },

    commerces () { return _.orderBy(this.details?.commerce, [(c) => this.industry_type_label(c.industry_type_id)], ['asc']); },
    taxes () { return _.orderBy(this.details?.taxes, [(t) => this.industry_category_label(t.industry_category_id), (t) => this.industry_type_label(t.industry_type_id)], ['asc', 'asc']); },
    populations () { return this.details?.population ?? []; },
    employments () { return this.details?.employment ?? []; },
    housings () { return this.details?.housing ?? []; },
  },

  watch: {
    town: {
      immediate: true,
      handler () { this.refresh_details(); }
    }
  },

  methods: {
    label_for_type (service_type: string): string { return this.$translate(ServiceType.label_for_type(service_type)); },
    industry_category_label (category_id: string): string { return this.$translate(this.clientState.core.planet_library.category_for_id(category_id)?.label); },
    industry_type_label (type_id: string): string { return this.$translate(this.clientState.core.planet_library.type_for_id(type_id)?.label); },

    format_unemployment (census): string {
      const unemployment: number = _.isNumber(census.unemployment) ? census.unemployment : 0;
      const population: number = _.isNumber(census.population) ? census.population : 0;
      return this.$format_percent(population > 0 ? (unemployment / population) : 0);
    },
    format_homelessness (census): string {
      const homeless: number = _.isNumber(census.homeless) ? census.homeless : 0;
      const population: number = _.isNumber(census.population) ? census.population : 0;
      return this.$format_percent(population > 0 ? (homeless / population) : 0);
    },

    async refresh_details () {
      this.details = null;
      if (!this.clientState?.player?.planet_id || !this.town) return;

      try {
        this.details_promise = this.$starpeaceClient.managers.planets_manager.load_town_details(this.town.id);
        this.details = await this.details_promise;
        this.details_promise = null;
      }
      catch (err) {
        this.clientState.add_error_message('Failure loading town details, please try again', err);
        this.details_promise = null;
      }
    },

    show_politics (): void {
      if (this.town?.id) this.clientState.show_politics(this.town.id);
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-inspect'

.column
  &.service-levels
    overflow-y: auto

  &.politics
    .button
      margin-top: 1rem

  &.commerce
    overflow-y: auto
    padding: 0

    table
      position: relative
      width: 100%

      th
        padding: .5rem

      td
        padding: .25rem .5rem

  &.taxes
    overflow-y: auto
    padding: 0

    table
      position: relative
      width: 100%

      th
        padding: .5rem

      td
        padding: .25rem .5rem

</style>
