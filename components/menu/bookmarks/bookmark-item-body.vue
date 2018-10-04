<template lang='haml'>
  %ul.sp-menu-list{'v-show':"!item.hidden && item.expanded"}
    %li{'v-for':"child in item.children"}
      %bookmark-item{'v-if':"child.is_folder()", 'v-bind:item':'child', 'v-bind:key':'child.id'}
      %a.is-menu-item{'v-else-if':'true', ':class':"item_level_class(item)"}
        %template{'v-if':"child.type == 'TOWN'"}
          %span.link-image.sp-city-icon
            %img{src:'~/assets/images/icons/general/cityscape.svg'}
        %template{'v-else-if':"true"}
          %span.link-image
            %font-awesome-icon{':icon':"['fas', 'map-marker-alt']"}
        %span.link-label {{child.name}}
</template>

<script lang='coffee'>

export default
  beforeCreate: () ->
    @$options.components.BookmarkItem = require('~/components/menu/bookmarks/bookmark-item.vue').default

  name: 'bookmark-item-body'
  props:
    item: Object

  methods:
    item_level_class: (item) -> "sp-level-#{item.level || 0}"
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.sp-menu-list
  a
    &.is-menu-item
      background-color: darken($sp-primary-bg, 15%)
      border-bottom: 1px solid darken($sp-primary-bg, 17.5%)
      display: inline-block
      padding-bottom: .75rem
      padding-top: .75rem
      width: 100%

      &:hover
        background-color: darken($sp-primary-bg, 12.5%)
        border-bottom: 1px solid darken($sp-primary-bg, 15%)

      &:active
        background-color: darken($sp-primary-bg, 10%)
        border-bottom: 1px solid darken($sp-primary-bg, 12.5%)

    &.sp-level-0
      padding-left: .5rem

    &.sp-level-1
      padding-left: 1.4rem

    &.sp-level-2
      padding-left: 2.3rem

    &.sp-level-3
      padding-left: 3.2rem

  .level-anchor
    display: inline-block
    width: .6rem
    height: 1rem
    border-left: 1px dotted $sp-primary
    border-bottom: 1px dotted $sp-primary
    margin-bottom: .25rem
    margin-left: .4rem
    margin-right: .25rem

  .link-image
    border: 0
    padding: .25rem
    max-width: 2rem

  .sp-city-icon
    img
      filter: invert(75%) sepia(8%) saturate(1308%) hue-rotate(111deg) brightness(93%) contrast(83%)
      height: 1.5rem
      width: 1.5rem

  .link-label
    font-size: 1.25rem
    padding-left: .5rem
</style>
