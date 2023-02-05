<template lang='pug'>
.products-tab.columns.is-marginless
  .column.is-narrow.is-paddingless.sp-scrollbar.products
    .product-tabs
      ul
        template(v-for='product,index in sortedProducts')
          li(:class="{ 'is-active': productIndex == index }" @click.stop.prevent='productIndex = index')
            a.sp-kv-key {{resourceTypeLabel(product.resource_id)}}

  .column.connections
    .connection-information(v-if='product')
      span.sp-kv-key {{translate('toolbar.inspect.products.label.price')}}:
      span.sp-kv-value {{format_percent(priceRatio)}} ({{format_money(product.price)}})
      span.sp-kv-key {{translate('toolbar.inspect.products.label.last_value')}}:
      span.sp-kv-value {{format_number(product.total_velocity)}} {{resourceTypeLabel(product.resource_id)}}
      span.sp-kv-key {{translate('toolbar.inspect.products.label.quality')}}:
      span.sp-kv-value {{format_percent(product.quality)}}

    .connection-details.sp-scrollbar
      table
        thead
          tr
            th.sp-kv-key {{translate('toolbar.inspect.products.label.customer')}}
            th.sp-kv-key {{translate('toolbar.inspect.products.label.company')}}
            th.has-text-right.sp-kv-key {{translate('toolbar.inspect.products.label.sales')}}
            th.has-text-right.sp-kv-key {{translate('toolbar.inspect.products.label.transport_cost')}}
        tbody
          template(v-if='!connections.length')
            tr.is-empty
              td(colspan=4) {{translate('ui.misc.none')}}
          template(v-else v-for='connection,index in connections')
            tr(:class="{ 'is-active': selectedIndices[index] }" @click.stop.prevent='clickConnection(connection, index)')
              td.sp-kv-value
                span.validity-icon
                  template(v-if='connection.valid')
                    font-awesome-icon(:icon="['fas', 'check']")
                  template(v-else)
                    font-awesome-icon(:icon="['fas', 'times']")
                | {{connection.sink_building_name}}
              td.sp-kv-value {{connection.sink_company_name}}
              td.has-text-right.sp-kv-value {{format_number(connection.velocity)}}
              td.has-text-right.sp-kv-value {{format_money(connection.transport_cost)}}

</template>

<script lang='coffee'>
import _ from 'lodash';

export default
  props:
    clientState: Object
    managers: Object

    products: Array

    building: Object
    definition: Object
    simulation: Object

  data: ->
    clickTimeout: null

    productIndex: 0
    selectedIndices: {}

  computed:
    sortedProducts: -> _.orderBy(@products, [(t) => @resourceTypeLabel(t.resource_id)], ['asc'])

    product: -> @sortedProducts[@productIndex]

    priceRatio: ->
      ifel_price = @resourceType(@product.resource_id)?.price || 0
      if ifel_price > 0 then (@product.price / ifel_price) else 0

    connections: -> @product?.connections || []

  watch:
    productIndex: -> @selectedIndices = {}

  methods:
    translate: (key) -> if @managers? then @managers.translation_manager.text(key) else key

    format_percent: (value) -> if _.isNumber(value) then "#{Math.round(value * 100)}%" else ''
    format_money: (value) -> if _.isNumber(value) then "$#{Math.round(value).toLocaleString()}" else ''
    format_number: (value) -> if _.isNumber(value) then value.toLocaleString() else ''

    resourceType: (type_id) ->@clientState.core.planet_library.resource_type_for_id(type_id)
    resourceTypeLabel: (type_id) -> @translate(@resourceType(type_id)?.label_plural)

    validConnection: (index) -> index % 3 == 0

    clickConnection: (connection, index) ->
      if @clickTimeout?
        clearTimeout(@clickTimeout)
        @clickTimeout = null
        @jumpConnection(connection)
      else
        should_deselect = @selectedIndices[index]
        @$set(@selectedIndices, index, true)
        @clickTimeout = setTimeout(=>
          @$delete(@selectedIndices, index) if should_deselect
          @clickTimeout = null
        , 250)

    jumpConnection: (connection) -> @clientState.jump_to(connection.sink_building_map_x, connection.sink_building_map_y, null) if connection?.sink_building_map_x? && connection?.sink_building_map_y?

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
