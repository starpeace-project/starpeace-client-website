<template lang='pug'>
#establish-corporation-container(v-if='is_visible')
  .modal-background
  .card.is-starpeace.has-header
    .card-header
      .card-header-title {{translate('ui.menu.corporation.establish.header')}}
    .card-content.sp-menu-background
      .content
        p.intro
          | {{translate('ui.menu.corporation.establish.planet.welcome')}}
          |
          span.planet-name {{planet_name()}}
          | ,
          |
          | {{translate('identity.tycoon')}}!
        p.info
          | {{translate('ui.menu.corporation.establish.description')}}
    footer.card-footer
      .card-footer-item.level.is-mobile
        .level-left
          a.button.is-primary.is-medium.is-outlined(v-on:click.stop.prevent='cancel') {{translate('ui.menu.corporation.establish.action.cancel')}}
        .level-right
          a.button.is-primary.is-medium(v-on:click.stop.prevent='establish') {{translate('ui.menu.corporation.establish.action.establish')}}

</template>

<script lang='coffee'>
export default
  props:
    managers: Object
    client_state: Object

  computed:
    is_visible: -> @client_state.initialized && @client_state.workflow_status == 'ready' && @client_state.is_tycoon() && !@client_state.player.corporation_id?.length

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    planet_name: -> @client_state?.current_planet_metadata().name

    cancel: () ->
      @client_state.reset_to_galaxy()
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
  grid-row-end: 7
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
