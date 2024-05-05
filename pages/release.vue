<template lang='pug'>
client-only
  #application-container(v-cloak=true)
    page-layout-header(:client-state='client_state')

    #application-body
      .columns
        .column.is-8.is-offset-2
          .card.is-starpeace.mt-4
            .card-header
              .card-header-title Release Notes - Latest
            .card-content.release-notes(v-html='release_notes_latest_html')
          .card.is-starpeace.mt-4
            .card-header
              .card-header-title Release Notes - Archive
            .card-content.release-notes(v-html='release_notes_archive_html')

    page-layout-footer
</template>

<script>
definePageMeta({
  layout: 'release'
})

export default {
  data () {
    return {
      client_state: this.$starpeaceClient?.client_state,
      release_notes_latest_html: this.$config.public.RELEASE_NOTES_HTML,
      release_notes_archive_html: this.$config.public.RELEASE_NOTES_ARCHIVE_HTML
    };
  }
}
</script>

<style lang='sass' scoped>
@import 'bulma/sass/utilities/mixins'

#application-body
  +mobile
    overflow-x: hidden
</style>
