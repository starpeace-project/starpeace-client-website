<template lang='pug'>
.toggle-icons(:class="{'is-disabled': disabled}")
  a(v-show="value" @click.stop.prevent='toggle')
    font-awesome-icon(:icon="['fas', 'toggle-on']")
  a(v-show="!value" @click.stop.prevent='toggle')
    font-awesome-icon(:icon="['fas', 'toggle-off']")
</template>

<script lang='coffee'>
export default
  props:
    value: Boolean
    disabled: Boolean

  methods:
    toggle: ->
      return if @disabled
      @$emit('toggle')

</script>

<style lang='sass' scoped>
.toggle-icons
  font-size: 1.5rem
  line-height: 1.5rem

  &.s-disabled
    a
      cursor: not-allowed

  a
    cursor: pointer

  .fa-toggle-on
    color: #fff
    font-weight: 1000
</style>
