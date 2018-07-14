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
                %label.label.group-header General&nbsp;Options
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
                    %a{href:'#', 'v-show':"ui_state.show_header", 'v-on:click.stop.prevent':"ui_state.show_header = !ui_state.show_header"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                    %a{href:'#', 'v-show':"!ui_state.show_header", 'v-on:click.stop.prevent':"ui_state.show_header = !ui_state.show_header"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-off']"}
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label Show&nbsp;FPS:
            .column.is-paddingless.field-body
              .field.is-narrow
                .control
                  .toggle-icons
                    %a{href:'#', 'v-show':"ui_state.show_fps", 'v-on:click.stop.prevent':"ui_state.show_fps = !ui_state.show_fps"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                    %a{href:'#', 'v-show':"!ui_state.show_fps", 'v-on:click.stop.prevent':"ui_state.show_fps = !ui_state.show_fps"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-off']"}

        .column
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label.group-header Render&nbsp;Options
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
                    %a{href:'#', 'v-show':"ui_state.render_trees", 'v-on:click.stop.prevent':"ui_state.render_trees = !ui_state.render_trees"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                    %a{href:'#', 'v-show':"!ui_state.render_trees", 'v-on:click.stop.prevent':"ui_state.render_trees = !ui_state.render_trees"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-off']"}
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label Buildings:
            .column.is-paddingless.field-body
              .field.is-narrow
                .control
                  .toggle-icons
                    %a{href:'#', 'v-show':"ui_state.render_buildings", 'v-on:click.stop.prevent':"ui_state.render_buildings = !ui_state.render_buildings"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                    %a{href:'#', 'v-show':"!ui_state.render_buildings", 'v-on:click.stop.prevent':"ui_state.render_buildings = !ui_state.render_buildings"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-off']"}
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label Building&nbsp;Animations:
            .column.is-paddingless.field-body
              .field.is-narrow
                .control
                  .toggle-icons
                    %a{href:'#', 'v-show':"ui_state.render_building_animations", 'v-on:click.stop.prevent':"ui_state.render_building_animations = !ui_state.render_building_animations"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                    %a{href:'#', 'v-show':"!ui_state.render_building_animations", 'v-on:click.stop.prevent':"ui_state.render_building_animations = !ui_state.render_building_animations"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-off']"}
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label Building&nbsp;Effects:
            .column.is-paddingless.field-body
              .field.is-narrow
                .control
                  .toggle-icons
                    %a{href:'#', 'v-show':"ui_state.render_building_effects", 'v-on:click.stop.prevent':"ui_state.render_building_effects = !ui_state.render_building_effects"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                    %a{href:'#', 'v-show':"!ui_state.render_building_effects", 'v-on:click.stop.prevent':"ui_state.render_building_effects = !ui_state.render_building_effects"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-off']"}
          .field.is-horizontal
            .column.is-paddingless.is-9
              .field-label
                %label.label Planes:
            .column.is-paddingless.field-body
              .field.is-narrow
                .control
                  .toggle-icons
                    %a{href:'#', 'v-show':"ui_state.render_planes", 'v-on:click.stop.prevent':"ui_state.render_planes = !ui_state.render_planes"}
                      %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                    %a{href:'#', 'v-show':"!ui_state.render_planes", 'v-on:click.stop.prevent':"ui_state.render_planes = !ui_state.render_planes"}
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
    client: Object

  computed:
    menu_state: -> @client?.menu_state
    ui_state: -> @client?.ui_state

    can_reset: ->
      @ui_state.show_header != true || @ui_state.show_fps != true || @ui_state.render_trees != true || @ui_state.render_buildings != true ||
          @ui_state.render_building_animations != true || @ui_state.render_building_effects != true || @ui_state.render_planes != true
    is_dirty: ->
      @ui_state.saved_show_header != @ui_state.show_header || @ui_state.saved_show_fps != @ui_state.show_fps ||
          @ui_state.saved_render_trees != @ui_state.render_trees || @ui_state.saved_render_buildings != @ui_state.render_buildings ||
          @ui_state.saved_render_building_animations != @ui_state.render_building_animations || @ui_state.saved_render_building_effects != @ui_state.render_building_effects ||
          @ui_state.saved_render_planes != @ui_state.render_planes

  methods:
    reset_options: () ->
      @ui_state.reset_state()
    save_options: () ->
      @ui_state.save_state()
</script>

<style lang='sass' scoped>
.card
  max-width: 40rem
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
