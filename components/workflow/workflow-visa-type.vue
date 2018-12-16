<template lang='haml'>
.identity-content
  %p.welcome-message
    %span.salut Welcome, Visitor!
    &nbsp;&nbsp;Please select a visa option to begin your STARPEACE adventure!&nbsp;&nbsp;
    %a{href: 'https://docs.starpeace.io'} Learn more

  .columns.identity-actions
    .column
      %h3 Visitor Visa
      %font-awesome-icon.tycoon-icon{':icon':"['fas', 'user-secret']"}
      %ul.fa-ul
        %li
          %font-awesome-icon.fa-li{':icon':"['fas', 'check']"}
          Meet new people
        %li
          %font-awesome-icon.fa-li{':icon':"['fas', 'check']"}
          See what's happening
        %li
          %font-awesome-icon.fa-li{':icon':"['fas', 'check']"}
          Become a Tycoon later
      %a.button.is-medium.is-primary.demo{'v-on:click.stop.prevent':'proceed_as_visitor()'} Visitor Visa

    .column
      %h3 Tycoon Visa
      %font-awesome-icon.tycoon-icon{':icon':"['fas', 'user-tie']"}
      %ul.fa-ul
        %li
          %font-awesome-icon.fa-li{':icon':"['fas', 'check']"}
          Get $100,000,000
        %li
          %font-awesome-icon.fa-li{':icon':"['fas', 'check']"}
          Create a company
        %li
          %font-awesome-icon.fa-li{':icon':"['fas', 'check']"}
          Build an Empire!
      %a.button.is-medium.is-info.login{'v-on:click.stop.prevent':'proceed_as_tycoon()'} Tycoon Visa

  .news-container
    .news-header
      %span News and Updates
      %a.version{href:'/release'} {{client_version}}
    %template{'v-if':'!news.length'}
      .news-loading
        %img.starpeace-logo.logo-loading
    %template{'v-else-if':'news.length'}
      .news-content.sp-scrollbar
        .is-mobile.news-item{'v-for':'news_item in news'}
          .news-date {{news_item.date}}
          .news-title {{news_item.title}}
          .news-body.content
            %span.details{'v-html':'news_item_html(news_item.body)'}
            %ul{'v-if':'news_item.items && news_item.items.length'}
              %li{'v-for':'item in news_item.items'} {{item}}

</template>

<script lang='coffee'>
export default
  props:
    client_state: Object

  data: ->
    client_version: process.env.CLIENT_VERSION
    news: []

  created: ->
    request = new XMLHttpRequest()
    request.open('GET', '/news.json', true)
    request.onload = () =>
      @news = JSON.parse(request.responseText).news if request.status >= 200 && request.status < 400
    request.send()

  methods:
    proceed_as_visitor: -> @client_state.identity.set_visa_type('visitor')
    proceed_as_tycoon: -> @client_state.identity.set_visa_type('tycoon')

    news_item_html: (value) -> value.replace(/\n/g, '<br>')
</script>

<style lang='sass' scoped>
@import '~bulma/sass/utilities/_all'
@import '~assets/stylesheets/starpeace-variables'

.identity-content
  height: 100%
  position: relative
  overflow: hidden

.welcome-message
  border-bottom: 1px solid $sp-primary
  color: #fff
  font-size: 1.5rem
  height: 6rem
  padding: 0 .5rem 1.5rem
  margin-bottom: 0

  .salut
    font-weight: bold

  a
    color: #fff
    font-size: 1.25rem

.identity-actions
  height: 22rem
  margin-top: 0
  margin-bottom: 0

  .column
    padding-bottom: 2rem
    text-align: center

    &:first-child
      +mobile
        border-bottom: 1px solid $sp-primary
        padding-bottom: 2rem

      +tablet
        border-right: 1px solid $sp-primary

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
      text-align: left
      margin: 0 0 1.5rem 3rem
      font-size: 1.25rem

      li
        margin-bottom: .25rem

      .fa-li
        margin-top: .25rem

.news-container
  border-top: 1px solid $sp-primary
  height: calc(100% - 28rem)
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
