<template lang='haml'>
.level-item
  .card.has-header
    .card-header
      .card-header-title
        Release Notes
      .card-header-icon.card-close{'v-on:click.stop.prevent':'menu_state.toggle_menu_release_notes()'}
        %font-awesome-icon{':icon':"['fas', 'times']"}

    .card-content.release-notes
      .card-description
        Visit the
        %a{href:'/release', target:'_blank'} release notes archive
        &nbsp;to view additional notes and historical changelog.
      .note-body{'v-html':'release_notes_html'}
</template>

<script lang='coffee'>
export default
  props:
    client: Object

  data: ->
    release_notes_html: process.env.RELEASE_NOTES_HTML

  computed:
    menu_state: -> @client?.menu_state
</script>

<style lang='sass' scoped>
.level-item
  height: 95%

.card
  height: 100%
  max-width: 60rem
  width: 100%
  z-index: 1050

.card-content
  height: calc(100% - 3.5rem)
  overflow-y: scroll

  &::-webkit-scrollbar
      width: 10px

  &::-webkit-scrollbar-track
      background: #2a453f

  &::-webkit-scrollbar-thumb
      background: #395950

  &::-webkit-scrollbar-thumb:hover
      background: #6ea192

  .card-description
    margin-bottom: 1rem
</style>
