<template lang='haml'>
%span{'v-bind:class':'money_css_class'} ${{money_value}}
</template>

<script lang='coffee'>
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default
  name: 'money-text'
  props:
    value: Number

  computed:
    money_value: -> Utils.format_money(@value)
    money_css_class: -> if @value < 0 then 'negative' else if @value > 0 then 'positive' else ''
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.negative
  color: $color-negative

.positive
  color: $color-positive

</style>
