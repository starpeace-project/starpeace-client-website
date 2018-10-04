<template lang='haml'>
.logo-content
  %img.starpeace-logo
  .label-loading {{message}}
</template>

<script lang='coffee'>
export default
  props:
    message: String
    show_menu: Boolean

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace'

.logo-content
  text-align: center

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
