<template lang='pug'>
.list-item
  a(:class="{'is-active':expanded, 'no-actions':!detailsCallback}" @click.stop.prevent='toggle')
    span.item-toggle
      template(v-if='detailsCallback')
        font-awesome-icon(v-if='expanded' :icon="['fas', 'chevron-down']")
        font-awesome-icon(v-else :icon="['fas', 'chevron-right']")

    span.item-label {{label}}

  div(v-if='expanded')
    template(v-if='loading')
      .loading-container
        img.starpeace-logo

    template(v-else)
      slot(:details='details')

</template>

<script lang='coffee'>

export default
  props:
    clientState: Object
    label: String
    detailsId: String
    detailsCallback: Function

  data: ->
    expanded: false
    detailsPromise: null
    details: null

  computed:
    loading: -> @expanded && @detailsId?.length && @detailsPromise?

  watch:
    expanded: -> @refreshDetails()
    detailsId: -> @refreshDetails()

  methods:
    toggle: ->
      return unless @detailsCallback?
      @expanded = !@expanded

    refreshDetails: ->
      try
        if @expanded
          return if @detailsPromise?
          @detailsPromise = @detailsCallback(@detailsId)
          @details = await @detailsPromise
          @detailsPromise = null
        else
          @details = null
      catch err
        @clientState.add_error_message('Failure loading details from server', err)
        @detailsPromise = null

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

.list-item
  margin-top: 1px
  overflow: hidden

  a
    display: block
    background-color: darken($sp-primary-bg, 12.5%)
    font-weight: normal
    padding: .25rem

    &.is-active
      background-color: $sp-primary-bg

    &.no-actions
      touch-action: none

.item-toggle
  display: inline-block
  padding: 0 .25rem 0 .5rem
  width: 1.9rem

.item-label
  padding: 0 .5rem 0 .25rem

</style>
