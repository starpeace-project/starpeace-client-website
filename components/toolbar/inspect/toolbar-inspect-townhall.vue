<template lang='pug'>
.inspect-details
  .is-flex.is-align-items-center.is-justify-content-center.loading-container(v-if='loading')
    img.loading-image.starpeace-logo.logo-loading

  template(v-else)
    .inspect-tabs.tabs.is-small.m-0
      ul
        li(v-for='tab in tabs' :class="{ 'is-active': tabId == tab.id }" @click.stop.prevent='tabId = tab.id')
            a {{$translate(tab.label)}}

    .inspect-body.columns.m-0.is-clipped
      template(v-if="tabId == 'general'")
        .column.is-narrow.sp-scrollbar.service-levels
          table.basic-table.condensed
            thead
              tr
                th.sp-kv-key {{$translate('ui.menu.town_search.panel.details.qol.label')}}
                th.has-text-right.sp-kv-value {{$formatPercent(qol)}}
            tbody
              tr(v-for='level in service_levels')
                td.sp-kv-key {{labelForServiceTypeId(level.typeId)}}
                td.has-text-right.sp-kv-value {{$formatPercent(level.value)}}

        .column.is-narrow.px-5.politics
          div
            span.sp-kv-key {{ $translate('toolbar.inspect.townhall.label.budget') }}:
            span.sp-kv-value {{ $format_money(cash) }}

          div
            span.sp-kv-key {{$translate('ui.menu.politics.details.mayor.label')}}:
            span.sp-kv-value
              template(v-if='mayor') {{mayor.name}}
              template(v-else) {{$translate('ui.misc.none')}}

          template(v-if='mayor')
            div
              span.sp-kv-key {{$translate('ui.menu.politics.details.overall_rating.label')}}:
              span.sp-kv-value {{$formatPercent(mayor_overall_rating)}}
            div
              span.sp-kv-key {{$translate('ui.menu.politics.details.terms.label')}}:
              span.sp-kv-value {{mayor.terms}}

          div
            span.sp-kv-key {{$translate('ui.menu.politics.details.next_election.label')}}:
            span.sp-kv-value {{next_election_label}}

          a.button.is-fullwidth.is-starpeace(@click.stop.prevent='show_politics') {{$translate('ui.menu.town_search.panel.action.show_politics')}}

        .column.is-narrow.pl-5.population
          table.basic-table
            thead
              tr
                th
                th.has-text-right.sp-kv-key(v-for='population in populations') {{ resourceTypeLabel(population.resourceId) }}
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

      template(v-else-if="tabId == 'commerce'")
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
                td.sp-kv-value {{industryTypeLabel(commerce.industryTypeId)}}
                td.has-text-right.sp-kv-value {{commerce.demand.toLocaleString()}}
                td.has-text-right.sp-kv-value {{commerce.supply.toLocaleString()}}
                td.has-text-right.sp-kv-value {{commerce.capacity.toLocaleString()}}
                td.has-text-right.sp-kv-value {{$formatPercent(commerce.ratio)}}
                td.has-text-right.sp-kv-value {{$format_money(commerce.ifelPrice)}}
                td.has-text-right.sp-kv-value {{$format_money(commerce.averagePrice)}} ({{$formatPercent(commerce.averagePrice, commerce.ifelPrice)}})
                td.has-text-right.sp-kv-value {{$formatPercent(commerce.quality)}}


      template(v-else-if="tabId == 'taxes'")
        .column.sp-scrollbar.taxes
          table.basic-table.sp-striped.sp-solid-header.sp-sticky-header
            thead
              tr
                th.sp-kv-key {{$translate('toolbar.inspect.townhall.label.name')}}
                th.has-text-right.sp-kv-key {{$translate('toolbar.inspect.townhall.label.tax_rate')}}
                th.has-text-right.sp-kv-key {{$translate('toolbar.inspect.townhall.label.last_year')}}
            tbody
              tr(v-for='tax in taxes')
                td.sp-kv-value {{industryCategoryLabel(tax.industryCategoryId)}} - {{industryTypeLabel(tax.industryTypeId)}}
                td.has-text-right.sp-kv-value {{$formatPercent(tax.taxRate)}}
                td.has-text-right.sp-kv-value {{$format_money(tax.lastYear)}}

      template(v-else-if="tabId == 'employment'")
        .column.is-narrow.employment
          datalist(id='wage-markers')
            option(value=0)
            option(value=100)
            option(value=250)
          table.basic-table
            thead
              tr
                th
                th.has-text-right.sp-kv-key(v-for='employment in employments') {{ resourceTypeLabel(employment.resourceId) }}
            tbody
              tr
                td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.total')}}
                td.has-text-right.sp-kv-value(v-for='employment in employments') {{ employment.total }}
              tr
                td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.vacancies')}}
                td.has-text-right.sp-kv-value(v-for='employment in employments') {{ employment.vacancies }}
              tr
                td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.average_wage')}}
                td.has-text-right.sp-kv-value(v-for='employment in employments')
                  div
                    span {{$format_money(employment.averageWage)}}
                    span.ml-1 ({{ $formatPercent(employment.averageWage, $resourceTypePrice(employment.resourceId)) }})
              tr
                td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.minimum_wage')}}
                td.has-text-right.sp-kv-value(v-for='employment in employments')
                  .sp-slider
                    input(type='range' list='wage-markers' min='0' max='250' value='0' disabled)
                    span {{$formatPercent(employment.minimumWage)}}

      template(v-else-if="tabId == 'housing'")
        .column.is-narrow.housing
          table.basic-table
            thead
              tr
                th
                th.has-text-right.sp-kv-key(v-for='housing in housings') {{ resourceTypeLabel(housing.resourceId) }}
            tbody
              tr
                td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.total')}}
                td.has-text-right.sp-kv-value(v-for='housing in housings') {{ housing.total }}
              tr
                td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.vacancies')}}
                td.has-text-right.sp-kv-value(v-for='housing in housings') {{ housing.vacancies }}
              tr
                td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.average_rent') }}
                td.has-text-right.sp-kv-value(v-for='housing in housings') {{ $formatPercent(housing.averageRent) }}
              tr
                td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.quality_index')}}
                td.has-text-right.sp-kv-value(v-for='housing in housings') {{ $formatPercent(housing.qualityIndex) }}

      template(v-else-if="tabId == 'jobs'")
        .column.p-0.is-relative.is-clipped
          toolbar-inspect-shared-tab-jobs(
            :client-state='clientState'
            :jobs='jobs'
            :building='building'
            :definition='definition'
            :simulation='simulation'
          )

</template>

<script lang='ts'>
import _ from 'lodash';

import { BuildingDefinition, ResourceType, SimulationDefinition } from '@starpeace/starpeace-assets-types';

import ClientState from '~/plugins/starpeace-client/state/client-state';
import Building from '~/plugins/starpeace-client/building/building';
import BuildingDetails from '~/plugins/starpeace-client/building/building-details';
import PopulationDetails from '~/plugins/starpeace-client/planet/details/population-details'
import ServiceType from '~/plugins/starpeace-client/planet/details/service-type'
import TownDetails from '~/plugins/starpeace-client/planet/town-details'


declare interface ToolbarInspectTownhallData {
  tabId: string | undefined;

  governmentPromise: Promise<TownDetails> | undefined;
  government: TownDetails | undefined;
}

export default {
  props: {
    clientState: { type: ClientState, required: true },

    building: { type: Building, required: true },
    definition: { type: BuildingDefinition, required: true },
    simulation: { type: SimulationDefinition, required: true },

    buildingDetails: { type: BuildingDetails, required: true }
  },

  data (): ToolbarInspectTownhallData {
    return {
      tabId: undefined,

      governmentPromise: undefined,
      government: undefined
    };
  },

  computed: {
    loading (): boolean {
      return !!this.governmentPromise || !this.government;
    },

    tabs () {
      const tabs = [
        {
          id: 'general',
          label: 'toolbar.inspect.common.tabs.general'
        },
        {
          id: 'commerce',
          label: 'toolbar.inspect.townhall.tabs.commerce'
        },
        {
          id: 'taxes',
          label: 'toolbar.inspect.townhall.tabs.taxes'
        },
        {
          id: 'employment',
          label: 'toolbar.inspect.townhall.tabs.employment'
        },
        {
          id: 'housing',
          label: 'toolbar.inspect.townhall.tabs.housing'
        }
      ];
      if (this.jobs.length > 0) {
        tabs.push({
          id: 'jobs',
          label: 'toolbar.inspect.common.tabs.jobs'
        });
      }
      return tabs;
    },

    town () { return _.find(this.clientState?.planet?.towns, (t) => t.building_id === this.clientState?.interface?.selected_building_id); },
    mayor () { return this.government?.currentTerm?.politician; },
    mayor_overall_rating () { return this.government?.currentTerm?.overall_rating ?? 0; },

    qol (): number {
      return this.government?.qol ?? 0;
    },
    service_levels (): Array<any> {
      return this.government?.services ?? [];
    },
    cash (): number {
      return this.government?.budget?.cash ?? 0;
    },

    next_election_label () { return this.government?.nextTerm?.start?.toFormat('MMM d, yyyy') ?? this.$translate('ui.misc.none'); },

    commerces () { return _.orderBy(this.government?.commerce, [(c) => this.industryTypeLabel(c.industryTypeId)], ['asc']); },
    taxes () { return _.orderBy(this.government?.taxes, [(t) => this.industryCategoryLabel(t.industryCategoryId), (t) => this.industryTypeLabel(t.industryTypeId)], ['asc', 'asc']); },
    populations () { return this.government?.population ?? []; },
    employments () { return this.government?.employment ?? []; },
    housings () { return this.government?.housing ?? []; },
    jobs () { return this.buildingDetails?.labors ?? []; },
  },

  watch: {
    town: {
      immediate: true,
      handler (): void {
        this.refreshGovernment();
      }
    },
    tabs: {
      immediate: true,
      handler () {
        if (!this.tabs.length) {
          this.tabId = undefined;
        }
        else if (!this.tabId || !this.tabs.find(t => t.id === this.tabId)) {
          this.tabId = this.tabs[0].id;
        }
      }
    }
  },

  methods: {
    labelForServiceTypeId (typeId: string): string {
      return this.$translate(ServiceType.labelForTypeId(typeId));
    },
    industryCategoryLabel (categoryId: string): string {
      return this.$translate(this.clientState.core.planet_library.category_for_id(categoryId)?.label);
    },
    industryTypeLabel (typeId: string): string {
      return this.$translate(this.clientState.core.planet_library.type_for_id(typeId)?.label);
    },
    resourceType (typeId: string): ResourceType {
      return this.clientState.core.planet_library.resource_type_for_id(typeId);
    },
    resourceTypeLabel (typeId: string): string {
      return this.$translate(this.resourceType(typeId)?.labelPlural);
    },

    format_unemployment (census: PopulationDetails): string {
      return this.$formatPercent(census.unemployed, census.population);
    },
    format_homelessness (census: PopulationDetails): string {
      return this.$formatPercent(census.homeless, census.population);
    },

    async refreshGovernment (): Promise<void> {
      this.government = undefined;
      if (!this.clientState?.player?.planet_id || !this.town) return;

      try {
        this.governmentPromise = this.$starpeaceClient.managers.planets_manager.load_town_details(this.town.id, true);
        this.government = await this.governmentPromise;
        this.governmentPromise = undefined;
      }
      catch (err) {
        this.clientState.add_error_message('Failure loading town details, please try again', err);
        this.governmentPromise = undefined;
      }
    },

    show_politics (): void {
      if (this.town?.id) {
        this.clientState.show_politics(this.town.id);
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-inspect'

.loading-container
  height: 100%

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
