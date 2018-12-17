<template lang='haml'>
#establish-corporation-container{'v-if':'is_visible'}
  .modal-background
  .card.is-starpeace.has-header
    .card-header
      .card-header-title
        Establish a Corporation
    .card-content.sp-menu-background
      .content
        %p.intro
          Welcome to
          %span.planet-name {{planet_name()}}
          , Tycoon!
        %p.info
          Establish a corporation to participate in the planet economy. IFEL Regulations limit Tycoons to a single corporation per planet; one or more companies can be formed under each corporation.
        %p.info
          Corporation name is unique across all systems and tycoons; name may be re-used across multiple planets once claimed by Tycoon.
    %footer.card-footer
      .card-footer-item.level.is-mobile
        .level-left
          %a.button.is-primary.is-medium.is-outlined{'v-on:click.stop.prevent':'cancel()'} Back to Planetary Systems
        .level-right
          %a.button.is-primary.is-medium{'v-on:click.stop.prevent':'establish()'} Establish Corporation

</template>

<script lang='coffee'>
export default
  props:
    client: Object
    translation_manager: Object
    client_state: Object

  computed:
    is_visible: -> @client_state.initialized && @client_state.workflow_status == 'ready' && @client_state.identity.identity.is_tycoon() && !@client_state.player.corporation_id?.length

  methods:
    planet_name: -> @client_state?.current_planet_metadata().name

    cancel: () ->
      @client_state.change_planet_id(null)
      window.document.title = "STARPEACE" if window?.document?

    establish: () ->
      console.log 'establish corp'
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

#establish-corporation-container
  display: flex
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 2
  grid-row-end: 6
  margin: 0
  position: relative
  overflow: hidden
  z-index: 1500

  > .card
    background-color: $sp-dark-bg
    margin: auto
    margin-top: 25vh
    max-width: 50rem
    z-index: 1500

    .content
      color: $sp-primary

      .intro
        font-size: 1.3rem
        font-weight: bold

      .info
        font-size: 1.15rem

      .planet-name
        color: #fff

</style>
