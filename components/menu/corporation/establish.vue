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
          %span.planet-name {{planet_name}}
          , Tycoon!
        %p.info
          Establish a corporation to participate in the planet economy. IFEL Regulations limit each Tycoon to a single corporation per planet, though multiple companies can be formed under each corporation.
        %p.info
          Corporation name is unique across all systems and tycoons; name may be re-used across multiple planets if claimed by Tycoon.
    %footer.card-footer
      .card-footer-item.level.is-mobile
        .level-left
          %a.button.is-primary.is-medium.is-outlined{'v-on:click.stop.prevent':'cancel()'} Back to Planetary Systems
        .level-right
          %a.button.is-primary.is-medium{href:'#', 'v-on:click.stop.prevent':'establish()', href: '#'} Establish Corporation

</template>

<script lang='coffee'>
export default
  props:
    client: Object
    translation_manager: Object
    game_state: Object

  computed:
    state_counter: -> if @game_state?.initialized then @game_state.session_state.state_counter else 0
    is_visible: -> @state_counter && @game_state.session_state.identity.is_tycoon() && !@game_state.session_state.corporation_id?.length

    planet_name: -> if @game_state?.session_state.planet_id?.length then @game_state.name_for_planet_id(@game_state.session_state.planet_id) else ''

  methods:
    cancel: () -> @client.reset_system()

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

  .modal-background
    background-color: #000
    height: 100%
    opacity: .7
    position: absolute
    width: 100%
    z-index: 1495

  > .card
    background-color: $sp-dark-bg
    margin: auto
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
