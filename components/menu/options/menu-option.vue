<template lang='pug'>
.field.is-horizontal
  .column.p-0.is-9
    .field-label
      label.label
        span.mr-1 {{ label }}
        span.mr-1(v-if='hint' :data-tooltip='hint')
          font-awesome-icon(:icon="['far', 'question-circle']")
        span :
  .column.p-0.field-body
    .field.is-narrow
      .control.toggle-field
        misc-toggle-option(:value='value' @toggle="$emit('toggle')")
</template>

<script lang='ts'>
export default {
  props: {
    label: { type: String, required: true},
    hint: { type: String, required: false},
    value: { type: Boolean, required: true}
  }
}
</script>

<style lang='sass' scoped>
.label
  &.group-header
    border-bottom: 1px solid
    font-weight: 1000
    padding-bottom: .25rem

  span
    &[data-tooltip]
      border-bottom-width: 0 !important

.toggle-field
  line-height: 1.5rem
  text-align: center
</style>
