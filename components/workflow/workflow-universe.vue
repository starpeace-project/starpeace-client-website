<template lang='pug'>
.identity-content
  .welcome-message
    span.salut {{$translate('ui.workflow.visa-type.greeting')}}, {{$translate('identity.visitor')}}!
    |
    |
    | {{$translate('ui.workflow.visa-type.intro')}}
    |
    |
    a(href='https://docs.starpeace.io') {{$translate('ui.workflow.visa-type.learnmore')}}

  .columns.universe-mode
    .column.is-6
      a.button.is-medium.is-fullwidth.is-starpeace.is-square(
        :class="{'is-active': universe_mode == 'starpeace'}"
        @click.stop.prevent="select_universe('starpeace')"
      ) STARPEACE {{$translate('ui.workflow.universe.universe.label')}}
    .column.is-6
      a.button.is-medium.is-fullwidth.is-starpeace.is-square(
        :class="{'is-active': universe_mode == 'multiverse'}"
        @click.stop.prevent="select_universe('multiverse')"
      ) {{$translate('ui.workflow.universe.multiverse.label')}}

  workflow-universe-starpeace(v-show="universe_mode == 'starpeace'" :client_state='client_state')
  workflow-universe-multiverse(v-show="universe_mode == 'multiverse'" :ajax_state='ajax_state' :client_state='client_state')

  .news-container
    .news-header
      span {{$translate('ui.workflow.visa-type.header.news')}}
      a.version(href='/release') {{client_version}}

    template(v-if='!news.length')
      .news-loading
        img.starpeace-logo.logo-loading

    template(v-else-if='news.length')
      .news-content.sp-scrollbar
        .news-item(v-for='news_item in news')
          .news-date {{news_item.date}}
          .news-title {{news_item.title}}
          .news-body.content
            span.details(v-html='news_item_html(news_item.body)')
            ul(v-if='news_item.items && news_item.items.length')
              li(v-for='item in news_item.items') {{item}}

</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state';

export default {
  props: {
    client_state: { type: ClientState, required: true },
    ajax_state: { type: Object, required: true }
  },

  data () {
    return {
      client_version: this.$config.public.CLIENT_VERSION,
      news: [],
      universe_mode: 'multiverse'
    }
  },

  created () {
    const request = new XMLHttpRequest()
    request.open('GET', '/news.json', true)
    request.onload = () => {
      if (request.status >= 200 && request.status < 400) {
        this.news = [JSON.parse(request.responseText).news[0]]
      }
    };
    request.send();
  },

  methods: {
    select_universe (mode: string): void { this.universe_mode = mode; },

    news_item_html (value: string): string { return value.replace(/\n/g, '<br>'); }
  }
}
</script>

<style lang='sass' scoped>
@import 'bulma/sass/utilities/_all'
@import '~/assets/stylesheets/starpeace-variables'

.identity-content
  height: 100%
  position: relative
  overflow: hidden

.welcome-message
  border-bottom: 1px solid $sp-primary
  color: #fff
  font-size: 1.5rem
  min-height: 6rem
  padding: 0 .5rem 1.5rem
  margin-bottom: 0

  .salut
    font-weight: bold

  a
    color: #fff
    font-size: 1.25rem

.universe-mode
  border-bottom: 1px solid $sp-primary
  margin: 0

  > .column
    padding: 0


.universe-starpeace-actions
  height: 22rem
  margin: 0

  .column
    padding-bottom: 2rem
    padding-top: 1.5rem
    text-align: center

    &:first-child
      +mobile
        border-bottom: 1px solid $sp-primary
        padding-bottom: 2rem

      +tablet
        border-right: 1px solid $sp-primary

    &.tycoon-column
      padding-left: 1.5rem

    h3
      color: #fff
      font-size: 1.75rem
      font-weight: 1000
      letter-spacing: .25rem

    .tycoon-icon
      color: #fff
      font-size: 4rem
      margin: .5rem 0 1rem

    ul
      display: inline-block
      font-size: 1.25rem
      margin: 0 0 1.5rem 2rem
      text-align: left

      li
        margin-bottom: .25rem

      .fa-li
        margin-top: .25rem

.universe-multiverse-actions
  position: relative

  .galaxy-list
    background-color: darken($sp-primary-bg, 17.5%)
    border-left: 1px solid darken($sp-primary-bg, 15%)
    border-top: 1px solid darken($sp-primary-bg, 15%)
    border-right: 1px solid darken($sp-primary-bg, 5%)
    border-bottom: 1px solid darken($sp-primary-bg, 5%)
    min-height: 15rem

  .galaxy-actions-level
    margin-top: .5rem
    margin-bottom: 1rem

.news-container
  border-top: 1px solid $sp-primary
  height: calc(100% - 33rem)
  max-height: 30rem
  padding-top: 1.5rem

  .news-header
    border-bottom: 1px solid darken($sp-primary, 20%)
    font-size: 1.35rem
    font-weight: bold
    height: 3rem
    letter-spacing: .15rem
    padding-bottom: .5rem

    span,
    a
      line-height: 2.5rem

    .version
      font-size: 1rem
      float: right
      margin-top: .25rem

  .news-loading
    height: calc(100% - 3rem)
    overflow: hidden
    position: relative
    text-align: center
    vertical-align: middle

    .starpeace-logo
      bottom: 50%
      filter: invert(38%) sepia(9%) saturate(1145%) hue-rotate(112deg) brightness(101%) contrast(86%)
      background-size: 10rem
      margin-left: -5rem
      margin-top: -5rem
      position: absolute
      height: 10rem
      top: 50%
      width: 10rem

  .news-content
    display: flex
    height: calc(100% - 3rem)
    padding: 1rem 0
    position: relative
    overflow-x: hidden
    overflow-y: auto

    .columns
      margin: 0

    .news-date
      font-size: 1rem
      font-weight: bold
      margin-bottom: .25rem

    .news-title
      color: lighten($sp-primary, 5%)
      font-size: 1.2rem
      font-weight: bold
      margin-bottom: .75rem
      position: relative

    .news-item
      padding-right: .25rem

      ul
        margin-left: 1.25rem

</style>
