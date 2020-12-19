<template lang='pug'>
.search-result-option
  a(:class='result_class' @click.stop.prevent="expanded=!expanded")
    span.result-name
      template(v-if="mode=='TYCOONS'") {{result.tycoonName}}
      template(v-else-if="mode=='CORPORATIONS'") {{result.corporationName}}

  .tycoon-section(v-if='expanded')
    template(v-if='is_loading')
      .loading-container
        img.starpeace-logo

    template(v-else)
      menu-panel-corporation(
        :hide-tycoon="mode=='TYCOONS'"
        :hide-corporation="mode=='CORPORATIONS'"
        :managers='managers'
        :client-state='clientState'
        :tycoon='result'
        :corporation='corporation'
      )

</template>

<script lang='coffee'>
import MenuPanelCorporation from '~/components/menu/shared/menu-panel/corporation.vue'

export default
  components: {
    MenuPanelCorporation
  }

  props:
    managers: Object
    clientState: Object
    ajaxState: Object

    mode: String
    result: Object

  data: ->
    expanded: false
    corporation: null

  computed:
    result_class: ->
      classes = []
      classes.push 'is-active' if @expanded
      classes

    corporation_id: -> @result?.corporationId

    is_loading: ->
      return false unless @expanded && @corporation_id?.length
      @ajaxState.request_mutex['corporation_metadata']?[@corporation_id] || !@corporation?

  watch:
    corporation_id: -> @refresh_corporation()
    expanded: -> @refresh_corporation()

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    refresh_corporation: () ->
      try
        if @expanded
          @corporation = await @managers.corporation_manager.load_by_corporation(@corporation_id)
        else
          @corporation = null
      catch err
        console.error err

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.loading-container
  justify-content: center
  display: flex
  margin: 1rem 0

  .starpeace-logo
    animation: spin-and-blink 1.5s linear infinite
    background-size: 5rem
    filter: $sp-filter-primary
    height: 5rem
    opacity: .7
    width: 5rem

.search-result-option
  margin-top: 1px

  a
    align-items: center
    background-color: darken($sp-primary-bg, 12.5%)
    display: grid
    grid-template-columns: auto
    grid-template-rows: auto
    font-weight: normal

    &.is-active
      background-color: $sp-primary-bg

.result-name
  padding: .5rem .5rem

</style>
