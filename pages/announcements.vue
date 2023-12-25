<template lang='pug'>
client-only
  #application-container
    #application-body
      .columns

        .column.is-offset-3.is-6
          .card.is-starpeace.mb-6
            .card-content.is-flex.is-flex-direction-column.is-align-items-center.logo-section
              .title-logo
                h1 STAR
                img.starpeace-logo
                h1.ml-2 PEACE

            .card-content
              template(v-if="newsId == 'NW_TEST'")
                announcements-2023-12-18-nw-test

              template(v-else)
                | None

    page-layout-footer
</template>

<script lang='ts'>
import _ from 'lodash';

definePageMeta({
  layout: 'release'
})

export default {
  data () {
    return {
      newsId: 'NW_TEST'
    };
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace'
@import '~/assets/stylesheets/starpeace-variables'

.logo-section
  background: unset !important
  background-color: $sp-dark-bg !important

.title-logo
  color: #FFF
  line-height: 3rem

  .starpeace-logo
    filter: brightness(0) saturate(100%) invert(100%) sepia(1%) saturate(7498%) hue-rotate(205deg) brightness(105%) contrast(100%)
    background-size: 2.75rem
    display: inline-block
    height: 2.75rem
    margin: 0 0 .5rem
    width: 2.75rem
    vertical-align: middle

  h1
    display: inline-block
    font-size: 3.25rem
    line-height: 3rem
    margin: .25rem .25rem .5rem
    vertical-align: middle


#nw-test-img
  width: 30rem

</style>
