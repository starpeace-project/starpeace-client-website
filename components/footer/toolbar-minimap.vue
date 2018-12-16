<template lang='haml'>
%td.column-mini-map{rowspan: 2, 'v-show':'show_mini_map', 'v-bind:style':'mini_map_column_css_style'}
  #mini-map-container{'v-bind:style':'mini_map_container_css_style'}
    #mini-map-webgl-container
    %a.zoom.zoom-out{'v-on:click.stop.prevent':'client_state.interface.mini_map_zoom_in()'}
      %font-awesome-icon{':icon':"['fas', 'plus']"}
    %a.zoom.zoom-in{'v-on:click.stop.prevent':'client_state.interface.mini_map_zoom_out()'}
      %font-awesome-icon{':icon':"['fas', 'minus']"}
</template>

<script lang='coffee'>
import interact from 'interactjs'
import moment from 'moment'

MIN_MINI_MAP_WIDTH = 300
MIN_MINI_MAP_HEIGHT = 200

export default
  props:
    options: Object
    client_state: Object

  data: ->
    show_mini_map: @options?.option('general.show_mini_map')
    mini_map_width: @options?.option('mini_map.width')
    mini_map_height: @options?.option('mini_map.height')

  mounted: ->
    @client_state?.menu?.subscribe_menu_listener =>
      @show_mini_map = @options?.option('general.show_mini_map')

    @client_state?.interface?.subscribe_mini_map_size_listener =>
      @mini_map_width = @options?.option('mini_map.width')
      @mini_map_height = @options?.option('mini_map.height')

    element = @.$el.querySelector('#mini-map-container') if process.browser
    return unless element? && !element.dataset.interactSetup?

    interact(element)
      .resizable({
        edges: { left: true, right: false, bottom: false, top: true }
        inertia: true
        restrictSize: {
          min: {
            width: MIN_MINI_MAP_WIDTH
            height: MIN_MINI_MAP_HEIGHT
          }
        }
      })
      .on('resizemove', (event) =>
        @client_state.interface.update_mini_map(event.rect.width, event.rect.height)
      )
    element.dataset.interactSetup = true

  computed:
    mini_map_column_css_style: -> "width:#{@mini_map_width}px"
    mini_map_container_css_style: -> "width:#{@mini_map_width}px;height:#{@mini_map_height}px"
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.column-mini-map
  position: relative

  #mini-map-container
    background-color: #000
    bottom: 0
    min-height: 200px
    min-width: 300px
    padding: 6px
    position: absolute
    right: 0
    z-index: 1050

    #mini-map-webgl-container
      height: 100%
      width: 100%

    .zoom
      background-color: #000
      color: #FFF
      bottom: 5px
      padding: .25rem .75rem 0
      position: absolute

    .zoom-out
      left: 5px

    .zoom-in
      right: 5px

</style>
