<template lang='haml'>
.card.has-header
  .card-header
    .card-header-title
      Map Locations
    .card-header-icon.card-close{'v-on:click.stop.prevent':'menu_state.toggle_menu_favorites()'}
      %font-awesome-icon{':icon':"['fas', 'times']"}

  .card-content.overall-container
    .filter-items
      %a.filter-toggle.tooltip.is-tooltip-top{'v-bind:class':"filter_class('services')", 'v-on:click.stop.prevent':"toggle_filter('services')", 'data-tooltip':'Services'}
        %img{src:'~/assets/images/icons/services/headquarters.svg'}
      %a.filter-toggle.tooltip.is-tooltip-top{'v-bind:class':"filter_class('industries')", 'v-on:click.stop.prevent':"toggle_filter('industries')", 'data-tooltip':'Industries'}
        %img{src:'~/assets/images/icons/industries/factory.svg'}
      %a.filter-toggle.tooltip.is-tooltip-top{'v-bind:class':"filter_class('warehouses')", 'v-on:click.stop.prevent':"toggle_filter('warehouses')", 'data-tooltip':'Logistics'}
        %img{src:'~/assets/images/icons/logistics/warehouse.svg'}
      %a.filter-toggle.tooltip.is-tooltip-top{'v-bind:class':"filter_class('commerce')", 'v-on:click.stop.prevent':"toggle_filter('commerce')", 'data-tooltip':'Commerce'}
        %img{src:'~/assets/images/icons/commerce/shop.svg'}
      %a.filter-toggle.tooltip.is-tooltip-top{'v-bind:class':"filter_class('civics')", 'v-on:click.stop.prevent':"toggle_filter('civics')", 'data-tooltip':'Civics'}
        %img{src:'~/assets/images/icons/civics/fountain.svg'}
      %a.filter-toggle.tooltip.is-tooltip-top{'v-bind:class':"filter_class('residentials')", 'v-on:click.stop.prevent':"toggle_filter('residentials')", 'data-tooltip':'Residentials'}
        %img{src:'~/assets/images/icons/residentials/lower.svg'}
      %a.filter-toggle.tooltip.is-tooltip-top{'v-bind:class':"filter_class('offices')", 'v-on:click.stop.prevent':"toggle_filter('offices')", 'data-tooltip':'Offices'}
        %img{src:'~/assets/images/icons/offices/office-block.svg'}

    %p.control.has-icons-left
      %typeahead{':source':"source", ':onSelect':'filter_input_select', ':onChange':'filter_input_change', ':limit':5}
      %span.icon.is-small.is-left
        %font-awesome-icon{':icon':"['fas', 'search-location']"}

</template>

<script lang='coffee'>
export default
  props:
    menu_state: Object

  data: ->
    filter_input_value: ''
    source: ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California']

  methods:
    filter_class: (type) ->
      ""
    toggle_filter: (type) ->
      console.log "toggle #{type}"

    filter_input_select: (value) ->
      @filter_input_value = value
    filter_input_change: (value) ->
      @filter_input_value = value

</script>

<style lang='sass' scoped>
$sp-primary: #6ea192
$sp-primary-bg: #395950

.card
  height: 100%
  max-width: 30rem
  overflow: hidden
  position: absolute
  width: 100%
  z-index: 1050

  .card-content
    height: calc(100% - 3.2rem)

    &.overall-container
      padding-top: .5rem

.filter-items
  position: relative
  text-align: center

  .filter-toggle
    border: 1px solid lighten($sp-primary-bg, 5%)
    display: inline-block
    padding: .4rem

    &:not(:first-child)
      margin-left: 1rem

    img
      filter: invert(63%) sepia(8%) saturate(1308%) hue-rotate(111deg) brightness(93%) contrast(83%)
      height: 1.6rem
      width: 1.6rem

      path
        fill: $sp-primary !important

    &:hover
      background-color: opacify($sp-primary-bg, .5)

    &:active
      background-color: lighten($sp-primary-bg, 7.5%)

      img
        filter: invert(100%)

</style>
