<template lang='pug'>
#loading-modal(:class="{'is-grid':withinGrid, 'is-absolute':withinAbsolute}")
</template>

<script lang='coffee'>
export default
  props:
    withinGrid: Boolean
    withinAbsolute: Boolean
</script>

<style lang='sass' scoped>
#loading-modal
  background-color: #000
  opacity: .5
  z-index: 1900

  &.is-grid
    grid-column-start: 1
    grid-column-end: 4
    grid-row-start: 2
    grid-row-end: 7

  &.is-absolute
    position: absolute
    height: 100%
    width: 100%

</style>
