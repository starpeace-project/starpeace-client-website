<template lang='pug'>
.identity-content
  .welcome-message.pb-5.mb-0
    span.salut {{ $translate('ui.workflow.visa-type.greeting') }}, {{ $translate('identity.visitor') }}!
    span.mx-4 {{ $translate('ui.workflow.visa-type.intro') }}
    a(href='https://docs.starpeace.io') {{ $translate('ui.workflow.visa-type.learnmore') }}

  .universe-mode.is-flex.is-flex-direction-row
    a.button.is-medium.is-flex-grow-1(:class="{'is-active': universeMode == 'starpeace'}" @click.stop.prevent="changeMode('starpeace')") STARPEACE {{ $translate('ui.workflow.universe.universe.label') }}
    a.button.is-medium.is-flex-grow-1(:class="{'is-active': universeMode == 'multiverse'}" @click.stop.prevent="changeMode('multiverse')") {{ $translate('ui.workflow.universe.multiverse.label') }}

  workflow-universe-starpeace(v-if="universeMode=='starpeace'" :client-state='clientState')
  workflow-multiverse-galaxy-list(v-else-if="universeMode=='multiverse'" :ajax-state='ajaxState' :client-state='clientState')

  .news-container
    template(v-if='showAnnouncement')
      announcements-2023-12-18-nw-test

    template(v-else)
      .news-header
        span {{ $translate('ui.workflow.visa-type.header.news') }}
        a.version(href='/release') {{ clientVersion }}

      template(v-if='!news.length')
        .news-loading
          img.starpeace-logo.logo-loading

      template(v-else-if='news.length')
        .news-content.sp-scrollbar
          .news-item(v-for='news_item in news')
            .news-date {{ news_item.date }}
            .news-title {{ news_item.title }}
            .news-body.content
              span.details(v-html='news_item_html(news_item.body)')
              ul(v-if='news_item.items && news_item.items.length')
                li(v-for='item in news_item.items') {{ item }}

</template>

<script lang='ts'>
import ClientState from '~/plugins/starpeace-client/state/client-state';

interface NewsUpdate {
  date: string;
  title: string;
  body: string;
  items: Array<string>;
}

interface WorkflowUniverseData {
  clientVersion: string;
  showAnnouncement: boolean;
  news: Array<NewsUpdate>;
  universeMode: string;
}

export default {
  props: {
    clientState: { type: ClientState, required: true },
    ajaxState: { type: Object, required: true }
  },

  data (): WorkflowUniverseData {
    return {
      clientVersion: this.$config.public.CLIENT_VERSION,
      showAnnouncement: false,
      news: [],
      universeMode: 'multiverse'
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
    changeMode (mode: string): void {
      this.universeMode = mode;
    },

    news_item_html (value: string): string {
      return value.replace(/\n/g, '<br>');
    }
  }
}
</script>

<style lang='sass' scoped>
@import 'bulma/sass/utilities'
@import '~/assets/stylesheets/starpeace-variables'

.identity-content
  height: 100%
  position: relative
  overflow: hidden

.welcome-message
  border-bottom: 1px solid $sp-primary
  color: #fff
  font-size: 1.5rem

  .salut
    font-weight: bold

  a
    color: #fff
    font-size: 1.25rem

.universe-mode
  border-bottom: 1px solid $sp-primary

  .button
    flex-basis: 0


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
