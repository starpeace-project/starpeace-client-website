<template lang='haml'>
  %p{'v-show':"!item.hidden", ':class':"item_container_class(item)"}
    %a{'v-on:click.stop.prevent':"item.toggle()", ':class':"item_level_class(item)"}
      %template{'v-if':"item.level == 0"}
        %span{'v-show':"item.children.length && !item.expanded"}
          %font-awesome-icon{':icon':"['fas', 'plus-square']"}
        %span{'v-show':"item.children.length && item.expanded"}
          %font-awesome-icon{':icon':"['fas', 'minus-square']"}
        %span.sp-folder-icon{'v-show':"!item.children.length"}
          %font-awesome-icon{':icon':"['fas', 'square']"}
        %span.sp-section-label {{item.name}}
      %template{'v-else-if':"true"}
        %template{'v-if':"item.type == 'CORPORATION'"}
          %span.sp-folder-icon{'v-if':"item.seal == 'DIS'"}
            %font-awesome-icon{':icon':"['fab', 'bimobject']", flip:'horizontal'}
          %span.sp-folder-icon{'v-if':"item.seal == 'MAGNA'"}
            %font-awesome-icon{':icon':"['fab', 'megaport']"}
          %span.sp-folder-icon{'v-if':"item.seal == 'MKO'"}
            %font-awesome-icon{':icon':"['fab', 'monero']"}
          %span.sp-folder-icon{'v-if':"item.seal == 'MOAB'"}
            %font-awesome-icon{':icon':"['fab', 'mizuni']"}
          %span.sp-folder-icon{'v-if':"item.seal == 'PGI'"}
            %font-awesome-icon{':icon':"['fas', 'parking']"}
        %template{'v-else-if':"item.type == 'TOWN'"}
          %span.sp-folder-icon.sp-city-icon
            %img{src:'~/assets/images/icons/general/cityscape.svg'}
        %template{'v-else-if':"true"}
          %span.sp-folder-icon{'v-show':"item.children.length && !item.expanded"}
            %font-awesome-icon{':icon':"['fas', 'folder']"}
          %span.sp-folder-icon{'v-show':"item.children.length && item.expanded"}
            %font-awesome-icon{':icon':"['fas', 'folder-open']"}
          %span.sp-folder-icon{'v-show':"!item.children.length"}
            %font-awesome-icon{':icon':"['far', 'folder']"}
        %span.sp-folder-label {{item.name}}

    %bookmark-item-body{'v-if':'item.is_folder()', 'v-bind:item':'item'}
</template>

<script lang='coffee'>
import BookmarkItemBody from '~/components/menu/bookmarks/bookmark-item-body.vue'

export default
  components:
    'bookmark-item-body': BookmarkItemBody

  name: 'bookmark-item'
  props:
    item: Object

  methods:
    item_container_class: (item) ->
      classes = []
      classes.push 'sp-section' if item.is_folder() && item.level == 0
      classes.push 'sp-folder' if item.is_folder() && item.level != 0
      classes
    item_level_class: (item) ->
      classes = ["sp-level-#{item.level || 0}"]
      classes.push 'disabled' if item.is_folder() && !item.children.length
      classes

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.sp-menu
  height: calc(100% - .5rem - 4rem - 3.5rem - 3.5rem)
  overflow-x: hidden
  overflow-y: scroll

  .sp-section
    border-bottom: 1px solid darken($sp-primary-bg, 7.5%)
    border-left: 0
    border-right: 0

    > a
      background-color: darken($sp-primary-bg, 3%)
      display: inline-block
      font-size: .75em
      letter-spacing: .1em
      padding: .75rem 1rem
      text-transform: uppercase
      width: 100%

      &:not(.disabled)
        &:hover
          background-color: $sp-primary-bg

        &:active
          color: lighten($sp-primary, 20%)

    &:first-child
      border-top: 1px solid darken($sp-primary-bg, 7.5%)

    .sp-section-label
      margin-left: 1rem

  .sp-folder
    > a
      background-color: darken($sp-primary-bg, 9%)
      border-bottom: 1px solid darken($sp-primary-bg, 11%)
      display: inline-block
      padding: .75rem .75rem
      width: 100%

      &:not(.disabled)
        &:hover
          background-color: darken($sp-primary-bg, 6.5%)
          border-bottom: 1px solid darken($sp-primary-bg, 9%)

        &:active
          background-color: darken($sp-primary-bg, 4%)
          border-bottom: 1px solid darken($sp-primary-bg, 6%)

    .sp-folder-icon
      display: inline-block
      min-width: 1.25rem

    .sp-folder-label
      margin-left: .5rem

    .sp-city-icon
      img
        filter: invert(75%) sepia(8%) saturate(1308%) hue-rotate(111deg) brightness(93%) contrast(83%)
        height: 1rem
        margin-top: .16rem
        width: 1rem

  a
    &.disabled
      cursor: not-allowed

    &.sp-level-1
      padding-left: .9rem

    &.sp-level-2
      padding-left: 1.8rem

</style>
