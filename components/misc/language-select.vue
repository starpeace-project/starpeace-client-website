<template lang='pug'>
.navbar-item.has-dropdown.is-hoverable.language-select
  a.header-item.navbar-link
    span.flag-icon(:class='current_language_flag')
  .navbar-dropdown.is-boxed.is-starpeace
    a.navbar-item(v-on:click.stop.prevent="change_language('DE')", :class="language_code == 'DE' ? 'is-active' : ''")
      span.flag-icon.flag-icon-de
      | de
    a.navbar-item(v-on:click.stop.prevent="change_language('EN')", :class="language_code == 'EN' ? 'is-active' : ''")
      span.flag-icon.flag-icon-gb
      | en
    a.navbar-item(v-on:click.stop.prevent="change_language('ES')", :class="language_code == 'ES' ? 'is-active' : ''")
      span.flag-icon.flag-icon-es
      | es
    a.navbar-item(v-on:click.stop.prevent="change_language('FR')", :class="language_code == 'FR' ? 'is-active' : ''")
      span.flag-icon.flag-icon-fr
      | fr
    a.navbar-item(v-on:click.stop.prevent="change_language('IT')", :class="language_code == 'IT' ? 'is-active' : ''")
      span.flag-icon.flag-icon-it
      | it
    a.navbar-item(v-on:click.stop.prevent="change_language('PT')", :class="language_code == 'PT' ? 'is-active' : ''")
      span.flag-icon.flag-icon-br
      | pt
</template>

<script lang='coffee'>
export default
  name: 'language-select'
  props:
    language_code: String

  computed:
    current_language_flag: ->
      return 'flag-icon-de' if @language_code == 'DE'
      return 'flag-icon-gb' if @language_code == 'EN'
      return 'flag-icon-es' if @language_code == 'ES'
      return 'flag-icon-fr' if @language_code == 'FR'
      return 'flag-icon-it' if @language_code == 'IT'
      return 'flag-icon-br' if @language_code == 'PT'
      'flag-icon-gb'

  methods:
    change_language: (code) -> @$emit('changed', code)
</script>

<style lang='sass' scoped>
.language-select
  display: inline-block !important

  .navbar-link
    background-color: inherit !important
    color: #fff
    margin-right: 0
    padding: 0 2.25rem 0 0

    &::after
      border-color: #fff
      right: 0.775em

    &:hover,
    &:active,
    &.is-hover,
    &.is-active
      background-color: inherit

  .navbar-item
    color: #fff !important
    font-size: 1.25rem
    padding-right: 1rem

    .flag-icon
      margin-right: .5rem

  .header-item
    line-height: 3rem
    margin: 0 1rem
    vertical-align: bottom
</style>
