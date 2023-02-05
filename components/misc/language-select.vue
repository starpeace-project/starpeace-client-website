<template lang='pug'>
.navbar-item.has-dropdown.is-hoverable.language-select
  a.header-item.navbar-link
    span.fi(:class='current_language_flag')
  .navbar-dropdown.is-boxed.is-starpeace
    a.navbar-item(@click.stop.prevent="change_language('DE')", :class="{'is-active': language_code == 'DE' }")
      span.fi.fi-de
      | de
    a.navbar-item(@click.stop.prevent="change_language('EN')", :class="{'is-active': language_code == 'EN' }")
      span.fi.fi-gb
      | en
    a.navbar-item(@click.stop.prevent="change_language('ES')", :class="{'is-active': language_code == 'ES' }")
      span.fi.fi-es
      | es
    a.navbar-item(@click.stop.prevent="change_language('FR')", :class="{'is-active': language_code == 'FR' }")
      span.fi.fi-fr
      | fr
    a.navbar-item(@click.stop.prevent="change_language('IT')", :class="{'is-active': language_code == 'IT' }")
      span.fi.fi-it
      | it
    a.navbar-item(@click.stop.prevent="change_language('PT')", :class="{'is-active': language_code == 'PT' }")
      span.fi.fi-br
      | pt
</template>

<script lang='coffee'>
export default
  name: 'language-select'
  props:
    language_code: String

  computed:
    current_language_flag: ->
      return 'fi-de' if @language_code == 'DE'
      return 'fi-gb' if @language_code == 'EN'
      return 'fi-es' if @language_code == 'ES'
      return 'fi-fr' if @language_code == 'FR'
      return 'fi-it' if @language_code == 'IT'
      return 'fi-br' if @language_code == 'PT'
      'fi-gb'

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
      right: 0.25em

    &:hover,
    &:active,
    &.is-hover,
    &.is-active
      background-color: inherit

  .navbar-item
    color: #fff !important
    font-size: 1.25rem
    padding-right: 1rem

    .fi
      margin-right: .5rem

  .header-item
    line-height: 3rem
    margin: 0 1rem
    vertical-align: bottom
</style>
