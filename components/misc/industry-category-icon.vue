(v-els<template lang='pug'>
  span.industry-category-icon(:class="icon_class")
    template(v-if="industry_category == 'CIVIC'")
      img(src='~/assets/images/icons/civics/fountain.svg')
    template(v-else-if="industry_category == 'COMMERCE'")
      img(src='~/assets/images/icons/commerce/shop.svg')
    template(v-else-if="industry_category == 'INDUSTRY'")
      img(src='~/assets/images/icons/industries/factory.svg')
    template(v-else-if="industry_category == 'LOGISTICS'")
      img(src='~/assets/images/icons/logistics/warehouse.svg')
    template(v-else-if="industry_category == 'REAL_ESTATE'")
      img(src='~/assets/images/icons/offices/office-block.svg')
    template(v-else-if="industry_category == 'SERVICE'")
      img(src='~/assets/images/icons/services/headquarters.svg')
    template(v-else-if="true")
      font-awesome-icon(:icon="['far', 'circle']")
</template>

<script lang='coffee'>
export default
  name: 'industry-category-icon'
  props:
    industry_category: String
    small: Boolean
    no_active: Boolean

  computed:
    icon_class: ->
      classes = []
      classes.push 'is-small' if @small
      classes.push 'no-active' if @no_active
      classes
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.industry-category-icon
  display: inline-block
  vertical-align: middle

  img
    filter: invert(75%) sepia(8%) saturate(1308%) hue-rotate(111deg) brightness(93%) contrast(83%)
    width: 100%

.is-active
  .industry-category-icon:not(.no-active)
    img
      filter: invert(100%)

</style>
