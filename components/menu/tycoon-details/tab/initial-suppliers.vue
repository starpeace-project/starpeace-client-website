<template lang='pug'>
.sp-tab
  .suppliers-tab
    .sp-scrollbar
      table.basic-table.sp-striped.sp-solid-header.sp-sticky-header.suppliers(:class="{'hoverable': is_self}")
        thead
          tr
            th.sp-kv-key.column-product {{translate('ui.menu.tycoon_details.tab.initial_suppliers.product')}}
            th.has-text-right.sp-kv-key.column-suppliers-count {{translate('ui.menu.tycoon_details.tab.initial_suppliers.suppliers')}}
            th.has-text-right.sp-kv-key.column-suppliers-price {{translate('ui.menu.tycoon_details.tab.initial_suppliers.average_price')}}
            th.has-text-right.sp-kv-key.column-ifel-price {{translate('ui.menu.tycoon_details.tab.initial_suppliers.ifel_price')}}
            th.has-text-centered.sp-kv-key.column-action {{translate('ui.menu.tycoon_details.tab.initial_suppliers.trade_center')}}

        tbody
          tr(v-for='resource_type in sorted_resource_types' :class="{'is-selected': selectedSupplierResourceTypeId == resource_type.id}" @click.stop.prevent='selectedSupplierResourceTypeId = resource_type.id')
            td.is-size-5.column-product {{translate(resource_type.label_plural)}}
            td.has-text-right {{supplier_info_by_resource_id[resource_type.id]?.count ?? 0}}
            td.has-text-right
              misc-money-text(:value='supplier_info_by_resource_id[resource_type.id]?.averagePrice ?? 0' no_styling)
            td.has-text-right
              misc-money-text(:value='resource_type.price' no_styling)
            td.column-action
              .is-flex.is-justify-content-center(v-if='has_corporation && is_self')
                misc-toggle-option(v-if='suppliersByResourceTypeId[resource_type.id]' :value='suppliersByResourceTypeId[resource_type.id].tradeCenter' @toggle="toggle_supplier_trade_center(resource_type.id)")

    .sp-scrollbar
      table.basic-table.sp-striped.sp-solid-header.sp-sticky-header.supplier-details
        thead
          tr
            th.sp-kv-key {{translate('ui.menu.tycoon_details.tab.initial_suppliers.corporation_name')}}
            th.sp-kv-key {{translate('ui.menu.tycoon_details.tab.initial_suppliers.building_name')}}
            th.has-text-right.sp-kv-key.column-price {{translate('ui.menu.tycoon_details.tab.initial_suppliers.price')}}
            th.column-action

        template(v-if='selectedSupplierResourceTypeId')
          tbody
            template(v-if='!suppliers_for_selected_resource_type.length')
              tr
                td.has-text-centered(colspan=4) {{translate('ui.misc.none')}}

            template(v-else)
              tr(v-for='supplier in suppliers_for_selected_resource_type')
                template(v-if='supplier.isTradeCenter')
                  td IFEL
                  td {{translate('ui.menu.tycoon_details.tab.initial_suppliers.trade_center')}}
                  td.has-text-right
                    misc-money-text(:value='supplier.price' no_styling)
                  td
                    .is-flex.is-justify-content-center(v-if='has_corporation && is_self')
                      button.button.is-small.is-starpeace(disabled) {{translate('misc.action.cancel')}}

          tfoot(v-if='has_corporation && is_self')
            tr
              td.has-text-centered.py-4(colspan=4)
                .is-flex.is-justify-content-center
                  button.button.is-starpeace(@click.stop.prevent='' disabled) {{translate('ui.menu.tycoon_details.tab.initial_suppliers.action.add_supplier')}}
                  button.button.is-starpeace(@click.stop.prevent='' disabled) {{translate('misc.action.manage')}}

</template>

<script lang='coffee'>
import _ from 'lodash';

import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default
  props:
    managers: Object
    clientState: Object
    tycoonId: String
    corporationId: String

  data: ->
    loadingSuppliers: false

    suppliersByResourceTypeId: {}
    selectedSupplierResourceTypeId: null

  computed:
    has_corporation: -> @corporationId?.length
    is_self: -> @clientState.player.tycoon_id == @tycoonId

    corporation: -> if @has_corporation then @clientState.core.corporation_cache.metadata_for_id(@corporationId) else null

    resource_types_by_id: -> _.keyBy(_.filter(@clientState?.core?.planet_library?.all_resource_types(), (t) => t.price > 0), 'id')
    sorted_resource_types: -> _.orderBy(Object.values(@resource_types_by_id), [(t) => @translate(t.label_plural)], ['asc'])

    supplier_info_by_resource_id: ->
      info = {}
      for type in @sorted_resource_types
        count = (if @suppliersByResourceTypeId[type.id]?.tradeCenter then 1 else 0) + (@suppliersByResourceTypeId[type.id]?.suppliers?.length || 0)
        totalPrice = (if @suppliersByResourceTypeId[type.id]?.tradeCenter then type.price else 0) + (@suppliersByResourceTypeId[type.id]?.suppliers || []).reduce(((s, i) => s + i), 0)
        info[type.id] = {
          count: count
          averagePrice: if count > 0 then (totalPrice / count) else 0
        }
      info

    suppliers_for_selected_resource_type: ->
      return [] if !@selectedSupplierResourceTypeId
      suppliers = []
      if @suppliersByResourceTypeId[@selectedSupplierResourceTypeId]?.tradeCenter
        suppliers.push({
          isTradeCenter: true
          price: @resource_types_by_id[@selectedSupplierResourceTypeId]?.price || 0
        })
      suppliers


  mounted: ->
    @refresh_details()

  watch:
    tycoonId: (newValue, oldValue) ->
      if newValue != oldValue
        @reset_state() if oldValue
        @refresh_details()
    corporationId: (newValue, oldValue) ->
      if newValue != oldValue
        @reset_state() if oldValue
        @refresh_details()

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    toggle_supplier_trade_center: (type_id) -> @suppliersByResourceTypeId[type_id].tradeCenter = !@suppliersByResourceTypeId[type_id].tradeCenter if @suppliersByResourceTypeId[type_id]

    reset_state: () ->
      @suppliersByResourceTypeId = {}
      @selectedSupplierResourceTypeId = null

    refresh_details: ->
      return if @loadingSuppliers || !@has_corporation
      try
        @loadingSuppliers = true
        @suppliersByResourceTypeId = {}
        for resource_type in @sorted_resource_types
          @suppliersByResourceTypeId[resource_type.id] = {
            tradeCenter: true
            suppliers: []
          }
        @selectedSupplierResourceTypeId = @sorted_resource_types[0].id if !@selectedSupplierResourceTypeId && @sorted_resource_types.length
      catch err
        @client_state.add_error_message('Failure loading tycoon details from server', err)
        @suppliersByResourceTypeId = {}
      finally
        @loadingSuppliers = false

</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-menus'
@import '~/assets/stylesheets/starpeace-menus-tycoon-details'


.tycoon-tabs
  .suppliers-tab
    display: grid
    grid-template-columns: 50% 50%
    height: 100%

    .sp-scrollbar
      overflow-y: scroll

.basic-table
  td
    &.column-action
      .is-flex
        column-gap: 1rem

  &.suppliers
    th
      &.column-suppliers-count
        width: 8rem

      &.column-suppliers-price,
      &.column-ifel-price
        width: 10rem

      &.column-action
        width: 20rem

    td
      &.column-product
        text-transform: capitalize

  &.supplier-details
    th
      &.column-price
        width: 8rem

      &.column-action
        width: 10rem

    .is-flex
      column-gap: 1rem

</style>
