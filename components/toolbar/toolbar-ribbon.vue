<template lang='pug'>
client-only
  transition(name='fade')
    #toolbar-ribbon(v-show='is_ready' v-cloak='true')
      .action-camera-in
        a.button.is-fullwidth.is-fullheight.is-small.is-starpeace(@click.stop.prevent='client_state.camera.camera_zoom_in()')
          font-awesome-icon(:icon="['fas', 'plus']")
      .action-camera-out
        a.button.is-fullwidth.is-fullheight.is-small.is-starpeace(@click.stop.prevent='client_state.camera.camera_zoom_out()')
          font-awesome-icon(:icon="['fas', 'minus']")

      .action-rotate-ccw
        a.button.is-fullwidth.is-fullheight.is-small.is-starpeace
          font-awesome-icon(:icon="['fas', 'redo-alt']")
      .action-rotate-cw
        a.button.is-fullwidth.is-fullheight.is-small.is-starpeace
          font-awesome-icon(:icon="['fas', 'undo-alt']")

      .action-overlays
        a.button.is-fullwidth.is-fullheight.is-small.is-uppercase.is-starpeace.is-starpeace-light(:class='menu_class_overlay' @click.stop.prevent='interface_state.toggle_overlay()')
          | {{translate('footer.ribbon.overlay')}}
      .action-zones
        a.button.is-fullwidth.is-fullheight.is-small.is-uppercase.is-starpeace.is-starpeace-light(:class='menu_class_zones' @click.stop.prevent='interface_state.toggle_zones()')
          | {{translate('footer.ribbon.city_zones')}}

      .action-inspect
        a.button.is-fullwidth.is-fullheight.is-small.is-uppercase.is-starpeace.is-starpeace-light
          | {{translate('footer.ribbon.inspect')}}

      .details-ticker.primary
        | {{translate('footer.ribbon.message.welcome')}}
      .details-ticker.secondary
        | {{translate('footer.ribbon.hint.tycoon')}}

      .action-jump-back
        a.button.is-fullwidth.is-fullheight.is-small.is-uppercase.is-starpeace(:disabled='!can_jump_back' @click.stop.prevent='jump_back')
          font-awesome-icon(:icon="['fas', 'chevron-left']")
          | {{translate('footer.ribbon.jump_back')}}
      .action-jump-next
        a.button.is-fullwidth.is-fullheight.is-small.is-uppercase.is-starpeace(:disabled='!can_jump_next' @click.stop.prevent='jump_next')
          | {{translate('footer.ribbon.jump_next')}}
          font-awesome-icon(:icon="['fas', 'chevron-right']")
      .action-jump-town
        a.button.is-fullwidth.is-fullheight.is-small.is-uppercase.is-starpeace(@click.stop.prevent='jump_town')
          | {{translate('footer.ribbon.jump_town')}}

</template>

<script lang='coffee'>
export default
  props:
    client_state: Object
    managers: Object

  computed:
    interface_state: -> @client_state.interface
    is_ready: -> @client_state.initialized && @client_state?.workflow_status == 'ready'

    menu_class_overlay: -> { 'is-active': @interface_state?.show_overlay || false }
    menu_class_zones: -> { 'is-active': @interface_state?.show_zones || false }


    can_jump_back: ->
      return false unless @client_state.camera.view_offset_x? && @client_state.camera.view_offset_y? && @client_state.interface.location_history.length
      return true if @client_state.interface.location_index < @client_state.interface.location_history.length - 1
      location = @client_state.current_location()
      return false unless location?
      !@client_state.matches_jump_history(location.i, location.j)
    can_jump_next: -> @client_state.interface.location_index > 0

  methods:
    translate: (key) -> if @managers? then @managers.translation_manager.text(key) else key

    jump_back: ->
      @client_state.jump_back() if @can_jump_back
    jump_next: ->
      @client_state.jump_next() if @can_jump_next
    jump_town: ->
      town = @client_state.town_for_location()
      @client_state.jump_to(town.map_x, town.map_y, town.building_id) if town?.building_id? && town?.map_x? && town?.map_y?

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.button
  &.is-starpeace
    &.is-small
      font-size: .875rem
      line-height: 1.5
      border-radius: .2rem

  &.is-fullheight
    height: 100%

#toolbar-ribbon
  background-color: #000
  display: grid
  grid-column-start: 1
  grid-column-end: 3
  grid-row-start: 4
  grid-row-end: 5
  grid-template-columns: [start-camera-1] 3rem [end-camera-1 start-camera-2] 3rem [end-camera-2 start-overlay] 10rem [end-overlay start-inspect] 13rem [end-inspect start-ticker] auto [end-ticker start-jump-1] 9rem [end-jump-1 start-jump-2] 9rem [end-jump-2]
  grid-template-rows: [start-row-1] 50% [end-row-1 start-row-2] 50% [end-row-2]
  margin: 0

  .action-camera-in
    grid-area: start-row-1 / start-camera-1 / end-row-1 / end-camera-1
    padding: .25rem .125rem .125rem
  .action-camera-out
    grid-area: start-row-1 / start-camera-2 / end-row-1 / end-camera-2
    padding: .25rem .125rem .125rem

  .action-rotate-ccw
    grid-area: start-row-2 / start-camera-1 / end-row-2 / end-camera-1
    padding: .125rem
    .fa-redo-alt
      transform: rotate(-20deg)
  .action-rotate-cw
    grid-area: start-row-2 / start-camera-2 / end-row-2 / end-camera-2
    padding: .125rem
    .fa-undo-alt
      transform: rotate(20deg)

  .action-overlays
    grid-area: start-row-1 / start-overlay / end-row-1 / end-overlay
    letter-spacing: .1rem
    padding: .25rem .125rem .125rem
  .action-zones
    grid-area: start-row-2 / start-overlay / end-row-2 / end-overlay
    letter-spacing: .1rem
    padding: .125rem

  .action-inspect
    grid-area: start-row-1 / start-inspect / end-row-2 / end-inspect
    letter-spacing: .2rem
    padding: .25rem .125rem .125rem

    .button
      font-size: 1.25rem
      font-weight: 1000

  .details-ticker
    background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAMAAAADCAYAAABWKLW/AAAABmJLR0QA/wD/AP+gvaeTAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAEElEQVQI12NgYGD4z0AQAAAjBAEAIsfjuAAAAABJRU5ErkJggg==')
    background-repeat: space
    font-weight: 1000
    letter-spacing: .05rem
    overflow: hidden
    padding: .35rem .5rem .25rem
    text-overflow: ellipsis
    vertical-align: middle
    white-space: nowrap

    &.primary
      background-color: rgba(0, 255, 0, .3)
      color: #00ff00
      grid-area: start-row-1 / start-ticker / end-row-1 / end-ticker

    &.secondary
      background-color: rgba(255, 128, 0, .3)
      color: #ff8000
      grid-area: start-row-2 / start-ticker / end-row-2 / end-ticker

  .action-jump-back
    grid-area: start-row-1 / start-jump-1 / end-row-1 / end-jump-1
    letter-spacing: .1rem
    padding: .125rem

    .fa-chevron-left
      margin-right: .5rem

  .action-jump-next
    grid-area: start-row-1 / start-jump-2 / end-row-1 / end-jump-2
    letter-spacing: .1rem
    padding: .125rem

    .fa-chevron-right
      margin-left: .5rem

  .action-jump-town
    grid-area: start-row-2 / start-jump-1 / end-row-2 / end-jump-2
    letter-spacing: .1rem
    padding: .125rem


</style>
