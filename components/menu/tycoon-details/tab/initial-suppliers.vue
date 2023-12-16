<template lang='pug'>
.sp-tab
  .suppliers-tab
    .sp-scrollbar
      table.basic-table.sp-striped.sp-solid-header.sp-sticky-header.suppliers(:class="{'hoverable': is_self}")
        thead
          tr
            th.sp-kv-key.column-product {{$translate('ui.menu.tycoon_details.tab.initial_suppliers.product')}}
            th.has-text-right.sp-kv-key.column-suppliers-count {{$translate('ui.menu.tycoon_details.tab.initial_suppliers.suppliers')}}
            th.has-text-right.sp-kv-key.column-suppliers-price {{$translate('ui.menu.tycoon_details.tab.initial_suppliers.average_price')}}
            th.has-text-right.sp-kv-key.column-ifel-price {{$translate('ui.menu.tycoon_details.tab.initial_suppliers.ifel_price')}}
            th.has-text-centered.sp-kv-key.column-action {{$translate('ui.menu.tycoon_details.tab.initial_suppliers.trade_center')}}

        tbody
          tr(v-for='resource_type in sorted_resource_types' :class="{'is-selected': selectedSupplierResourceTypeId == resource_type.id}" @click.stop.prevent='selectedSupplierResourceTypeId = resource_type.id')
            td.is-size-5.column-product {{$translate(resource_type.label_plural)}}
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
            th.sp-kv-key {{$translate('ui.menu.tycoon_details.tab.initial_suppliers.corporation_name')}}
            th.sp-kv-key {{$translate('ui.menu.tycoon_details.tab.initial_suppliers.building_name')}}
            th.has-text-right.sp-kv-key.column-price {{$translate('ui.menu.tycoon_details.tab.initial_suppliers.price')}}
            th.column-action

        template(v-if='selectedSupplierResourceTypeId')
          tbody
            template(v-if='!suppliers_for_selected_resource_type.length')
              tr
                td.has-text-centered(colspan=4) {{$translate('ui.misc.none')}}

            template(v-else)
              tr(v-for='supplier in suppliers_for_selected_resource_type')
                template(v-if='supplier.isTradeCenter')
                  td IFEL
                  td {{$translate('ui.menu.tycoon_details.tab.initial_suppliers.trade_center')}}
                  td.has-text-right
                    misc-money-text(:value='supplier.price' no_styling)
                  td
                    .is-flex.is-justify-content-center(v-if='has_corporation && is_self')
                      button.button.is-small.is-starpeace(disabled) {{$translate('misc.action.cancel')}}

          tfoot(v-if='has_corporation && is_self')
            tr
              td.has-text-centered.py-4(colspan=4)
                .is-flex.is-justify-content-center
                  button.button.is-starpeace(@click.stop.prevent='' disabled) {{$translate('ui.menu.tycoon_details.tab.initial_suppliers.action.add_supplier')}}
                  button.button.is-starpeace(@click.stop.prevent='' disabled) {{$translate('misc.action.manage')}}

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state';

declare interface InitialSuppliersData {
  loadingSuppliers: boolean;
  suppliersByResourceTypeId: Record<string, any>;
  selectedSupplierResourceTypeId: string | null;
}

export default {
  props: {
    clientState: { type: ClientState, required: true },
    tycoonId: String,
    corporationId: String
  },

  data (): InitialSuppliersData {
    return {
      loadingSuppliers: false,

      suppliersByResourceTypeId: {},
      selectedSupplierResourceTypeId: null
    };
  },

  computed: {
    has_corporation (): boolean { return (this.corporationId?.length ?? 0) > 0; },
    is_self (): boolean { return this.clientState.player.tycoon_id === this.tycoonId; },

    corporation (): any | null { return this.has_corporation ? this.clientState.core.corporation_cache.metadata_for_id(this.corporationId) : null; },

    resource_types_by_id () { return _.keyBy(_.filter(this.clientState?.core?.planet_library?.all_resource_types(), (t) => t.price > 0), 'id'); },
    sorted_resource_types () { return _.orderBy(Object.values(this.resource_types_by_id), [(t) => this.$translate(t.label_plural)], ['asc']); },

    supplier_info_by_resource_id () {
      const info: Record<string, any> = {};
      for (const type of this.sorted_resource_types) {
        const count = (this.suppliersByResourceTypeId[type.id]?.tradeCenter ? 1 : 0) + (this.suppliersByResourceTypeId[type.id]?.suppliers?.length ?? 0);
        const totalPrice = (this.suppliersByResourceTypeId[type.id]?.tradeCenter ? type.price : 0) + (this.suppliersByResourceTypeId[type.id]?.suppliers ?? []).reduce(((s, i) => s + i), 0)
        info[type.id] = {
          count: count,
          averagePrice: count > 0 ? (totalPrice / count) : 0
        };
      }
      return info;
    },

    suppliers_for_selected_resource_type (): Array<any> {
      if (!this.selectedSupplierResourceTypeId) return [];
      const suppliers = [];
      if (this.suppliersByResourceTypeId[this.selectedSupplierResourceTypeId]?.tradeCenter) {
        suppliers.push({
          isTradeCenter: true,
          price: this.resource_types_by_id[this.selectedSupplierResourceTypeId]?.price ?? 0
        });
      }
      return suppliers;
    }
  },

  mounted () {
    this.refresh_details();
  },

  watch: {
    tycoonId (newValue, oldValue) {
      if (newValue !== oldValue) {
        if (oldValue) this.reset_state();
        this.refresh_details();
      }
    },
    corporationId (newValue, oldValue) {
      if (newValue !== oldValue) {
        if (oldValue) this.reset_state();
        this.refresh_details();
      }
    }
  },

  methods: {
    toggle_supplier_trade_center (type_id: string) {
      if (this.suppliersByResourceTypeId[type_id]) {
        this.suppliersByResourceTypeId[type_id].tradeCenter = !this.suppliersByResourceTypeId[type_id].tradeCenter;
      }
    },

    reset_state () {
      this.suppliersByResourceTypeId = {};
      this.selectedSupplierResourceTypeId = null;
    },

    async refresh_details () {
      if (this.loadingSuppliers || !this.has_corporation) return;
      try {
        this.loadingSuppliers = true;
        this.suppliersByResourceTypeId = {};
        for (const resource_type of this.sorted_resource_types) {
          this.suppliersByResourceTypeId[resource_type.id] = {
            tradeCenter: true,
            suppliers: []
          };
        }
        if (!this.selectedSupplierResourceTypeId && this.sorted_resource_types.length > 0) {
          this.selectedSupplierResourceTypeId = this.sorted_resource_types[0].id;
        }
      }
      catch (err) {
        this.clientState.add_error_message('Failure loading tycoon details from server', err);
        this.suppliersByResourceTypeId = {};
      }
      finally {
        this.loadingSuppliers = false;
      }
    }
  }
}
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
