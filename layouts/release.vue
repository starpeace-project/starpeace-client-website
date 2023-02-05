<template>
  <slot/>
</template>

<style lang='sass'>
html
  font-size: 12px
  overflow-y: scroll

  body
    background: url('~/assets/images/background.jpg') top center repeat-y
    background-size: 100%
    box-sizing: border-box
    color: #000
    font-family: 'Open Sans', sans-serif
    font-size: 12px
    height: 100%

    #application-container
      display: grid
      grid-template-columns: .5rem auto .5rem
      grid-template-rows: [start-header] 4rem [end-header] auto

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
