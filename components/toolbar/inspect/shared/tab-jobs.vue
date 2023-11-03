<template lang='pug'>
.jobs-tab.columns.is-marginless
  .column.is-narrow.is-paddingless
    table.basic-table
      thead
        tr
          th
          th.has-text-right.sp-kv-key(v-for='typeId in laborResourceIds') {{resourceTypeLabel(typeId)}}
      tbody
        tr
          td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.vacancies')}}
          td.has-text-right.sp-kv-value(v-for='typeId in laborResourceIds')
        tr
          td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.spending_power')}}
          td.has-text-right.sp-kv-value(v-for='typeId in laborResourceIds')
        tr
          td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.average_wage')}}
          td.has-text-right.sp-kv-value(v-for='typeId in laborResourceIds')
        tr
          td.sp-kv-key {{$translate('toolbar.inspect.townhall.label.minimum_wage')}}
          td.has-text-right.sp-kv-value(v-for='typeId in laborResourceIds')
            .sp-slider
              input(type='range' min='0' max='200' value='100' disabled)
              span {{$format_percent(0)}}

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';

import Labor from '~/plugins/starpeace-client/building/details/labor';

declare interface TabJobsData {
}

export default {
  props: {
    clientState: { type: ClientState, required: true },

    jobs: { type: Array<Labor>, required: true },

    building: Object,
    definition: Object,
    simulation: Object
  },

  data (): TabJobsData {
    return {
    };
  },

  computed: {
    laborResourceIds () {
      return this.jobs?.map(l => l.resourceId);
    },


  },

  methods: {
    resourceType (type_id: string) { return this.clientState.core.planet_library.resource_type_for_id(type_id); },
    resourceTypeLabel (type_id: string) { return this.$translate(this.resourceType(type_id)?.label_plural); },

  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.products-tab
  height: 100%
  position: relative
  overflow: hidden
  width: 100%

.button
  letter-spacing: .1rem
  text-transform: uppercase

.column
  &.products
    direction: rtl
    overflow-y: auto

    .product-tabs
      direction: ltr

      ul
        flex-direction: column

        li
          display: flex
          justify-content: flex-end
          margin-left: .25rem
          text-align: right

          a
            border-radius: 0
            color: $sp-primary
            padding: .5rem
            letter-spacing: .05rem
            text-transform: uppercase

            &:hover
              color: $sp-light

            &:active
              color: lighten($sp-light, 10%)

          &.is-active
            a
              background-color: $sp-dark-bg
              color: #fff

  &.connections
    background-color: $sp-dark-bg
    display: grid
    grid-template-columns: auto
    grid-template-rows: [start-information] 2rem [end-information start-details] auto [end-details]
    overflow: hidden
    padding: .25rem
    position: relative

    .connection-information
      grid-column: 1 / 2
      grid-row: start-information / end-information

      .sp-kv-key
        margin-left: 1rem

        &:not(:first-child)
          margin-left: 4rem

    .connection-details
      border: 1px solid $sp-primary-bg
      grid-column: 1 / 2
      grid-row: start-details / end-details
      overflow-y: auto

    table
      position: relative
      width: 100%

      tbody
        tr
          &:not(.is-empty)
            cursor: pointer

          td
            background-color: #fff
            border-bottom: 1px solid lighten($sp-light-bg, 40%)

          &:nth-child(even)
            td
              background-color: lighten($sp-light-bg, 55%)

          &.is-active
            td
              color: #fff
              background-color: $sp-light-bg
              border-bottom: 1px solid $sp-primary-bg

      th
        background-color: $sp-primary-bg
        color: $sp-light
        padding: .5rem
        position: sticky
        top: 0

      td
        color: #000
        padding: .25rem .5rem
        vertical-align: middle

    .validity-icon
      display: inline-block
      text-align: center
      margin-right: .5rem
      width: 1.5rem

</style>
