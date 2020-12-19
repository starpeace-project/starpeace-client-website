<template lang='pug'>
#common-header(v-show='show_header', v-cloak=true)
  .common-logo.not-mobile.is-hidden-mobile
    a.logo(href='/')
      h1 STAR
      img.starpeace-logo
      h1 PEACE
  .common-logo.mobile.is-hidden-tablet
    a.logo(href='/')
      h1 STAR
      img.starpeace-logo
      h1 PEACE

  .welcome.is-hidden-mobile.is-hidden-tablet-only
    span {{translate('ui.page-layout.header.greeting')}}, {{tycoon_name}}!
    a(v-if='is_authenticated' v-on:click.stop.prevent="logout_tycoon()") ({{translate('ui.workflow.universe.signout.label')}})

  .development.is-hidden-mobile.is-hidden-tablet-only
    a.header-item.documentation(href='https://docs.starpeace.io') {{translate('ui.page-layout.header.documentation')}}
    a.header-item.community(href='https://starpeace-project.com/', target='_blank') {{translate('ui.page-layout.header.community')}}
    language-select(:language_code='language_code', v-on:changed='change_language')
    a.header-item.discord(href='https://discord.gg/TF9Bmsj', target='_blank')
      font-awesome-icon(:icon="['fab', 'discord']")
    a.header-item.twitter(href='https://twitter.com/starpeace_io', target='_blank')
      font-awesome-icon(:icon="['fab', 'twitter']")
    a.header-item.github(href='https://github.com/starpeace-project/starpeace-client-website', target='_blank')
      font-awesome-icon(:icon="['fab', 'github']")

</template>

<script lang='coffee'>
import LanguageSelect from '~/components/misc/language-select.vue'

export default
  components:
    'language-select': LanguageSelect

  props:
    options: Object
    translation_manager: Object

    client_state: Object
    managers: Object

  mounted: ->
    @client_options?.subscribe_options_listener =>
      @show_header = @client_options?.option('general.show_header')
      @show_header = true unless @show_header?
      @language_code = @client_options?.language()

  data: ->
    show_header: if @client_options? then @client_options.option('general.show_header') else true
    language_code: if @client_options? then @client_options?.language() else 'EN'

  computed:
    client_options: -> if @client_state?.options? then @client_state?.options else @options
    translator: -> if @managers?.translation_manager? then @managers.translation_manager else @translation_manager

    is_authenticated: -> @client_state?.identity?.galaxy_tycoon?
    tycoon_name: -> if @is_authenticated then @client_state?.identity?.galaxy_tycoon?.name else @translate('identity.visitor')

  methods:
    translate: (key) -> if @translator? then @translator.text(key) else key
    change_language: (code) -> @client_options?.set_language(code)

    logout_tycoon: () ->
      return unless @client_state?.identity?.galaxy_id? && @managers?.galaxy_manager?
      @managers.galaxy_manager.logout(@client_state?.identity?.galaxy_id)
        .then () =>
          @client_state.reset_full_state()
        .catch (e) =>
          console.error e
          @$forceUpdate()
</script>

<style lang='sass' scoped>
#common-header
  color: #fff
  font-size: 1.25rem
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 1
  grid-row-end: 1
  line-height: 3rem
  padding-top: .25rem
  z-index: 2000

  .common-logo
    float: left

    .starpeace-logo
      filter: brightness(0) saturate(100%) invert(100%) sepia(1%) saturate(7498%) hue-rotate(205deg) brightness(105%) contrast(100%)
      background-size: 2.5rem
      display: inline-block
      height: 2.5rem
      margin: 0 0 .5rem
      width: 2.5rem
      vertical-align: middle

    h1
      display: inline-block
      font-size: 3rem
      line-height: 3rem
      margin: .25rem .25rem .5rem
      vertical-align: middle

      &:not(:first-child)
        margin-left: .5rem

    &.mobile
      padding: 2vw 1vw 1vw
      text-align: center
      width: 100%

      .starpeace-logo
        background-size: 9vw
        height: 9vw
        margin: 0 0 .5rem
        width: 9vw

      h1
        font-size: 11vw

  a
    color: #fff

  .welcome
    float: left
    margin: .25rem 0 0 .5rem

    span
      margin-right: 1rem

  .development
    float: right
    padding-top: .25rem

    .header-item
      display: inline-block
      line-height: 3rem
      margin: 0 1rem
      vertical-align: bottom

      &.discord,
      &.twitter,
      &.github
        font-size: 1.4rem

      &.twitter
        line-height: 2.95rem

      &.discord
        line-height: 2.9rem
</style>
