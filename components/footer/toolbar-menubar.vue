<template lang='haml'>
%td.column-menu
  %a.button.is-starpeace.is-small.tooltip{'v-bind:class':'menu_class_planetary', 'v-on:click.stop.prevent':'menu_state.toggle_menu_planetary()', 'data-tooltip':'Planetary Systems'}
    %font-awesome-icon{':icon':"['fas', 'globe']"}
  %a.button.is-starpeace.is-small.tooltip{'v-bind:class':'menu_class_bookmarks', 'v-on:click.stop.prevent':'menu_state.toggle_menu_bookmarks()', 'data-tooltip':'Map Locations'}
    %font-awesome-icon{':icon':"['fas', 'map-marker-alt']"}
  %a.button.is-starpeace.is-small.tooltip{'v-on:click.stop.prevent':'menu_state.hide_all_menus()', 'data-tooltip':'Hide Menus'}
    %font-awesome-icon{':icon':"['far', 'eye']"}
  %a.button.is-starpeace.is-small.tooltip{'v-bind:class':'menu_class_tycoon', 'v-on:click.stop.prevent':'menu_state.toggle_menu_tycoon()', 'data-tooltip':'Tycoon Details'}
    %font-awesome-icon{':icon':"['fas', 'user-tie']"}
  %a.button.is-starpeace.is-small.tooltip{'v-bind:class':'menu_class_building', 'v-on:click.stop.prevent':'menu_state.toggle_menu_building()', 'data-tooltip':'Construction'}
    %font-awesome-icon{':icon':"['fas', 'toolbox']"}
  %a.button.is-starpeace.is-small.tooltip{'v-bind:class':'menu_class_mail', 'v-on:click.stop.prevent':'menu_state.toggle_menu_mail()', 'data-tooltip':'Mail'}
    %font-awesome-icon{':icon':"['far', 'envelope']"}
  %a.button.is-starpeace.is-small.tooltip{'v-bind:class':'menu_class_chat', 'v-on:click.stop.prevent':'menu_state.toggle_menu_chat()', 'data-tooltip':'Chat'}
    %font-awesome-icon{':icon':"['far', 'comments']"}
  %a.button.is-starpeace.is-small.tooltip{'v-bind:class':'menu_class_options', 'v-on:click.stop.prevent':'menu_state.toggle_menu_options()', 'data-tooltip':'Options'}
    %font-awesome-icon{':icon':"['fas', 'cogs']"}
  %a.button.is-starpeace.is-small.tooltip{'v-bind:class':'menu_class_help', 'v-on:click.stop.prevent':'menu_state.toggle_menu_help()', 'data-tooltip':'Help'}
    %font-awesome-icon{':icon':"['far', 'question-circle']"}
</template>

<script lang='coffee'>
export default
  props:
    game_state: Object
    menu_state: Object
    ui_state: Object

  computed:
    menu_class_overlay: -> { 'is-active': @ui_state?.show_overlay || false }
    menu_class_zones: -> { 'is-active': @ui_state?.show_zones || false }
    menu_class_planetary: -> { 'is-active': @menu_state?.main_menu == 'planetary' }
    menu_class_bookmarks: -> { 'is-active': @menu_state?.show_menu_bookmarks || false }
    menu_class_tycoon: -> { 'is-active': @menu_state?.main_menu == 'tycoon' }
    menu_class_building: -> { 'is-active': @menu_state?.main_menu == 'building' }
    menu_class_mail: -> { 'is-active': @menu_state?.main_menu == 'mail' }
    menu_class_chat: -> { 'is-active': @menu_state?.main_menu == 'chat' }
    menu_class_options: -> { 'is-active': @menu_state?.main_menu == 'options' }
    menu_class_help: -> { 'is-active': @menu_state?.main_menu == 'help' }
    menu_class_release_notes: -> { 'is-active': @menu_state?.show_menu_release_notes || false }
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.button
  &.is-starpeace
    &.is-small
      border-radius: .2rem
      height: 2.5rem
      font-size: 1.25rem
      line-height: 1.5
      padding: 0 .65rem

td
  border-top: 0

  &.column-menu
    background: linear-gradient(to top, #395950, #000)
    max-width: 32rem
    padding: .25rem
    text-align: center
    width: 32rem

    .button
      height: 2.5rem
      font-size: 1.25rem
      padding: 0 .65rem

      &:not(:first-child)
        margin-left: .5rem
</style>
