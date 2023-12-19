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

            .card-content.has-text-white
              div.is-size-6 FOR IMMEDIATE RELEASE
              div.is-size-6 Dec. 18, 2066

              template(v-if="newsId == 'NW_TEST'")
                div.mt-4
                  .is-flex.is-flex-direction-row.is-justify-content-center
                    span.is-size-3.has-text-weight-bold.is-capitalized Dr. Blomke discovers hidden v-numbers, unlocks portal travel to new universe!

                  p.is-size-5.mt-2
                    span.is-uppercase Antananarivo,
                    span.ml-1 Madagascar
                    span.mx-1 -
                    span The International Foundation for Extraterrestrial Life is excited to announce a major breakthrough from Dr. Markus Blomke: "More than 23 years after original portal rights were restored to me, I've discovered the proof was incomplete: v-numbers have hidden cardinality!"

                    p.is-size-5.mt-2
                    | "This has profound implications and unlocks our ability to license travel to new planets - including planets in galaxies not within our Universe."

                  p.is-size-5.mt-2
                    | "And these planets are not normal," exclaims Dr. Blomke, "Citizens do not consume, factories do not produce, and rooms remain empty, yet wages are demanded. We continue to search for answers, but meanwhile, we must not impede opportunity; I've instructed the IFEL to begin at once the issuing of Seal visas!"

                  .content.is-flex.is-flex-direction-row.mt-4
                    img#nw-test-img(src='~/assets/images/announcements/nw-test.png')

                    div.ml-5
                      p.is-size-5
                        | The International Foundation for Extraterrestrial Life can confirm these peculiar planets and remains committed to ongoing research and development, until order is established and economies are normalized.

                      .is-flex.is-flex-direction-row
                        div
                          span Works:
                          ul
                            li Tycoon, Corporation, and Company creation
                            li Research management
                            li Building construction and upgrades
                            li Building inspect menu and tab most settings
                            li Bookmarks (partial)
                            li Search menus (partial)
                            li Basic simulation and economics loop

                        div.ml-3
                          span Doesn't Work:
                          ul
                            li Majority of simulation and planet economy
                            li Research or construction refunds
                            li Level promotions
                            li Construction rules (roads, water)
                            li No roads, overlaps, or zoning
                            li Various buildings missing
                            li Tycoon menu
                            li Building connection management
                            li Lots of other things

                      p.is-size-6.is-italic.mt-4
                        | The Foundation of Alien Rights and Trade refused a request for comment, replying instead with a dollar-sign emoji.

                  p.is-size-5.mt-2
                    span Feel free to jump in now and please report any problems, suggestions, or feedback in Discord; volunteers always welcome across translations, game design, UI design, programming, artwork, and testing!

                  p.is-size-4.mt-3
                    span.has-text-weight-bold Join on 12/31 at 4pm GMT / 11am EST / 8am PST for a coordinated stress test and to help us find server connection limits


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
