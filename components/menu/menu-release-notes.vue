<template lang='haml'>
#notes-container
  .card.is-starpeace.has-header
    .card-header
      .card-header-title
        Release Notes
      .card-header-icon.card-close{'v-on:click.stop.prevent':"client_state.menu.toggle_menu('release_notes')"}
        %font-awesome-icon{':icon':"['fas', 'times']"}
    .card-content.sp-menu-background.release-notes
      .card-description
        Visit the
        %a{href:'/release', target:'_blank'} release notes archive
        &nbsp;to view additional notes and historical changelog.
      %span.notes-wrapper
        %aside.notes-content.sp-scrollbar{'v-html':'release_notes_html'}
</template>

<script lang='coffee'>
export default
  props:
    client_state: Object

  data: ->
    release_notes_html: process.env.RELEASE_NOTES_HTML
</script>

<style lang='sass' scoped>
#notes-container
  align-items: center
  display: flex
  grid-column-start: 2
  grid-column-end: 3
  grid-row-start: 2
  grid-row-end: 4
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
