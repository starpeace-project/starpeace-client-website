<template lang='haml'>
%no-ssr
  %transition{name:'fade-in'}
    #workflow-container{'v-show':'is_active'}
      %workflow-corporation{'v-show':"status == 'pending_system' || status == 'pending_planet'", 'v-bind:client':'client', 'v-bind:game_state':'game_state', 'v-bind:system_name':'current_system_name'}

      .card.is-starpeace{'v-bind:style':'workflow_card_style', 'v-bind:class':'workflow_card_class'}
        .card-header{'v-show':'has_header'}
          .card-header-title{'v-show':"status == 'pending_system'"}
            Planetary Systems
          .card-header-title.card-header-planet{'v-show':"status == 'pending_planet'"}
            %a{'v-on:click.stop.prevent':'reset_planetary_system()'} Planetary Systems
            %span.title-spacer \/
            %span.planet-name {{ current_system_name }}

        .card-content
          %menu-loading{'v-show':"status == 'initializing'", message:'Initializing...'}

          %menu-visa-type{'v-show':"status == 'pending_visa_type'", 'v-bind:client':'client', 'v-bind:game_state':'game_state'}

          %menu-loading{'v-show':"status == 'pending_identity'", message:'Simulating identity authentication with provider...'}
          %menu-loading{'v-show':"status == 'pending_session'", message:'Authorizing session for identity...'}

          %menu-loading{'v-show':"status == 'pending_tycoon_metadata'", message:'Retrieving tycoon information...'}
          %menu-loading{'v-show':"status == 'pending_system_metadata'", message:'Retrieving planetary systems information...'}
          %menu-system{'v-show':"status == 'pending_system'", 'v-bind:client':'client', 'v-bind:game_state':'game_state'}
          %menu-loading{'v-show':"status == 'pending_planet_metadata'", message:'Retrieving system information...'}
          %menu-planet{'v-show':"status == 'pending_planet'", 'v-bind:client':'client', 'v-bind:game_state':'game_state'}

          %menu-loading{'v-show':"status == 'pending_assets'", message:'Loading assets and resources...'}
          %menu-loading{'v-show':"status == 'pending_initialization'", message:'Initializing client environment...'}
          %menu-loading{'v-show':"status == 'ready'", message:'Initializing...'}
</template>

<script lang='coffee'>
import WorkflowCorporation from '~/components/workflow/workflow-corporation.vue'
import WorkflowLoading from '~/components/workflow/workflow-loading.vue'
import WorkflowPlanet from '~/components/workflow/workflow-planet.vue'
import WorkflowSystem from '~/components/workflow/workflow-system.vue'
import WorkflowVisaType from '~/components/workflow/workflow-visa-type.vue'

import Logger from '~/plugins/starpeace-client/logger.coffee'
import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'

STATUS_MAX_WIDTHS = {
  'pending_visa_type': '45rem'
  'pending_identity': '30rem'
  'pending_session': '20rem'
  'pending_tycoon_metadata': '20rem'
  'pending_system_metadata': '20rem'
  'pending_system': '50rem'
  'pending_planet_metadata': '20rem'
  'pending_planet': '50rem'
  'pending_assets': '20rem'
  'pending_initialization': '20rem'
}

export default
  components:
    'workflow-corporation': WorkflowCorporation
    'menu-loading': WorkflowLoading
    'menu-planet': WorkflowPlanet
    'menu-system': WorkflowSystem
    'menu-visa-type': WorkflowVisaType

  props:
    client: Object
    event_listener: Object
    game_state: Object

  watch:
    status: (new_value, old_value) ->
      @client.managers.refresh_systems_metadata() if new_value == 'pending_system_metadata' && !@game_state.common_metadata.is_refreshing_systems_metadata()
      @client.managers.refresh_planets_metadata() if new_value == 'pending_planet_metadata' && !@game_state.is_refreshing_planets_metadata_for_current_system()

  computed:
    status: ->
      return 'initializing' unless @game_state? && @game_state.common_metadata.state_counter? && @game_state.session_state.state_counter?

      unless @game_state.initialized
        return 'pending_visa_type' unless @game_state.session_state.visa_type?
        return 'pending_identity' unless @game_state.session_state.identity?
        return 'pending_session' unless @game_state.session_state.session_token?

        return 'pending_tycoon_metadata' if @game_state.session_state.identity.is_tycoon() && !@game_state.session_state.has_tycoon_metadata_fresh()
        return 'pending_system_metadata' unless @game_state.common_metadata.has_systems_metadata_fresh()
        return 'pending_system' unless @game_state.session_state.system_id?
        return 'pending_planet_metadata' unless @game_state.has_planets_metadata_fresh_for_current_system()
        return 'pending_planet' unless @game_state.session_state.planet_id?

        return 'pending_assets' unless @game_state.has_assets
        return 'pending_initialization'

      'ready'

    is_active: -> @status != 'ready'

    workflow_card_class: -> { 'has-header': @has_header, 'full-height': @status == 'pending_visa_type', 'sp-scrollbar': @status == 'pending_system' || @status == 'pending_planet' }
    workflow_card_style: -> { 'width': @max_width, 'max-height': @max_height }

    has_header: -> @status == 'pending_system' || @status == 'pending_planet'
    max_width: -> STATUS_MAX_WIDTHS[@status]
    max_height: -> if @status == 'pending_visa_type' then '60rem' else 'inherit'

    current_system_name: -> if @game_state?.session_state.system_id? then @game_state.current_system_metadata()?.name else ''

  methods:
    reset_planetary_system: -> @client.reset_system()
</script>

<style lang='sass' scoped>
#workflow-container
  align-items: center
  display: flex
  flex-direction: column
  grid-column-start: 2
  grid-column-end: 3
  grid-row-start: 2
  grid-row-end: 6
  margin: 0
  max-height: 100%
  justify-content: center
  overflow: hidden
  position: relative

.existing-corporations
  margin-bottom: 1rem

.card
  display: inline-block

  position: relative
  transition: max-width .5s
  text-align: left
  z-index: 1050
  overflow: hidden

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

  &.full-height
    height: calc(100% - 2rem)

</style>
