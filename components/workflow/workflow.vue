<template lang='pug'>
client-only
  transition(name='fade-in')
    #workflow-container(v-show='is_active')
      .card.is-starpeace(:style='workflow_card_style', :class='workflow_card_class')
        .card-header(v-show='has_header')
          .card-header-title.card-header-planet(v-show="status == 'pending_planet'")
            a(v-on:click.stop.prevent='reset_galaxy') {{translate('ui.workflow.universe.multiverse.label')}}
            span.title-spacer /
            span.planet-name {{ current_galaxy_name }}

        .card-content
          menu-loading(v-show="status == 'initializing'", :message="translate('ui.workflow.loading.initializing')")

          menu-universe(v-show="status == 'pending_universe'", :managers='managers', :ajax_state='ajax_state', :client_state='client_state')
          menu-planet(v-show="status == 'pending_planet'", :managers='managers', :client_state='client_state')
          menu-loading(v-show="status == 'pending_visa'", :message="translate('ui.workflow.loading.pending_visa')")
          menu-loading(v-show="status == 'pending_assets'", :message="translate('ui.workflow.loading.pending_assets')")
          menu-loading(v-show="status == 'pending_planet_details'", :message="translate('ui.workflow.loading.pending_planet_details')")
          menu-loading(v-show="status == 'pending_player_data'", :message="translate('ui.workflow.loading.pending_player_data')")
          menu-loading(v-show="status == 'pending_initialization'", :message="translate('ui.workflow.loading.pending_initialization')")
          menu-loading(v-show="status == 'ready'", :message="translate('ui.workflow.loading.initializing')")

</template>

<script lang='coffee'>
import WorkflowLoading from '~/components/workflow/workflow-loading.vue'
import WorkflowPlanet from '~/components/workflow/workflow-planet.vue'
import WorkflowUniverse from '~/components/workflow/workflow-universe.vue'

import Logger from '~/plugins/starpeace-client/logger.coffee'
import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'

STATUS_MAX_WIDTHS = {
  'pending_universe': '60rem'
  'pending_visa': '20rem'
  'pending_planet': '80rem'
  'pending_assets': '20rem'
  'pending_initialization': '20rem'
}

export default
  components:
    'menu-loading': WorkflowLoading
    'menu-planet': WorkflowPlanet
    'menu-universe': WorkflowUniverse

  props:
    ajax_state: Object
    client_state: Object
    managers: Object

  computed:
    status: -> @client_state.workflow_status
    is_active: -> @status != 'ready'

    workflow_card_class: -> { 'has-header': @has_header, 'full-height': @status == 'pending_universe', 'sp-scrollbar': @status == 'pending_planet' }
    workflow_card_style: -> { 'width': @max_width, 'max-height': @max_height }

    has_header: -> @status == 'pending_planet'
    max_width: -> STATUS_MAX_WIDTHS[@status]
    max_height: -> if @status == 'pending_universe' then '60rem' else 'inherit'

    current_galaxy_name: ->
      if @client_state.identity.galaxy_id? && @client_state.core.galaxy_cache.has_galaxy_metadata(@client_state.identity.galaxy_id) then @client_state.core.galaxy_cache.galaxy_metadata(@client_state.identity.galaxy_id).name else

  methods:
    translate: (key) -> if @managers? then @managers.translation_manager.text(key) else key

    reset_galaxy: ->
      @client_state.identity.reset_state()
      @client_state.update_state()
      window.document.title = "STARPEACE" if window?.document?
</script>

<style lang='sass' scoped>
#workflow-container
  align-items: center
  display: flex
  flex-direction: column
  grid-column-start: 2
  grid-column-end: 3
  grid-row-start: start-render
  grid-row-end: end-toolbar
  margin: 0
  max-height: 100%
  justify-content: center
  overflow: hidden
  position: relative

.existing-corporations
  margin-bottom: 1rem

.card
  display: inline-block
  overflow: hidden
  position: relative
  text-align: left
  transition: max-width .5s
  z-index: 1050

  &.sp-scrollbar
    overflow-y: auto

  .card-header-planet
    .title-spacer
      font-weight: normal
      margin: 0 .75rem

    a
      color: #fff
      font-weight: normal

  .card-content
    height: 100%
    position: relative
    transition: width .5s

  &.has-header
    .card-content
      height: calc(100% - 3rem)

  &.full-height
    height: calc(100% - 2rem)

</style>
