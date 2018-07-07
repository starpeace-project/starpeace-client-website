<template lang='haml'>
.level-item
  .card.has-header
    .card-header
      .card-header-title
        Client Options
      .card-header-icon.card-close{'v-on:click.stop.prevent':'menu_state.toggle_menu_options()'}
        %font-awesome-icon{':icon':"['fas', 'times']"}

    .card-content
      %form
        .field.is-horizontal
          .column.is-paddingless.is-3
            .field-label
              %label.label Show&nbsp;Header:
          .field-body
            .field.is-narrow
              .control
                .toggle-icons
                  %a{href:'#', 'v-show':"ui_state.show_header", 'v-on:click.stop.prevent':'toggle_header()'}
                    %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                  %a{href:'#', 'v-show':"!ui_state.show_header", 'v-on:click.stop.prevent':'toggle_header()'}
                    %font-awesome-icon{':icon':"['fas', 'toggle-off']"}

        .field.is-horizontal
          .column.is-paddingless.is-3
            .field-label
              %label.label Show&nbsp;FPS:
          .field-body
            .field.is-narrow
              .control
                .toggle-icons
                  %a{href:'#', 'v-show':"ui_state.show_fps", 'v-on:click.stop.prevent':'toggle_fps()'}
                    %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
                  %a{href:'#', 'v-show':"!ui_state.show_fps", 'v-on:click.stop.prevent':'toggle_fps()'}
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
      @ui_state.show_header != true || @ui_state.show_fps != true
    is_dirty: ->
      @ui_state.saved_show_header != @ui_state.show_header || @ui_state.saved_show_fps != @ui_state.show_fps

  methods:
    toggle_header: () ->
      @ui_state.show_header = !@ui_state.show_header
    toggle_fps: () ->
      @ui_state.show_fps = !@ui_state.show_fps

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

  .label-column
    color: #fff
    font-weight: 1000

  .toggle-icons
    font-size: 1.5rem
    line-height: 1.5rem
    cursor: pointer

    .fa-toggle-on
      color: #fff
      font-weight: 1000

  .card-footer
    .card-footer-item
      a
        width: 100%

</style>
