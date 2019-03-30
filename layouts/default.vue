<template>
  <nuxt/>
</template>

<script lang='coffee'>
export default
  head: ->
    {
      htmlAttrs: {
        class: 'default-layout'
      }
      bodyAttrs: {
        class: 'default-layout'
      }
    }
</script>

<style lang='sass'>
html
  &.default-layout
    font-size: 12px
    overflow-y: scroll

    body
      background: url('~assets/images/background.jpg') top center repeat-y
      background-size: 100%
      box-sizing: border-box
      color: #000
      font-family: 'Open Sans', sans-serif
      font-size: 12px
      margin: 0
      padding: 0
      -webkit-touch-callout: none
      -webkit-user-select: none
      -khtml-user-select: none
      -moz-user-select: none
      -ms-user-select: none
      user-select: none

      #application-container
        display: grid
        grid-template-columns: .5rem auto .5rem
        grid-template-rows: 4rem auto

        @media screen and (max-width: 768px)
          display: inline-block
          width: 100%

          #common-header
            display: inline-block
            width: 100%

        #application-body
          grid-column-start: 1
          grid-column-end: 4
          grid-row-start: 2
          grid-row-end: 2
          margin: 0
</style>
