<template lang='pug'>
#loading-container.level(v-show='is_visible' :class="{'is-sp-grid':withinGrid, 'is-sp-absolute':withinAbsolute}")
  .level-item
    .card.is-starpeace
      .card-content
        img.starpeace-logo
        .label-loading {{$translate('ui.workflow.loading')}}
</template>

<script lang='ts'>
export default {
  props: {
    client_state: Object,

    withinGrid: Boolean,
    withinAbsolute: Boolean,
    visible: Boolean
  },

  computed: {
    is_visible (): boolean { return this.client_state?.initialized && this.client_state?.loading || this.visible; }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace'

#loading-container
  margin: 0
  position: relative

  &.is-sp-grid
    grid-column-start: 1
    grid-column-end: 4
    grid-row-start: start-render
    grid-row-end: end-render

  &.is-sp-absolute
    position: absolute
    height: 100%
    width: 100%

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
