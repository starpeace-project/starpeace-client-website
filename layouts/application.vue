<template>
  <div>
    <nuxt/>
  </div>
</template>

<style lang='sass'>
@import '~bulma/sass/utilities/_all'

html
  font-size: 12px
  overflow-y: hidden

body
  background: url('~/assets/images/background.jpg') top center repeat-y
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

#application
  display: grid
  grid-template-columns: .5rem auto .5rem
  grid-template-rows: 4rem auto 3rem 15.5rem

#application-container
  display: grid
  grid-template-columns: .5rem auto .5rem
  grid-template-rows: 4rem auto 3rem 15.5rem
  height: 100vh
  position: relative

  +mobile
    grid-template-rows: calc(11vw + 1.5rem) auto 3rem 15.5rem

    #common-header
      display: inline-block
      width: 100%

  &.no-header
    @media screen and (max-width: 768px)
      grid-template-rows: calc(1rem) auto 3rem 15.5rem

  #application-body
    grid-column-start: 1
    grid-column-end: 4
    grid-row-start: 2
    grid-row-end: 2
    margin: 0

</style>
