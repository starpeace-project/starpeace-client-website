<template lang='pug'>
span.industry-category-icon(:class="{'is-small': small, 'no-active': no_active}")
  template(v-if="category == 'CIVIC'")
    img(src='~/assets/images/icons/civics/fountain.svg')
  template(v-else-if="category == 'COMMERCE'")
    img(src='~/assets/images/icons/commerce/shop.svg')
  template(v-else-if="category == 'INDUSTRY'")
    img(src='~/assets/images/icons/industries/factory.svg')
  template(v-else-if="category == 'LOGISTICS'")
    img(src='~/assets/images/icons/logistics/warehouse.svg')
  template(v-else-if="category == 'REAL_ESTATE'")
    img(src='~/assets/images/icons/offices/office-block.svg')
  template(v-else-if="category == 'SERVICE'")
    img(src='~/assets/images/icons/services/headquarters.svg')
  template(v-else-if="true")
    font-awesome-icon(:icon="['far', 'circle']")
</template>

<script lang='coffee'>
export default
  name: 'industry-category-icon'
  props:
    category: String

    small: Boolean
    no_active: Boolean

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.industry-category-icon
  display: inline-flex
  justify-content: center

  img
    filter: invert(75%) sepia(8%) saturate(1308%) hue-rotate(111deg) brightness(93%) contrast(83%)
    width: 100%
    vertical-align: middle

  &.is-small
    img
      height: 1rem
      width: 1rem

.is-active
  .industry-category-icon:not(.no-active)
    img
      filter: invert(100%)

</style>
