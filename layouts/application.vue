<template>
  <nuxt/>
</template>

<script lang='coffee'>
export default
  head: ->
    {
      htmlAttrs: {
        class: 'application-layout'
      }
      bodyAttrs: {
        class: 'application-layout'
      }
    }
</script>

<style lang='sass'>
@import '~bulma/sass/utilities/_all'

html
  &.application-layout
    font-size: 12px
    overflow-y: hidden

    body
      background: url('~assets/images/background.jpg') top center repeat-y
      background-size: 100%
      box-sizing: border-box
      color: #000
      font-family: 'Open Sans', sans-serif
      font-size: 12px
      height: 100vh
      margin: 0
      padding: 0
      -webkit-touch-callout: none
      -webkit-user-select: none
      -khtml-user-select: none
      -moz-user-select: none
      -ms-user-select: none
      user-select: none

</style>
