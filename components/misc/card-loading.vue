<template lang='pug'>
#loading-container.level(v-show='is_visible')
  .level-item
    .card.is-starpeace
      .card-content
        img.starpeace-logo
        .label-loading {{translate('ui.workflow.loading')}}
</template>

<script lang='coffee'>
export default
  props:
    client_state: Object
    managers: Object

  computed:
    is_visible: -> @client_state?.initialized && @client_state?.loading

  methods:
    translate: (key) -> if @managers? then @managers.translation_manager.text(key) else key
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace'

#loading-container
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 2
  grid-row-end: 4
  margin: 0
  position: relative

.card
  max-width: 20rem
  text-align: center
  width: 100%
  z-index: 2000

  .starpeace-logo
    animation: spin-and-blink 1.5s linear infinite
    background-size: 10rem
    filter: $sp-filter-primary
    height: 10rem
    margin-bottom: 1.5rem
    opacity: .7
    width: 10rem

  .label-loading
    color: $sp-primary
    font-size: 1rem
    font-style: italic


</style>
