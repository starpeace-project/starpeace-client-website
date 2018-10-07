<template lang='haml'>
#tycoon-container.card.has-header
  .card-header
    .card-header-title
      Tycoon Details
    .card-header-icon.card-close{'v-on:click.stop.prevent':"menu_state.toggle_menu('tycoon')"}
      %font-awesome-icon{':icon':"['fas', 'times']"}
  .card-content.sp-menu-background.overall-container
</template>

<script lang='coffee'>
import BookmarkItem from '~/components/menu/bookmarks/bookmark-item.vue'

export default
  components:
    'bookmark-item': BookmarkItem

  props:
    bookmark_manager: Object
    options: Object
    game_state: Object
    menu_state: Object

  watch:
    state_counter: (new_value, old_value) ->
      @sections = @bookmark_manager?.sections(@options) || []

  data: ->
    filter_input_value: ''

    sections: []

  computed:
    state_counter: -> @options.vue_state_counter + @bookmark_manager.vue_state_counter

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

#tycoon-container
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 2
  grid-row-end: 4
  margin: 0
  overflow: hidden
  z-index: 1100

.card
  height: 100%
  max-width: 25rem
  overflow: hidden
  position: absolute
  width: 100%

  .card-content
    height: calc(100% - 3.2rem)
    padding: 0

    &.overall-container
      padding-top: .5rem
      position: relative

</style>
