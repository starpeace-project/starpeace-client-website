<template lang='haml'>
%no-ssr
  %transition{name:'fade-in'}
    #workflow-container{'v-show':'is_active'}
      %workflow-corporation{'v-show':"status == 'pending_system' || status == 'pending_planet'", 'v-bind:client':'client', 'v-bind:client_state':'client_state', 'v-bind:system_name':'current_system_name'}

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

          %menu-visa-type{'v-show':"status == 'pending_visa_type'", 'v-bind:client':'client', 'v-bind:client_state':'client_state'}
          %menu-loading{'v-show':"status == 'pending_identity'", message:'Simulating identity authentication with provider...'}
          %menu-loading{'v-show':"status == 'pending_session'", message:'Authorizing session for identity...'}

          %menu-loading{'v-show':"status == 'pending_tycoon_metadata'", message:'Retrieving tycoon information...'}
          %menu-loading{'v-show':"status == 'pending_system_metadata'", message:'Retrieving planetary systems information...'}
          %menu-system{'v-show':"status == 'pending_system'", 'v-bind:client':'client', 'v-bind:client_state':'client_state'}
          %menu-planet{'v-show':"status == 'pending_planet'", 'v-bind:client':'client', 'v-bind:client_state':'client_state'}

          %menu-loading{'v-show':"status == 'pending_assets'", message:'Loading assets and resources...'}
          %menu-loading{'v-show':"status == 'pending_planet_details'", message:'Loading planet details...'}
          %menu-loading{'v-show':"status == 'pending_player_data'", message:'Loading tycoon and corporation data...'}
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
    client_state: Object

  computed:
    status: -> @client_state.workflow_status
    is_active: -> @status != 'ready'

    workflow_card_class: -> { 'has-header': @has_header, 'full-height': @status == 'pending_visa_type', 'sp-scrollbar': @status == 'pending_system' || @status == 'pending_planet' }
    workflow_card_style: -> { 'width': @max_width, 'max-height': @max_height }

    has_header: -> @status == 'pending_system' || @status == 'pending_planet'
    max_width: -> STATUS_MAX_WIDTHS[@status]
    max_height: -> if @status == 'pending_visa_type' then '60rem' else 'inherit'

    current_system_name: -> if @client_state?.player?.system_id? then @client_state.current_system_metadata()?.name else ''

  methods:
    reset_planetary_system: ->
      @client_state.reset_system()
      window.document.title = "STARPEACE" if window?.document?
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
