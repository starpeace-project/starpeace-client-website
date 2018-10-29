<template lang='haml'>
%span.sp-city-icon
  %img{src:'~/assets/images/icons/general/cityscape.svg'}
</template>

<script lang='coffee'>
export default
  name: 'city-icon'
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.sp-city-icon
  img
    filter: invert(75%) sepia(8%) saturate(1308%) hue-rotate(111deg) brightness(93%) contrast(83%)
    height: 1rem
    margin-top: .16rem
    width: 1rem

</style>
