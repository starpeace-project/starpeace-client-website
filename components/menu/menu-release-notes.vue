<template lang='pug'>
#notes-container(oncontextmenu='return false')
  .card.is-starpeace.has-header
    .card-header
      .card-header-title {{translate('ui.menu.release_notes.header')}}
      .card-header-icon.card-close(v-on:click.stop.prevent="client_state.menu.toggle_menu('release_notes')")
        font-awesome-icon(:icon="['fas', 'times']")
    .card-content.sp-menu-background.release-notes
      .card-description
        | {{translate('ui.menu.release_notes.info.prefix')}}
        |
        a(href='/release', target='_blank') {{translate('ui.menu.release_notes.info.link')}}
        |
        | {{translate('ui.menu.release_notes.info.suffix')}}
      span.notes-wrapper
        aside.notes-content.sp-scrollbar(v-html='release_notes_html')
</template>

<script lang='coffee'>
export default
  props:
    client_state: Object
    managers: Object

  data: ->
    release_notes_html: process.env.RELEASE_NOTES_HTML

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)
</script>

<style lang='sass' scoped>
#notes-container
  align-items: center
  display: flex
  grid-column-start: 2
  grid-column-end: 3
  grid-row-start: start-render
  grid-row-end: end-render
  justify-content: center
  overflow: hidden
  z-index: 1100

.card
  height: 95%
  max-width: 60rem
  width: 100%

.card-content
  height: calc(100% - 3.2rem)
  padding-right: 0
  overflow: hidden

  .card-description
    height: 2rem
    margin-bottom: 1rem

  .notes-wrapper
    display: inline-block
    height: calc(100% - 3rem)
    position: relative
    width: 100%

  .notes-content
    height: 100%
    overflow-x: hidden
    overflow-y: scroll
    padding-right: 1.25rem
    position: absolute
    width: 100%
</style>
