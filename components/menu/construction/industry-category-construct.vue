<template lang='pug'>
aside.sp-menu-category.sp-scrollbar
  template(v-for="info in sortedBuildingsInformation")
    a.is-building-item(@click.stop.prevent="toggleBuilding(info.id)" :class="{'active': selectedBuildingId == info.id}")
      misc-industry-type-icon(:industry_type="info.definition.industryTypeId" small)
      span.is-building-label {{ $translate(info.definition.name) }}
      .construction-disabled(v-if="!has_construction_requirements(info.id)")

    a.construct-action(@click.stop.prevent="selectBuilding(info.id)" :disabled='!has_construction_requirements(info.id)')
      .tile.is-ancestor.is-item-details(v-show="selectedBuildingId == info.id")
        .tile.is-parent.is-vertical
          .tile.is-parent.is-item-details-top
            article.tile.is-child.is-7(:ref="'previewItem.' + info.id")
            article.tile.is-child
              .building-cost
                misc-money-text(:value='info.cost' no_styling as_thousands)
              .building-size {{ info.footprintArea }}m&sup2;

          .tile.is-parent.is-item-details-bottom
            article.tile.is-child
              .building-description {{ info.description }}
              .building-research(v-show="info.definition.requiredInventionIds.length")
                span.research-label {{$translate('ui.menu.construction.requires')}}:
                template(v-for='id,index in info.definition.requiredInventionIds')
                  a(
                    :class="{'has-text-weight-bold': !completedInventionIds.has(id), 'is-italic': completedInventionIds.has(id)}"
                    @click.stop.prevent='selectInvention(id)'
                  ) {{ $inventionLabel(id) }}
                  span.research-separator(v-if="!(index >= info.definition.requiredInventionIds.length - 1)") {{separator_label_for_index(index, info.definition.requiredInventionIds.length)}}

              button.button.is-fullwidth.is-starpeace.mb-3.construct-button(
                @click.stop.prevent="selectBuilding(info.id)"
                :disabled='!has_construction_requirements(info.id)'
              ) {{ $translate('ui.menu.construction.construct_building') }}

</template>

<script lang='ts'>
import _ from 'lodash';

import { BuildingDefinition } from '@starpeace/starpeace-assets-types';

import ClientState from '~/plugins/starpeace-client/state/client-state';
import Company from '~/plugins/starpeace-client/company/company';

export default {
  props: {
    clientState: { type: ClientState, required: true },

    company: { type: Company, required: false },
    companyBuildingsByCategoryId: { type: Object, required: true },

    selectedIndustryCategoryId: { type: String, required: false },
  },

  computed: {
    isVisible (): boolean {
      return this.clientState?.workflow_status === 'ready' && (this.clientState?.menu?.is_visible('construction') ?? false);
    },

    buildings (): Array<BuildingDefinition> {
      return (this.selectedIndustryCategoryId ? this.companyBuildingsByCategoryId[this.selectedIndustryCategoryId] : undefined) ?? [];
    },
    sortedBuildingsInformation (): Array<any> {
      return _.orderBy((this.buildings).map((info: BuildingDefinition) => {
        const image = this.clientState.core.building_library.images_by_id[info.imageId];
        const areaSize = image ? ((image.w * 20) * (image.h * 20)) : 0;

        return {
          id: info.id,
          definition: info,
          description: this.$starpeaceClient.managers.translation_manager.description_for_building(info),
          cost: this.$starpeaceClient.managers?.building_manager?.cost_for_building_definition_id(info.id) ?? 0,
          footprintArea: areaSize
        };
      }), [(info) => info.definition.industryTypeId, (info) => info.cost], ['asc', 'asc']);
    },

    completedInventionIds (): Set<string> {
      return (this.isVisible && this.company ? this.clientState.corporation.inventions_metadata_by_company_id[this.company.id]?.completedIds : undefined) ?? new Set<string>();
    },

    selectedBuildingId (): string | null {
      return this.clientState.interface.construction_selected_building_id;
    }
  },

  mounted () {
    if (this.selectedBuildingId) {
      this.$emit('select', {
        definitionId: this.selectedBuildingId,
        previewContainer: this.$refs[`previewItem.${this.selectedBuildingId}`]
      });
    }
  },

  methods: {
    separator_label_for_index (index: number, length: number): string {
      return length > 2 ? (index == length - 2 ? ', and ' : ', ') : ' and ';
    },

    has_construction_requirements (definitionId: string) {
      return this.clientState.has_construction_requirements(definitionId);
    },

    toggleBuilding (definitionId: string): void {
      if (this.selectedBuildingId === definitionId) {
        this.clientState.interface.selectConstructionDefinitionId(null);
        this.$emit('select', null);
      }
      else {
        this.clientState.interface.selectConstructionDefinitionId(definitionId);
        this.$emit('select', {
          definitionId,
          previewContainer: this.$refs[`previewItem.${definitionId}`]
        });
      }
    },

    selectBuilding (definitionId: string): void {
      if (this.has_construction_requirements(definitionId)) {
        this.clientState.initiate_building_construction(definitionId);
      }
    },

    selectInvention (id: string) {
      this.clientState.interface.inventions_selected_invention_id = id;
      this.clientState.menu.toggle_menu('research');
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.sp-menu-category
  height: calc(100% - 4.75rem - 2.75rem - 3.5rem)
  position: absolute
  overflow-x: hidden
  overflow-y: scroll
  width: 100%

  li
    padding: 0 1.25rem


.is-building-item
  background-color: darken($sp-primary-bg, 9%)
  border-bottom: 1px solid darken($sp-primary-bg, 11%)
  cursor: zoom-in
  display: inline-block
  padding: .5rem .75rem
  position: relative
  width: 100%

  .construction-disabled
    background-color: #000
    height: 100%
    left: 0
    opacity: .5
    pointer-events: none
    position: absolute
    top: 0
    width: 100%
    z-index: 1000

  &:not(.disabled),
  &:not([disabled])
    &:hover
      background-color: darken($sp-primary-bg, 6.5%)
      border-bottom: 1px solid darken($sp-primary-bg, 9%)

    &:active
      color: #8bb3a7
      font-weight: normal

    &.active
      background-color: darken($sp-primary-bg, 4%)
      border-bottom: 1px solid darken($sp-primary-bg, 6%)

    &.active
      cursor: zoom-out

  &.disabled
    cursor: not-allowed

  .is-building-label
    margin-left: .5rem

.is-item-details
  margin: 0

  > .tile
    &.is-parent
      padding: 0

  .is-item-details-top
    padding-bottom: .25rem

  .is-item-details-bottom
    padding-top: .25rem

.construct-action
  cursor: pointer
  font-weight: normal

  &.disabled
    cursor: not-allowed

  article
    position: relative

  .building-cost
    font-size: 1.25rem
    font-weight: bold
    text-align: right

  .building-size
    text-align: right

  .research-label
    margin-right: .5rem

  .research-completed
    font-style: italic

  .research-pending
    font-weight: bold

  .construct-button
    letter-spacing: .05rem
    margin-top: .5rem
    text-transform: uppercase

</style>
