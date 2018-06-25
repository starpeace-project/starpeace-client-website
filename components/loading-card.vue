<template lang='haml'>
#loading-container.level{'v-show':'is_loading'}
  .level-item
    .card
      .card-content
        %img.starpeace-logo
        .label-loading.sp-primary-color Loading...
</template>

<script lang='coffee'>
export default
  props:
    client: Object

  computed:
    is_loading: -> (@client?.game_state?.initialized || false) && (@client?.game_state?.loading || false)
</script>

<style lang='sass' scoped>
$sp-filter-primary: invert(38%) sepia(9%) saturate(1145%) hue-rotate(112deg) brightness(101%) contrast(86%)
$sp-filter-light: invert(8%) sepia(22%) saturate(305%) hue-rotate(100deg) brightness(95%) contrast(97%)

@keyframes spin
  0%
    filter: $sp-filter-primary
  50%
    filter: $sp-filter-light
  100%
    filter: $sp-filter-primary
    transform: rotate(360deg)

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
    animation: spin 1.5s linear infinite
    background-size: 10rem
    filter: $sp-filter-primary
    height: 10rem
    margin-bottom: 1.5rem
    opacity: .7
    width: 10rem

  .label-loading
    font-size: 1rem
    font-style: italic


</style>
