<template lang='haml'>
%no-ssr
  #application-container{'v-cloak':true}
    %sp-header
    #application-body
      .columns
        .column.is-8.is-offset-2
          .card.notes-container
            .card-header
              .card-header-title Release Notes - Latest
            .card-content.release-notes{'v-html':'release_notes_latest_html'}
          .card.notes-container
            .card-header
              .card-header-title Release Notes - Archive
            .card-content.release-notes{'v-html':'release_notes_archive_html'}
    %sp-footer
</template>

<script lang='coffee'>
import Header from '~/components/header/header-panel.vue'
import Footer from '~/components/footer/footer-panel.vue'

export default
  components:
    'sp-header': Header
    'sp-footer': Footer

  data: ->
    release_notes_latest_html: process.env.RELEASE_NOTES_HTML
    release_notes_archive_html: process.env.RELEASE_NOTES_ARCHIVE_HTML
</script>

<style lang='sass' scoped>
@import '~bulma/sass/utilities/_all'

.notes-container
  margin-top: 1rem

#application-body
  +mobile
    overflow-x: hidden
</style>
