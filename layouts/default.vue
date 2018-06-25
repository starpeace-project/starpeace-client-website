<template>
  <div>
    <nuxt/>
  </div>
</template>

<style lang='sass'>
/* https://nuxtjs.org/guide/views#layouts */

html
  font-size: 12px
  overflow-y: hidden

body
  background: url('~/assets/images/background.jpg') top center no-repeat
  background-size: cover
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

a
  font-weight: bold
  text-decoration: none

h1
  font-family: 'Varela Round', sans-serif
  letter-spacing: .5rem
  text-shadow: 0 0 2rem rgba(0, 0, 0, .7)

h2
  font-family: 'Varela Round', sans-serif
  font-size: 2rem

h3
  font-family: 'Open Sans Condensed', sans-serif
  font-size: 2rem
  text-shadow: 0 0 .25rem rgba(0, 0, 0, .2)


/* handle auto-generated vue transition classes */
.fade-enter-active
  transition: opacity .5s
.fade-leave-active
  transition: opacity .5s
.fade-enter
  opacity: 0
.fade-leave-to
  opacity: 0

.fade-in-enter-active
  transition: opacity .5s
.fade-in-enter
  opacity: 0
.fade-in-leave-to
  opacity: 0

/* cloak to keep DOM elements hidden until vue ready */
[v-cloak]
  display: none

</style>
