<template lang='haml'>
.logo-content
  %img.starpeace-logo
  .label-loading.sp-primary-color {{message}}
</template>

<script lang='coffee'>
export default
  props:
    message: String
    show_menu: Boolean

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

.logo-content
  text-align: center

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
