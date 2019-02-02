<template lang='pug'>
span(:class='money_css_class') ${{money_value}}
</template>

<script lang='coffee'>
import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default
  name: 'money-text'
  props:
    value: Number
    no_styling: Boolean
    as_thousands: Boolean

  computed:
    money_value: -> if @as_thousands then "#{Utils.format_money(@value / 1000)}K" else Utils.format_money(@value)
    money_css_class: -> if @no_styling then '' else if @value < 0 then 'negative' else if @value > 0 then 'positive' else ''
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.negative
  color: $color-negative

.positive
  color: $color-positive

</style>
