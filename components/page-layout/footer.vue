<template lang='pug'>
#footer-container
  .columns.links
    .column.is-2.is-offset-3
      a(href='https://docs.starpeace.io') Documentation
    .column.is-2
      a(href='https://www.starpeace.io/privacy') Privacy
    .column.is-2
      a(href='https://github.com/starpeace-project/starpeace-client-website' target='_blank') GitHub

  .columns.copyright
    .column.is-6.is-offset-3
      span(v-once=true, v-html='copyright()')
</template>

<script lang='coffee'>
import { DateTime } from 'luxon';

export default
  methods:
    copyright: () -> "Copyright &copy; #{DateTime.now().year}"
</script>

<style lang='sass' scoped>
#footer-container
  background-color: #fff
  border-top: 1rem solid #eee
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 3
  grid-row-end: 3
  margin-top: 2rem
  padding: 2rem
  text-align: center

  .links
    font-size: 1.2rem

    a
      color: #000
</style>
