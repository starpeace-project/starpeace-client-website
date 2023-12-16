<template lang='pug'>
span.toggle-icons(:class="{'is-disabled': disabled}")
  a(v-show="value" @click.stop.prevent='toggle')
    font-awesome-icon(:icon="['fas', 'toggle-on']")
  a(v-show="!value" @click.stop.prevent='toggle')
    font-awesome-icon(:icon="['fas', 'toggle-off']")
</template>

<script lang='ts'>
export default {
  props: {
    value: Boolean,
    disabled: Boolean
  },

  methods: {
    toggle (): void {
      if (this.disabled) return;
      this.$emit('toggle');
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.toggle-icons
  font-size: 1.5rem
  line-height: 1.5rem

  &.is-disabled
    a
      cursor: not-allowed

  a
    cursor: pointer
    color: $sp-primary

  .fa-toggle-on
    color: #fff
    font-weight: 1000
</style>
