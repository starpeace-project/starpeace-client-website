<template lang='pug'>
.inspect-details
  template(v-if='loading')
    img.loading-image.starpeace-logo.logo-loading

  template(v-else)
    .inspect-tabs.tabs.is-small.is-marginless
      ul
        li(:class="{ 'is-active': tab_index == 0 }" @click.stop.prevent='tab_index = 0')
          a {{$translate('toolbar.inspect.tradecenter.tabs.general')}}
        li(:class="{ 'is-active': tab_index == 1 }" @click.stop.prevent='tab_index = 1')
          a {{$translate('toolbar.inspect.tradecenter.tabs.products')}}

    .inspect-body.columns.is-marginless
      template(v-if='tab_index == 0')
        .column.is-narrow.extra-padding-right.general
          div
            span.sp-kv-key {{$translate('toolbar.inspect.tradecenter.label.name')}}:
            span.sp-kv-value
              template(v-if='name') {{name}}
              template(v-else) {{$translate('ui.misc.none')}}
          div
            span.sp-kv-key {{$translate('toolbar.inspect.tradecenter.label.built')}}:
            span.sp-kv-value Jan 1, 2500
          div
            span.sp-kv-key {{$translate('toolbar.inspect.tradecenter.label.owner')}}:
            span.sp-kv-value IFEL

        .column.is-narrow.extra-padding-left.general-actions
          a.button.is-fullwidth.is-starpeace(disabled) {{$translate('toolbar.inspect.tradecenter.action.connect')}}

      template(v-else-if='tab_index == 1')
        .column.is-paddingless.products
          toolbar-inspect-shared-tab-products(
            :client-state='clientState'
            :products='products'
          )

</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';

declare interface ToolbarInspectTradeCenterData {
  tab_index: number;
  product_index: number;

  details_promise: null;
  details: null;
}

export default {
  props: {
    clientState: { type: ClientState, required: true },

    building: { type: Object, required: true },
    definition: Object,
    simulation: Object
  },

  data (): ToolbarInspectTradeCenterData {
    return {
      tab_index: 0,
      product_index: 0,

      details_promise: null,
      details: null
    };
  },

  computed:  {
    loading (): boolean { return !!this.details_promise || !this.details; },

    building_id () { return this.building.id; },
    name () {
      if (this.building?.name) return this.building.name;
      if (this.definition?.name) return this.$translate(this.definition.name);
      return null;
    },

    products () { return this.details?.products ?? []; }
  },

  watch: {
    building_id: {
      immediate: true,
      handler () { this.refresh_details(); }
    }
  },

  methods: {
    resource_type_label (type_id: string) { return this.$translate(this.clientState.core.planet_library.resource_type_for_id(type_id)?.label_plural); },

    async refresh_details (): Promise<void> {
      this.details = null;
      if (!this.building_id) return;

      try {
        this.details_promise = this.$starpeaceClient.managers.building_manager.load_building_details(this.building_id);
        this.details = await this.details_promise;
        this.details_promise = null;
      }
      catch (err) {
        this.clientState.add_error_message('Failure loading building details, please try again', err);
        this.details_promise = null;
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'
@import '~/assets/stylesheets/starpeace-inspect'

.column
  &.general-actions
    min-width: 16rem

  &.products
    overflow: hidden
    position: relative

</style>
