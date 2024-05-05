<template lang='pug'>
span.is-inline-flex(:class="{'is-active': value, 'is-disabled': disabled}")
  span.toggle-icons
    a(v-show='value' @click.stop.prevent='toggle')
      font-awesome-icon(:icon="['fas', 'toggle-on']")
    a(v-show='!value' @click.stop.prevent='toggle')
      font-awesome-icon(:icon="['fas', 'toggle-off']")

  span.toggle-label.ml-2(v-if='labelSuffix' @click.stop.prevent='toggle') {{ $translate(labelSuffix) }}
</template>

<script lang='ts'>
export default {
  props: {
    labelSuffix: { type: String, required: false },
    value: Boolean,
    disabled: { type: Boolean, required: false },
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

  a
    cursor: pointer
    color: $sp-primary

.toggle-label
  color: $sp-primary
  cursor: pointer
  font-size: 1rem

.is-active
  .toggle-icons
    a
      font-weight: 1000

    svg
      color: #fff

  .toggle-label
    color: #fff

.is-disabled
  .toggle-icons
    a
      cursor: not-allowed

    svg
      filter: brightness(50%)

  .toggle-label
    cursor: not-allowed
    filter: brightness(50%)

</style>
