<template lang='pug'>
.toolbar-menu
  a.button.is-starpeace.is-small.tooltip(:class="is_menu_visible('galaxy') ? 'is-active' : ''", v-on:click.stop.prevent="toggle_menu('galaxy')", :data-tooltip="translate('ui.menu.galaxy.header')")
    font-awesome-icon(:icon="['fas', 'satellite']")
  a.button.is-starpeace.is-small.tooltip(:class="is_menu_visible('bookmarks') ? 'is-active' : ''", v-on:click.stop.prevent="toggle_menu('bookmarks')", :data-tooltip="translate('ui.menu.bookmarks.header')")
    font-awesome-icon(:icon="['fas', 'map-marker-alt']")
  a.button.is-starpeace.is-small.tooltip(:class="is_menu_visible('tycoon') ? 'is-active' : ''", v-on:click.stop.prevent="toggle_menu('tycoon')", :data-tooltip="translate('ui.menu.tycoon_details.header')")
    font-awesome-icon(:icon="['fas', 'user-tie']")
  a.button.is-starpeace.is-small.tooltip(:class="is_menu_visible('politics') ? 'is-active' : ''", v-on:click.stop.prevent="toggle_menu('politics')", :data-tooltip="translate('ui.menu.politics.header')")
    font-awesome-icon(:icon="['fas', 'landmark']")
  a.button.is-starpeace.is-small.tooltip(:class="is_menu_visible('rankings') ? 'is-active' : ''", v-on:click.stop.prevent="toggle_menu('rankings')", :data-tooltip="translate('ui.menu.rankings.header')")
    font-awesome-icon(:icon="['fas', 'medal']")
  a.button.is-starpeace.is-small.tooltip(:class="is_menu_visible('hide_all') ? 'is-active' : ''", v-on:click.stop.prevent="toggle_menu('hide_all')", :data-tooltip="translate('misc.hide_menus.label')")
    font-awesome-icon(:icon="['far', 'eye']")
  a.button.is-starpeace.is-small.tooltip(:class="is_menu_visible('town_search') ? 'is-active' : ''", v-on:click.stop.prevent="toggle_menu('town_search')", :data-tooltip="translate('ui.menu.town_search.header')")
    font-awesome-icon(:icon="['fas', 'search-location']")
  a.button.is-starpeace.is-small.tooltip(:class="is_menu_visible('tycoon_search') ? 'is-active' : ''", v-on:click.stop.prevent="toggle_menu('tycoon_search')", :data-tooltip="translate('ui.menu.tycoon_search.header')")
    font-awesome-icon(:icon="['fas', 'search']")
  a.button.is-starpeace.is-small.tooltip(:class="is_menu_visible('research') ? 'is-active' : ''", v-on:click.stop.prevent="toggle_menu('research')", :data-tooltip="translate('ui.menu.research.header')")
    font-awesome-icon(:icon="['fas', 'flask']")
  a.button.is-starpeace.is-small.tooltip(:class="is_menu_visible('construction') ? 'is-active' : ''", v-on:click.stop.prevent="toggle_menu('construction')", :data-tooltip="translate('ui.menu.construction.header')")
    font-awesome-icon(:icon="['fas', 'hammer']")
  a.button.is-starpeace.is-small.tooltip(:class="is_menu_visible('mail') ? 'is-active' : ''", v-on:click.stop.prevent="toggle_menu('mail')", :data-tooltip="translate('ui.menu.mail.header')")
    font-awesome-icon(:icon="['far', 'envelope']")
  a.button.is-starpeace.is-small.tooltip(:class="is_menu_visible('chat') ? 'is-active' : ''", v-on:click.stop.prevent="toggle_menu('chat')", :data-tooltip="translate('ui.menu.chat.header')")
    font-awesome-icon(:icon="['far', 'comments']")
  a.button.is-starpeace.is-small.tooltip(:class="is_menu_visible('options') ? 'is-active' : ''", v-on:click.stop.prevent="toggle_menu('options')", :data-tooltip="translate('ui.menu.options.header')")
    font-awesome-icon(:icon="['fas', 'cogs']")
  a.button.is-starpeace.is-small.tooltip(:class="is_menu_visible('help') ? 'is-active' : ''", v-on:click.stop.prevent="toggle_menu('help')", :data-tooltip="translate('ui.menu.help.header')")
    font-awesome-icon(:icon="['far', 'question-circle']")

</template>

<script lang='coffee'>
export default
  props:
    client_state: Object
    managers: Object

  #mounted: ->
    #@client_state?.menu?.subscribe_menu_listener => @$forceUpdate()

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    is_menu_visible: (option_type) -> @client_state.menu.is_visible(option_type)

    toggle_menu: (option_type) -> @client_state.menu.toggle_menu(option_type)
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


.toolbar-menu
  background: linear-gradient(to top, darken($sp-primary-bg, 5%), #06261D)
  display: inline-block
  padding: .25rem
  text-align: center
  width: 46rem

  .button
    height: 2.5rem
    font-size: 1.25rem
    padding: 0 .65rem

    &:first-child
      &.tooltip
        &.is-tooltip-active::before,
        &:focus::before,
        &:hover::before
          -webkit-transform: translate(-25%, -0.5rem)
          transform: translate(-25%, -0.5rem)

    &:not(:first-child)
      margin-left: .5rem
</style>
