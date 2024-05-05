<template lang='pug'>
.overlay-menu-container(:oncontextmenu="'return ' + !$config.public.disableRightClick")
  .is-flex.is-align-items-center.is-relative.py-1
    .dropdown.is-up.is-hoverable
      .dropdown-trigger
        button.button.is-starpeace
          span {{ $translate(selectedOverlayLabel) }}
          span.icon.is-small
            font-awesome-icon(:icon="['fas', 'angle-up']")

      .dropdown-menu(role='menu')
        .dropdown-content
          template(v-for='option in overlayTypeOptions')
            template(v-if='option.children.length > 0')
              .nested.dropdown.dropdown-item(:class="{ 'is-active': option.id == selectedOverlayTypeId || parentOfSelected(option.id) }")
                .dropdown-trigger
                  a.dropdown-item.p-0
                    span {{ $translate(option.label) }}
                    span
                      font-awesome-icon(:icon="['fas', 'chevron-right']")
                .dropdown-menu
                  .dropdown-content
                    template(v-for='child in option.children')
                      a.dropdown-item(:class="{ 'is-active': child.id == selectedOverlayTypeId }" @click.stop.prevent='changeOverlay(child.id)')
                        span {{ $translate(child.label) }}

            template(v-else)
              a.dropdown-item(:class="{ 'is-active': option.id == selectedOverlayTypeId }" @click.stop.prevent='changeOverlay(option.id)')
                span {{ $translate(option.label) }}

    .flag-losing.is-flex.pl-4.pr-2
      span.is-clickable(@click.stop.prevent='toggleLosingFacilities')
        | {{ $translate('overlay.signal_losing.label' )}}:
      .toggle-icons.is-clickable
        a.toggle-on(v-if="show_losing_facilities" @click.stop.prevent='toggleLosingFacilities')
          font-awesome-icon(:icon="['fas', 'toggle-on']")
        a.toggle-off(v-if="!show_losing_facilities" @click.stop.prevent='toggleLosingFacilities')
          font-awesome-icon(:icon="['fas', 'toggle-off']")

    .road-toggle.is-flex.pl-4.pr-2(v-if='isTransportActive')
      button.button.is-menu-option.is-small.has-tooltip-arrow
        img(src='~/assets/images/icons/transport/road.svg')
      button.button.is-menu-option.is-small.has-tooltip-arrow
        img(src='~/assets/images/icons/transport/rail.svg')


</template>

<script lang='ts'>
import _ from 'lodash';

import { Translation } from '@starpeace/starpeace-assets-types';

import OverlayType from '~/plugins/starpeace-client/overlay/overlay-type';
import ClientState from '~/plugins/starpeace-client/state/client-state';

const OVERLAY_TYPE_TOWNS = new OverlayType({
  id: 'TOWNS',
  label: Translation.fromJson({
    'DE': 'Städte',
    'EN': 'Towns',
    'ES': 'Pueblos',
    'FR': 'Les Villes',
    'IT': 'Città',
    'PT': 'Cidades'
  })
});

interface OverlayTypeOption {
  id: string;
  label: Translation;
  children: Array<OverlayTypeOption>;
}

export default {
  props: {
    client_state: { type: ClientState, required: true }
  },

  computed: {
    overlayTypeById (): Record<string, OverlayType> {
      return {
        ...this.client_state.core.planet_library.overlayTypeById,
        [OVERLAY_TYPE_TOWNS.id]: OVERLAY_TYPE_TOWNS
      };
    },
    overlayTypeOptions (): Array<OverlayTypeOption> {
      const roots: Array<OverlayType> = [];
      const overlaysByParentId: Record<string, Array<OverlayType>> = {};

      for (const overlay of Object.values(this.overlayTypeById)) {
        if (!overlay.parentId) {
          roots.push(overlay);
        }
        else {
          overlaysByParentId[overlay.parentId] ||= [];
          overlaysByParentId[overlay.parentId].push(overlay);
        }
      }

      const sortOptions = (options: Array<OverlayTypeOption>) => _.orderBy(options, [r => r.children.length > 0 ? 1 : 0, r => this.$translate(r.label)], ['desc', 'asc']);
      const typeToOption = (type: OverlayType): OverlayTypeOption => {
        return {
          id: type.id,
          label: type.label,
          children: sortOptions((overlaysByParentId[type.id] ?? []).map(typeToOption))
        };
      };

      return sortOptions(roots.map(typeToOption));
    },

    selectedOverlayTypeId (): string | undefined {
      return this.client_state.interface.selectedOverlayTypeId;
    },
    selectedOverlayLabel (): Translation | undefined {
      return this.selectedOverlayTypeId ? this.overlayTypeById[this.selectedOverlayTypeId]?.label : undefined;
    },

    show_losing_facilities () {
      return this.client_state.interface?.show_losing_facilities ? this.client_state.interface?.show_losing_facilities : false;
    },

    isTransportActive (): boolean {
      return this.selectedOverlayTypeId === 'TRAFFIC_AIR' || this.selectedOverlayTypeId === 'TRAFFIC_RAIL' || this.selectedOverlayTypeId === 'TRAFFIC_ROAD';
    }
  },

  methods: {
    parentOfSelected (parentId: string): boolean {
      return (this.selectedOverlayTypeId ? this.overlayTypeById[this.selectedOverlayTypeId]?.parentId : undefined) === parentId;
    },

    changeOverlay (overlayTypeId: string): void {
      this.client_state.interface.selectedOverlayTypeId = overlayTypeId;
    },

    toggleLosingFacilities (): void {
      this.client_state.interface.show_losing_facilities = !this.client_state.interface.show_losing_facilities;
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.overlay-menu-container
  background-color: #000
  bottom: 0
  grid-column: start-left / end-left
  grid-row: start-overlay / end-overlay
  height: 3rem
  pointer-events: auto
  position: absolute
  z-index: 1125

  > .is-flex
    padding: 0 0.125rem

.dropdown-trigger
  .dropdown-item
    display: flex
    padding-right: 1rem

    span
      &:first-child
        flex-grow: 1


.dropdown
  &.is-active
    .dropdown-menu
      display: none

  &.is-hoverable
    &:hover
      .dropdown-menu
        display: none

.dropdown
  &.is-active
    > .dropdown-menu
      display: block

  &.is-hoverable
    &:hover
      > .dropdown-menu
        display: block

  .dropdown-item
    &:hover
      background-color: #ffffbf
      color: #000000

  .dropdown-item
    &.is-active
      > .dropdown-trigger
        > .dropdown-item
          color: #000000

.nested
  &.dropdown
    &:hover
      > .dropdown-menu
        display: block

    .dropdown-menu
      top: -0.5rem
      margin-left: 100%


.dropdown-trigger
  button
    justify-content: flex-start
    width: 16rem

    .icon
      position: absolute
      right: .75rem

.dropdown-menu
  min-width: 16rem
  width: 16rem

.flag-losing
  color: $sp-primary
  white-space: nowrap

  span
    line-height: 2rem

  .toggle-icons
    font-size: 1.5rem
    line-height: 2rem
    margin-left: .5rem
    vertical-align: bottom

    a
      &:hover,
      &:active
        color: lighten(#6ea192, 5%)

    .toggle-on
      color: #fff
      font-weight: 1000

      &:hover,
      &:active
        color: #fff

    .toggle-off
      color: $sp-primary

.road-toggle
  color: $sp-primary
  white-space: nowrap

  .button
    &:not(:first-child)
      margin-left: .5rem

    img
      filter: invert(75%) sepia(8%) saturate(1308%) hue-rotate(111deg) brightness(93%) contrast(83%)

</style>
