<template lang='pug'>
span.sp-city-icon
  img(src='~/assets/images/icons/general/cityscape.svg')
</template>

<script lang='ts'>
export default {
  name: 'city-icon'
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.sp-city-icon
  display: inline-block
  min-width: 1.25rem
  text-align: center

  img
    filter: invert(75%) sepia(8%) saturate(1308%) hue-rotate(111deg) brightness(93%) contrast(83%)
    height: 1.1rem
    margin-bottom: -.1rem
    width: 1.1rem

</style>
