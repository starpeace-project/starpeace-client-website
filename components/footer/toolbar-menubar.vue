<template lang='haml'>
%td.column-menu
  %a.button.is-starpeace.is-small.tooltip{'v-for':'option in menu_options', 'v-bind:class':"option.menu_class", 'v-on:click.stop.prevent':"toggle_menu(option)", 'v-bind:data-tooltip':'option.tooltip'}
    %font-awesome-icon{':icon':"[option.icon_category, option.icon_key]"}
</template>

<script lang='coffee'>
export default
  props:
    game_state: Object
    menu_state: Object
    ui_state: Object

  data: ->
    menu_options: [{
      type: 'planetary'
      tooltip: 'Planetary Systems'
      icon_category: 'fas'
      icon_key: 'globe'
      menu_class: ''
    }, {
      type: 'bookmarks'
      tooltip: 'Map Locations'
      icon_category: 'fas'
      icon_key: 'map-marker-alt'
      menu_class: ''
    }, {
      type: 'hide_all'
      tooltip: 'Hide Menus'
      icon_category: 'far'
      icon_key: 'eye'
      menu_class: ''
    }, {
      type: 'tycoon'
      tooltip: 'Tycoon Details'
      icon_category: 'fas'
      icon_key: 'user-tie'
      menu_class: ''
    }, {
      type: 'construction'
      tooltip: 'Construction'
      icon_category: 'fas'
      icon_key: 'toolbox'
      menu_class: ''
    }, {
      type: 'mail'
      tooltip: 'Mail'
      icon_category: 'far'
      icon_key: 'envelope'
      menu_class: ''
    }, {
      type: 'chat'
      tooltip: 'Chat'
      icon_category: 'far'
      icon_key: 'comments'
      menu_class: ''
    }, {
      type: 'options'
      tooltip: 'Options'
      icon_category: 'fas'
      icon_key: 'cogs'
      menu_class: ''
    }, {
      type: 'help'
      tooltip: 'Help'
      icon_category: 'far'
      icon_key: 'question-circle'
      menu_class: ''
    }]

  watch:
    menu_state_counter: (new_value, old_value) ->
      option.menu_class = (if @menu_state?.is_visible(option.type) then 'is-active' else '') for option in @menu_options

  computed:
    menu_state_counter: ->
      (@menu_state?.toolbar_left || '') + (@menu_state?.toolbar_body || '') + (@menu_state?.toolbar_right || '')

  methods:
    toggle_menu: (option) ->
      @menu_state.toggle_menu(option.type)
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
