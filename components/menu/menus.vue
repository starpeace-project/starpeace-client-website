<template lang='haml'>
%no-ssr
  #menu-container.level{'v-show':'can_render', 'v-cloak':true}

    %menu-building{'v-show':"main_menu == 'building'", 'v-bind:client':'client'}
    %menu-chat{'v-show':"main_menu == 'chat'", 'v-bind:client':'client'}
    %menu-favorites{'v-show':"show_menu_favorites", 'v-bind:client':'client'}
    %menu-mail{'v-show':"main_menu == 'mail'", 'v-bind:client':'client'}
    %menu-options{'v-show':"main_menu == 'options'", 'v-bind:client':'client'}
    %menu-help{'v-show':"main_menu == 'help'", 'v-bind:client':'client'}

    %menu-release-notes{'v-show':"show_menu_release_notes", 'v-bind:client':'client'}

</template>

<script lang='coffee'>
import MenuBuilding from '~/components/menu/menu-building.vue'
import MenuChat from '~/components/menu/menu-chat.vue'
import MenuFavorites from '~/components/menu/menu-favorites.vue'
import MenuMail from '~/components/menu/menu-mail.vue'
import MenuOptions from '~/components/menu/menu-options.vue'
import MenuHelp from '~/components/menu/menu-help.vue'
import MenuReleaseNotes from '~/components/menu/menu-release-notes.vue'

export default
  components:
    'menu-building': MenuBuilding
    'menu-chat': MenuChat
    'menu-favorites': MenuFavorites
    'menu-mail': MenuMail
    'menu-options': MenuOptions
    'menu-help': MenuHelp
    'menu-release-notes': MenuReleaseNotes

  props:
    client: Object

  computed:
    menu_state: -> @client?.menu_state
    game_state: -> @client?.game_state

    can_render: -> @game_state?.initialized || false
    main_menu: -> @menu_state?.main_menu
    show_menu_favorites: -> @menu_state?.show_menu_favorites || false
    show_menu_release_notes: -> @menu_state?.show_menu_release_notes || false

</script>

<style lang='sass' scoped>
#menu-container
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 2
  grid-row-end: 4
  margin: 0
  position: relative
  overflow: hidden

.no-header
  #menu-container
    grid-row-start: 1

</style>
