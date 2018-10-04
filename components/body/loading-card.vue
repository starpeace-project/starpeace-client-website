<template lang='haml'>
#loading-container.level{'v-show':'is_loading'}
  .level-item
    .card
      .card-content
        %img.starpeace-logo
        .label-loading Loading...
</template>

<script lang='coffee'>
export default
  props:
    game_state: Object

  computed:
    is_loading: -> (@game_state?.initialized || false) && (@game_state?.loading || false)
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

.no-header
  #loading-container
    grid-row-start: 1

.card
  max-width: 20rem
  text-align: center
  width: 100%
  z-index: 1050

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
