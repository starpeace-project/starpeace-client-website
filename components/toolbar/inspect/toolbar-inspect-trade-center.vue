<template lang='pug'>
.inspect-details
  template(v-if='loading')
    img.loading-image.starpeace-logo.logo-loading

  template(v-else)
    .inspect-tabs.tabs.is-small.is-marginless
      ul
        li(v-for='tab in tabs' :class="{ 'is-active': tabId == tab.id }" @click.stop.prevent='tabId = tab.id')
          a {{$translate(tab.label)}}

    .inspect-body.columns.is-marginless
      template(v-if="tabId == 'general'")
        .column.is-narrow.extra-padding-right.general
          div
            span.sp-kv-key {{$translate('toolbar.inspect.tradecenter.label.name')}}:
            span.sp-kv-value
              template(v-if='name') {{name}}
              template(v-else) {{$translate('ui.misc.none')}}
          div
            span.sp-kv-key {{$translate('toolbar.inspect.tradecenter.label.built')}}:
            span.sp-kv-value {{constructionDate}}
          div
            span.sp-kv-key {{$translate('toolbar.inspect.tradecenter.label.owner')}}:
            span.sp-kv-value IFEL

        .column.is-narrow.extra-padding-left.general-actions
          a.button.is-fullwidth.is-starpeace(disabled) {{$translate('toolbar.inspect.tradecenter.action.connect')}}

      template(v-else-if="tabId == 'products'")
        .column.is-paddingless.is-relative.is-clipped
          toolbar-inspect-shared-tab-products(
            :client-state='clientState'
            :products='products'
          )

      template(v-else-if="tabId == 'jobs'")
        .column.is-paddingless.is-relative.is-clipped
          toolbar-inspect-shared-tab-jobs(
            :client-state='clientState'
            :jobs='jobs'
          )

</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';

declare interface ToolbarInspectTradeCenterData {
  tabId: string | undefined;
  product_index: number;

  details_promise: any | null;
  details: any | null;
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
      tabId: undefined,
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
    constructionDate () {
      return this.building.constructionFinishedAt?.toFormat('LLL dd, yyyy');
    },

    products () { return this.details?.products ?? []; },
    jobs () { return this.details?.labors ?? []; },

    tabs () {
      const tabs = [
        {
          id: 'general',
          label: 'toolbar.inspect.common.tabs.general'
        }
      ];
      if (this.products.length > 0) {
        tabs.push({
          id: 'products',
          label: 'toolbar.inspect.common.tabs.products'
        });
      }
      if (this.jobs.length > 0) {
        tabs.push({
          id: 'jobs',
          label: 'toolbar.inspect.common.tabs.jobs'
        });
      }
      return tabs;
    }
  },

  watch: {
    building_id: {
      immediate: true,
      handler () { this.refresh_details(); }
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

</style>
