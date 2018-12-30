<template lang='haml'>
.field.is-horizontal
  .column.is-paddingless.is-9
    .field-label
      %label.label {{label}}:
  .column.is-paddingless.field-body
    .field.is-narrow
      .control
        .toggle-icons
          %a{href:'#', 'v-show':"value", 'v-on:click.stop.prevent':"$emit('toggle')"}
            %font-awesome-icon{':icon':"['fas', 'toggle-on']"}
          %a{href:'#', 'v-show':"!value", 'v-on:click.stop.prevent':"$emit('toggle')"}
            %font-awesome-icon{':icon':"['fas', 'toggle-off']"}
</template>

<script lang='coffee'>
export default
  props:
    label: String
    value: Boolean

</script>

<style lang='sass' scoped>

#options-container
  align-items: center
  display: flex
  grid-column-start: 2
  grid-column-end: 3
  grid-row-start: 2
  grid-row-end: 4
  justify-content: center
  z-index: 1100

.card
  max-width: 60rem
  width: 100%

  legend
    color: #fff
    font-weight: 1000

  .label
    &.group-header
      border-bottom: 1px solid
      font-weight: 1000
      padding-bottom: .25rem

  .second-group-header
    .field-label
      margin: 0

  .label-column
    color: #fff
    font-weight: 1000

  .toggle-icons
    font-size: 1.5rem
    line-height: 1.5rem
    cursor: pointer
    text-align: center

    .fa-toggle-on
      color: #fff
      font-weight: 1000

  .card-footer
    .card-footer-item
      a
        width: 100%

</style>
