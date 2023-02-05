<template lang='pug'>
client-only
  #application-container(v-cloak=true)
    sp-header(:translation_manager='translation_manager', :options='options')

    #application-body
      .columns
        .column.is-8.is-offset-2
          .card.is-starpeace.notes-container
            .card-header
              .card-header-title Release Notes - Latest
            .card-content.release-notes(v-html='release_notes_latest_html')
          .card.is-starpeace.notes-container
            .card-header
              .card-header-title Release Notes - Archive
            .card-content.release-notes(v-html='release_notes_archive_html')
    sp-footer
</template>

<script lang='coffee'>
import Header from '~/components/page-layout/header.vue'
import Footer from '~/components/page-layout/footer.vue'

import Options from '~/plugins/starpeace-client/state/options.coffee'
import TranslationManager from '~/plugins/starpeace-client/language/translation-manager.coffee'

if process.client
  options = new Options()
  translation_manager = new TranslationManager(null, null, options)

definePageMeta({
  layout: 'release'
})

export default
  components:
    'sp-header': Header
    'sp-footer': Footer

  data: ->
    translation_manager: translation_manager
    options: options

    release_notes_latest_html: @$config.public.RELEASE_NOTES_HTML
    release_notes_archive_html: @$config.public.RELEASE_NOTES_ARCHIVE_HTML
</script>

<style lang='sass' scoped>
@import 'bulma/sass/utilities/_all'

.notes-container
  margin-top: 1rem

#application-body
  +mobile
    overflow-x: hidden
</style>
