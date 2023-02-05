<template lang='pug'>
.ranking-option
  a(:class='ranking_class' @click.stop.prevent="$emit('toggle', ranking.corporationId)")
    span.ranking-rank {{ranking.rank}}
    span.ranking-name {{ranking.corporationName}}

    span.ranking-value
      template(v-if="rankingType.unit == 'CURRENCY'")
        misc-money-text(:value='ranking.value' no_styling)
      template(v-else)
        | {{ranking.value}}

  .tycoon-section(v-if='is_selected')
    template(v-if='is_loading')
      .loading-container
        img.starpeace-logo

    template(v-else)
      menu-shared-menu-panel-corporation(
        hide-corporation=true
        :managers='managers'
        :client-state='clientState'
        :tycoon='ranking'
        :corporation='corporation'
      )
</template>

<script lang='coffee'>
export default
  props:
    managers: Object
    clientState: Object
    ajaxState: Object

    rankingType: Object
    ranking: Object

  data: ->
    corporation: null

  computed:
    ranking_class: ->
      classes = []
      classes.push 'rank-player' if @ranking.corporationId == @clientState?.player?.corporation_id
      classes.push 'rank-first' if @ranking.rank == 1
      classes.push 'rank-top' if @ranking.rank > 1 && @ranking.rank <= 5
      classes.push 'is-active' if @is_selected
      classes

    selected_ranking_corporation_id: -> @clientState?.interface?.selected_ranking_corporation_id
    is_selected: -> @ranking.corporationId == @selected_ranking_corporation_id
    is_loading: ->
      return false unless @is_selected && @selected_ranking_corporation_id?.length
      @ajaxState.request_mutex['corporation_metadata']?[@selected_ranking_corporation_id] || !@corporation?

  mounted: ->
    @clientState.core.corporation_cache.subscribe_corporation_metadata_listener => @refresh_corporation()

  watch:
    selected_ranking_corporation_id: -> @refresh_corporation()

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    refresh_corporation: () -> @corporation = if @is_selected then @clientState.core.corporation_cache.metadata_for_id(@selected_ranking_corporation_id) else null

</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

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

.ranking-option
  margin-top: 1px

  a
    align-items: center
    display: grid
    grid-template-columns: max-content auto max-content
    grid-template-rows: auto
    font-weight: normal

    > span
      background-color: darken($sp-primary-bg, 20%)

    &.rank-first
      > span
        background-color: darken($sp-primary-bg, 7.5%)
        font-weight: bold

    &.rank-top
      > span
        background-color: darken($sp-primary-bg, 12.5%)

    &.rank-player
      > span
        color: #ccc
        font-weight: bold

      &:hover
        > span
          color: #ddd

      &:active,
      &.is-active
        > span
          color: #fff

    &.is-active
      > span
        background-color: $sp-primary-bg

.ranking-rank
  margin-right: 1px
  min-width: 2.25rem
  padding: .5rem .5rem
  text-align: center

.ranking-name,
.ranking-value
  padding: .5rem .5rem

</style>
