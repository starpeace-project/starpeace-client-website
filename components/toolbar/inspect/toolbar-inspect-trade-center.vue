<template lang='pug'>
.inspect-details
  template(v-if='loading')
    img.loading-image.starpeace-logo.logo-loading

  template(v-else)
    .inspect-tabs.tabs.is-small.is-marginless
      ul
        li(:class="{ 'is-active': tab_index == 0 }" @click.stop.prevent='tab_index = 0')
          a {{translate('toolbar.inspect.tradecenter.tabs.general')}}
        li(:class="{ 'is-active': tab_index == 1 }" @click.stop.prevent='tab_index = 1')
          a {{translate('toolbar.inspect.tradecenter.tabs.products')}}

    .inspect-body.columns.is-marginless
      template(v-if='tab_index == 0')
        .column.is-narrow.extra-padding-right.general
          div
            span.sp-kv-key {{translate('toolbar.inspect.tradecenter.label.name')}}:
            span.sp-kv-value
              template(v-if='name') {{name}}
              template(v-else) {{translate('ui.misc.none')}}
          div
            span.sp-kv-key {{translate('toolbar.inspect.tradecenter.label.built')}}:
            span.sp-kv-value Jan 1, 2500
          div
            span.sp-kv-key {{translate('toolbar.inspect.tradecenter.label.owner')}}:
            span.sp-kv-value IFEL

        .column.is-narrow.extra-padding-left.general-actions
          a.button.is-fullwidth.is-starpeace(disabled) {{translate('toolbar.inspect.tradecenter.action.connect')}}

      template(v-else-if='tab_index == 1')
        .column.is-paddingless.products
          tab-products(
            :client-state='clientState'
            :managers='managers'
            :products='products'
          )

</template>

<script lang='coffee'>
import TabProducts from '~/components/toolbar/inspect/shared/tab-products.vue'

export default
  components: {
    TabProducts
  }

  props:
    clientState: Object
    managers: Object

    building: Object
    definition: Object
    simulation: Object

  data: ->
    tab_index: 0
    product_index: 0

    details_promise: null
    details: null

  computed:
    loading: -> @details_promise? || !@details?

    building_id: -> @building.id
    name: ->
      return @building.name if @building?.name?
      return @translate(@definition.name) if @definition?.name?
      null

    products: -> @details?.products || []

  watch:
    building_id:
      immediate: true
      handler: -> @refresh_details()

  methods:
    translate: (key) -> if @managers? then @managers.translation_manager.text(key) else key

    resource_type_label: (type_id) -> @translate(@clientState.core.planet_library.resource_type_for_id(type_id)?.label_plural)

    refresh_details: ->
      @details = null
      return unless @building_id?

      try
        @details_promise = @managers.building_manager.load_building_details(@building_id)
        @details = await @details_promise
        @details_promise = null
      catch err
        @client_state.add_error_message('Failure loading building details, please try again', err)
        @details_promise = null

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'
@import '~assets/stylesheets/starpeace-inspect'

.column
  &.general-actions
    min-width: 16rem

  &.products
    overflow: hidden
    position: relative

</style>
