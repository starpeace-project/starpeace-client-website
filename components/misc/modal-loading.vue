<template lang='pug'>
#loading-modal(:class="{'is-sp-grid': withinGrid, 'is-sp-absolute': withinAbsolute}")
</template>

<script lang='ts'>
export default {
  props: {
    withinGrid: Boolean,
    withinAbsolute: Boolean
  }
}
</script>

<style lang='sass' scoped>
#loading-modal
  background-color: #000
  opacity: .5
  z-index: 1900

  &.is-sp-grid
    grid-column-start: 1
    grid-column-end: 4
    grid-row-start: start-render
    grid-row-end: end-toolbar

  &.is-sp-absolute
    position: absolute
    height: 100%
    width: 100%

</style>
