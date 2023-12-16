<template lang='pug'>
span(:class='money_css_class')
  template(v-if='has_value') ${{money_value}}
  template(v-else) -
</template>

<script lang='ts'>
import _ from 'lodash';
import Utils from '~/plugins/starpeace-client/utils/utils.js'

export default {
  name: 'money-text',
  props: {
    value: { type: Number, required: false },

    no_styling: Boolean,
    as_thousands: { type: Boolean, required: false, default: false }
  },

  computed: {
    has_value (): boolean { return _.isNumber(this.value); },
    money_value (): string | null {
      if (!_.isNumber(this.value)) return null;
      return this.as_thousands ? `${Utils.format_money(this.value / 1000)}K` : Utils.format_money(this.value);
    },
    money_css_class (): string {
      if (!_.isNumber(this.value) || this.no_styling) return '';
      if (this.value < 0) return 'negative';
      if (this.value > 0) return 'positive';
      return '';
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.negative
  color: $color-negative

.positive
  color: $color-positive

</style>
