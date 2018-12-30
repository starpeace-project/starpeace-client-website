<template lang='haml'>
#options-container
  .card.is-starpeace.has-header
    .card-header
      .card-header-title
        Client Options
      .card-header-icon.card-close{'v-on:click.stop.prevent':"client_state.menu.toggle_menu('options')"}
        %font-awesome-icon{':icon':"['fas', 'times']"}
    .card-content.sp-menu-background
      %form.columns
        .column
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label.group-header General
            .column.is-paddingless.second-group-header
              .field-label
                %label.label.group-header &nbsp;
          %menu-option{'label':'Show Header', ':value':"options.option('general.show_header')", 'v-on:toggle':"options.toggle('general.show_header')"}
          %menu-option{'label':'Show FPS', ':value':"options.option('general.show_fps')", 'v-on:toggle':"options.toggle('general.show_fps')"}
          %menu-option{'label':'Mini Map', ':value':"options.option('general.show_mini_map')", 'v-on:toggle':"options.toggle('general.show_mini_map')"}
          %menu-option{'label':'Game Music', ':value':"options.option('music.show_game_music')", 'v-on:toggle':"options.toggle('music.show_game_music')"}
        .column
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label.group-header Rendering
            .column.is-paddingless.second-group-header
              .field-label
                %label.label.group-header &nbsp;
          %menu-option{'label':'Trees', ':value':"options.option('renderer.trees')", 'v-on:toggle':"options.toggle('renderer.trees')"}
          %menu-option{'label':'Buildings', ':value':"options.option('renderer.buildings')", 'v-on:toggle':"options.toggle('renderer.buildings')"}
          %menu-option{'label':'Building Animations', ':value':"options.option('renderer.building_animations')", 'v-on:toggle':"options.toggle('renderer.building_animations')"}
          %menu-option{'label':'Building Effects', ':value':"options.option('renderer.building_effects')", 'v-on:toggle':"options.toggle('renderer.building_effects')"}
          %menu-option{'label':'Planes', ':value':"options.option('renderer.planes')", 'v-on:toggle':"options.toggle('renderer.planes')"}
        .column
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label.group-header Map&nbsp;Locations
            .column.is-paddingless.second-group-header
              .field-label
                %label.label.group-header &nbsp;
          %menu-option{'label':'Points of Interest', ':value':"options.option('bookmarks.points_of_interest')", 'v-on:toggle':"options.toggle('bookmarks.points_of_interest')"}
          %menu-option{'label':'POI - Capital', ':value':"options.option('bookmarks.capital')", 'v-on:toggle':"options.toggle('bookmarks.capital')"}
          %menu-option{'label':'POI - Towns', ':value':"options.option('bookmarks.towns')", 'v-on:toggle':"options.toggle('bookmarks.towns')"}
          %menu-option{'label':'POI - Mausoleums', ':value':"options.option('bookmarks.mausoleums')", 'v-on:toggle':"options.toggle('bookmarks.mausoleums')"}
          %menu-option{'label':'Corporation', ':value':"options.option('bookmarks.corporation')", 'v-on:toggle':"options.toggle('bookmarks.corporation')"}
    %footer.card-footer
      .card-footer-item.reset-item
        %a.button.is-primary.is-medium.is-outlined{'v-on:click.stop.prevent':'reset_options()', href: '#', ':disabled':'!can_reset'} Reset
      .card-footer-item.save-item
        %a.button.is-primary.is-medium{href:'#', 'v-on:click.stop.prevent':'save_options()', href: '#', ':disabled':'!is_dirty'} Save
</template>

<script lang='coffee'>
import MenuOption from '~/components/menu/options/menu-option.vue'

export default
  components:
    'menu-option': MenuOption

  props:
    client_state: Object

  data: ->
    can_reset: @options?.can_reset()
    is_dirty: @options?.is_dirty()

  computed:
    options: -> @client_state?.options

  mounted: ->
    @client_state.options.subscribe_options_listener =>
      @can_reset = @options?.can_reset()
      @is_dirty = @options?.is_dirty()
      @$forceUpdate()

  methods:
    reset_options: () -> @options.reset_state()
    save_options: () -> @options.save_state()
</script>

<style lang='sass' scoped>

#options-container
  align-items: center
  display: flex
  grid-column-start: 2
  grid-column-end: 3
  grid-row-start: 2
  grid-row-end: 4
  justify-content: center
  z-index: 1100

.card
  max-width: 60rem
  width: 100%

  legend
    color: #fff
    font-weight: 1000

  .label
    &.group-header
      border-bottom: 1px solid
      font-weight: 1000
      padding-bottom: .25rem

  .second-group-header
    .field-label
      margin: 0

  .label-column
    color: #fff
    font-weight: 1000

  .toggle-icons
    font-size: 1.5rem
    line-height: 1.5rem
    cursor: pointer
    text-align: center

    .fa-toggle-on
      color: #fff
      font-weight: 1000

  .card-footer
    .card-footer-item
      a
        width: 100%

</style>
