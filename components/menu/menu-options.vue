<template lang='haml'>
.level-item
  .card.has-header
    .card-header
      .card-header-title
        Client Options
      .card-header-icon.card-close{'v-on:click.stop.prevent':'menu_state.toggle_menu_options()'}
        %font-awesome-icon{':icon':"['fas', 'times']"}

    .card-content
      %form.columns
        .column
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label.group-header General
            .column.is-paddingless.second-group-header
              .field-label
                %label.label.group-header &nbsp;
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label Show&nbsp;Header:
            .column.is-paddingless.field-body
              .field.is-narrow
                .control
                  .toggle-icons
                    %a{href:'#', 'v-show':"options.option('general.show_header')", 'v-on:click.stop.prevent':"options.toggle('general.show_header')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                    %a{href:'#', 'v-show':"!options.option('general.show_header')", 'v-on:click.stop.prevent':"options.toggle('general.show_header')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-off']"}
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label Show&nbsp;FPS:
            .column.is-paddingless.field-body
              .field.is-narrow
                .control
                  .toggle-icons
                    %a{href:'#', 'v-show':"options.option('general.show_fps')", 'v-on:click.stop.prevent':"options.toggle('general.show_fps')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                    %a{href:'#', 'v-show':"!options.option('general.show_fps')", 'v-on:click.stop.prevent':"options.toggle('general.show_fps')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-off']"}
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label Mini&nbsp;Map:
            .column.is-paddingless.field-body
              .field.is-narrow
                .control
                  .toggle-icons
                    %a{href:'#', 'v-show':"options.option('general.show_mini_map')", 'v-on:click.stop.prevent':"options.toggle('general.show_mini_map')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                    %a{href:'#', 'v-show':"!options.option('general.show_mini_map')", 'v-on:click.stop.prevent':"options.toggle('general.show_mini_map')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-off']"}
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label Game&nbsp;Music:
            .column.is-paddingless.field-body
              .field.is-narrow
                .control
                  .toggle-icons
                    %a{href:'#', 'v-show':"options.option('music.show_game_music')", 'v-on:click.stop.prevent':"options.toggle('music.show_game_music')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                    %a{href:'#', 'v-show':"!options.option('music.show_game_music')", 'v-on:click.stop.prevent':"options.toggle('music.show_game_music')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-off']"}

        .column
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label.group-header Rendering
            .column.is-paddingless.second-group-header
              .field-label
                %label.label.group-header &nbsp;
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label Trees:
            .column.is-paddingless.field-body
              .field.is-narrow.has-text-centered
                .control
                  .toggle-icons
                    %a{href:'#', 'v-show':"options.option('renderer.trees')", 'v-on:click.stop.prevent':"options.toggle('renderer.trees')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                    %a{href:'#', 'v-show':"!options.option('renderer.trees')", 'v-on:click.stop.prevent':"options.toggle('renderer.trees')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-off']"}
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label Buildings:
            .column.is-paddingless.field-body
              .field.is-narrow
                .control
                  .toggle-icons
                    %a{href:'#', 'v-show':"options.option('renderer.buildings')", 'v-on:click.stop.prevent':"options.toggle('renderer.buildings')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                    %a{href:'#', 'v-show':"!options.option('renderer.buildings')", 'v-on:click.stop.prevent':"options.toggle('renderer.buildings')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-off']"}
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label Building&nbsp;Animations:
            .column.is-paddingless.field-body
              .field.is-narrow
                .control
                  .toggle-icons
                    %a{href:'#', 'v-show':"options.option('renderer.building_animations')", 'v-on:click.stop.prevent':"options.toggle('renderer.building_animations')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                    %a{href:'#', 'v-show':"!options.option('renderer.building_animations')", 'v-on:click.stop.prevent':"options.toggle('renderer.building_animations')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-off']"}
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label Building&nbsp;Effects:
            .column.is-paddingless.field-body
              .field.is-narrow
                .control
                  .toggle-icons
                    %a{href:'#', 'v-show':"options.option('renderer.building_effects')", 'v-on:click.stop.prevent':"options.toggle('renderer.building_effects')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                    %a{href:'#', 'v-show':"!options.option('renderer.building_effects')", 'v-on:click.stop.prevent':"options.toggle('renderer.building_effects')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-off']"}
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label Planes:
            .column.is-paddingless.field-body
              .field.is-narrow
                .control
                  .toggle-icons
                    %a{href:'#', 'v-show':"options.option('renderer.planes')", 'v-on:click.stop.prevent':"options.toggle('renderer.planes')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                    %a{href:'#', 'v-show':"!options.option('renderer.planes')", 'v-on:click.stop.prevent':"options.toggle('renderer.planes')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-off']"}

        .column
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label.group-header Map&nbsp;Locations
            .column.is-paddingless.second-group-header
              .field-label
                %label.label.group-header &nbsp;
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label Points of Interest:
            .column.is-paddingless.field-body
              .field.is-narrow.has-text-centered
                .control
                  .toggle-icons
                    %a{href:'#', 'v-show':"options.option('bookmarks.points_of_interest')", 'v-on:click.stop.prevent':"options.toggle('bookmarks.points_of_interest')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                    %a{href:'#', 'v-show':"!options.option('bookmarks.points_of_interest')", 'v-on:click.stop.prevent':"options.toggle('bookmarks.points_of_interest')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-off']"}
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label POI - Towns:
            .column.is-paddingless.field-body
              .field.is-narrow.has-text-centered
                .control
                  .toggle-icons
                    %a{href:'#', 'v-show':"options.option('bookmarks.towns')", 'v-on:click.stop.prevent':"options.toggle('bookmarks.towns')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                    %a{href:'#', 'v-show':"!options.option('bookmarks.towns')", 'v-on:click.stop.prevent':"options.toggle('bookmarks.towns')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-off']"}
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label POI - Mausoleums:
            .column.is-paddingless.field-body
              .field.is-narrow.has-text-centered
                .control
                  .toggle-icons
                    %a{href:'#', 'v-show':"options.option('bookmarks.mausoleums')", 'v-on:click.stop.prevent':"options.toggle('bookmarks.mausoleums')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                    %a{href:'#', 'v-show':"!options.option('bookmarks.mausoleums')", 'v-on:click.stop.prevent':"options.toggle('bookmarks.mausoleums')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-off']"}
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label Corporation:
            .column.is-paddingless.field-body
              .field.is-narrow.has-text-centered
                .control
                  .toggle-icons
                    %a{href:'#', 'v-show':"options.option('bookmarks.corporation')", 'v-on:click.stop.prevent':"options.toggle('bookmarks.corporation')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                    %a{href:'#', 'v-show':"!options.option('bookmarks.corporation')", 'v-on:click.stop.prevent':"options.toggle('bookmarks.corporation')"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-off']"}

    %footer.card-footer
      .card-footer-item.reset-item
        %a.button.is-primary.is-medium.is-outlined{'v-on:click.stop.prevent':'reset_options()', href: '#', ':disabled':'!can_reset'} Reset
      .card-footer-item.save-item
        %a.button.is-primary.is-medium{href:'#', 'v-on:click.stop.prevent':'save_options()', href: '#', ':disabled':'!is_dirty'} Save

</template>

<script lang='coffee'>
export default
  props:
    options: Object
    menu_state: Object
    ui_state: Object

  data: ->
    can_reset: @options?.can_reset()
    is_dirty: @options?.is_dirty()

  watch:
    state_counter: (new_value, old_value) ->
      @can_reset = @options?.can_reset()
      @is_dirty = @options?.is_dirty()

  computed:
    state_counter: -> @options.vue_state_counter

  methods:
    reset_options: () -> @options.reset_state()
    save_options: () -> @options.save_state()
</script>

<style lang='sass' scoped>
.card
  max-width: 60rem
  width: 100%
  z-index: 1050

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
