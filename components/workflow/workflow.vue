<template lang='haml'>
%no-ssr
  %transition{name:'fade-in'}
    #workflow-container{'v-show':'is_active'}
      .card{'v-bind:style':'workflow_card_style', 'v-bind:class':'workflow_card_class'}
        .card-header{'v-show':'has_header'}
          .card-header-title{'v-if':"status == 'pending_planetary_system'"}
            Planetary Systems
          .card-header-title.card-header-planet{'v-else-if':"status == 'pending_planet'"}
            %a{'v-on:click.stop.prevent':'reset_planetary_system()', href: '#'} Planetary Systems
            &nbsp;/&nbsp;{{ current_planetary_system_name() }}

        .card-content{'v-bind:style':'workflow_card_content_style'}
          %menu-loading{'v-show':"status == 'pending_identity_authentication'", message:'Authenticating identity with provider...'}
          %menu-identity{'v-show':"status == 'pending_identity'", 'v-bind:game_state':'game_state'}
          %menu-loading{'v-show':"status == 'pending_account'", message:'Authorizing session for identity...'}

          %menu-loading{'v-show':"status == 'pending_planetary_metadata'", message:'Retrieving planetary information...'}
          %menu-planetary-system{'v-show':"status == 'pending_planetary_system'", 'v-bind:game_state':'game_state', 'v-bind:planetary_metadata_manager':'planetary_metadata_manager'}
          %menu-planet{'v-show':"status == 'pending_planet'", 'v-bind:event_listener':'event_listener', 'v-bind:game_state':'game_state', 'v-bind:planetary_metadata_manager':'planetary_metadata_manager'}

          %menu-loading{'v-show':"status == 'pending_assets'", message:'Loading assets and resources...'}
          %menu-loading{'v-show':"status == 'pending_initialization'", message:'Initializing client environment...'}
          %menu-loading{'v-show':"status == 'ready'", message:'Initializing...'}
</template>

<script lang='coffee'>
import Logger from '~/plugins/starpeace-client/logger.coffee'
import WorkflowLoading from '~/components/workflow/workflow-loading.vue'
import WorkflowIdentity from '~/components/workflow/workflow-identity.vue'
import WorkflowPlanetarySystem from '~/components/workflow/workflow-planetary-system.vue'
import WorkflowPlanet from '~/components/workflow/workflow-planet.vue'
import TimeUtils from '~/plugins/starpeace-client/utils/time-utils.coffee'

STATUS_MAX_WIDTHS = {
  'pending_identity_authentication': '25rem'
  'pending_identity': '45rem'
  'pending_account': '25rem'
  'pending_planetary_metadata': '25rem'
  'pending_planetary_system': '50rem'
  'pending_planet': '50rem'
  'pending_assets': '20rem'
  'pending_initialization': '20rem'
}

export default
  components:
    'menu-loading': WorkflowLoading
    'menu-identity': WorkflowIdentity
    'menu-planetary-system': WorkflowPlanetarySystem
    'menu-planet': WorkflowPlanet

  props:
    event_listener: Object
    game_state: Object
    planetary_metadata_manager: Object

  computed:
    status: ->
      return 'initializing' unless @game_state?
      return 'pending_identity_authentication' if @game_state.current_identity_authentication?
      return 'pending_identity' unless @game_state.current_identity?
      return 'pending_account' unless @game_state.current_account?
      return 'pending_account_registration' unless @game_state.current_account?.registered

      return 'pending_planetary_metadata' unless @planetary_metadata_manager?.systems_metadata?.length
      return 'pending_planetary_system' unless @game_state.current_planetary_system?
      return 'pending_planet' unless @game_state.current_planet?

      return 'pending_assets' unless @game_state.has_assets
      return 'pending_initialization' unless @game_state.initialized

      'ready'

    is_active: -> @status != 'ready'

    workflow_card_class: -> { 'has-header': @has_header }
    workflow_card_style: -> { 'max-width': @max_width } #'width': @max_width,
    workflow_card_content_style: -> {  } #'width': @max_width

    has_header: -> @status == 'pending_planetary_system' || @status == 'pending_planet'
    max_width: -> STATUS_MAX_WIDTHS[@status]

  methods:
    reset_planetary_system: ->
      window.document.title = "STARPEACE" if window?.document?
      @game_state.current_planetary_system = null
      @game_state.current_planet = null
      @game_state.initialized = false
      # FIXME: TODO: what other state should be reset?
      Logger.debug "resetting planetary system back to empty, will need to re-select"

    current_planetary_system_name: -> @game_state?.current_planetary_system?.name
</script>

<style lang='sass' scoped>
#workflow-container
  grid-column-start: 2
  grid-column-end: 3
  grid-row-start: 2
  grid-row-end: 4
  margin: 0
  text-align: center

.card
  transition: max-width .5s
  z-index: 1050
  display: inline-block
  text-align: left

  .card-header-planet
    a
      color: #fff
      font-weight: normal

  .card-content
    transition: width .5s

</style>
