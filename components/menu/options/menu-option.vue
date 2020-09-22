<template lang='pug'>
.field.is-horizontal
  .column.is-paddingless.is-9
    .field-label
      label.label {{label}}:
  .column.is-paddingless.field-body
    .field.is-narrow
      .control.toggle-field
        toggle-option(:value='value' @toggle="$emit('toggle')")
</template>

<script lang='coffee'>
import ToggleOption from '~/components/misc/toggle-option.vue'

export default
  components:
    'toggle-option': ToggleOption

  props:
    label: String
    value: Boolean
</script>

<style lang='sass' scoped>
.label
  &.group-header
    border-bottom: 1px solid
    font-weight: 1000
    padding-bottom: .25rem

.toggle-field
  line-height: 1.5rem
  text-align: center
</style>
