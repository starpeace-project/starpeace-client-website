<template lang='pug'>
.logo-content
  img.starpeace-logo
  .label-loading(v-if='messageKey') {{ $translate(messageKey) }}
  .label-loading(v-else-if='message') {{ message }}
</template>

<script lang='ts'>
export default {
  props: {
    messageKey: { type: String, required: false },
    message: { type: String, required: false }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace'

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
