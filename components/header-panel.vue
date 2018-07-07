<template lang='haml'>
%no-ssr
  #common-header{'v-show':'show_header', 'v-cloak':true}
    .common-logo
      %a.logo{href: '/'}
        %h1 STAR
        %img.starpeace-logo
        %h1 PEACE

    .welcome
      %span Welcome, Visitor!
      %a.login-header{href: '/login.html'} Sign In

    .development
      %a.documentation{href: 'https://docs.starpeace.io'} Documentation
      %a.community{href: 'https://starpeaceproject.com/'} Community
      %a.discord{href: 'https://discord.gg/TF9Bmsj'}
        %font-awesome-icon{':icon':"['fab', 'discord']"}
      %a.github{href: 'https://github.com/ronappleton/starpeace-website-client'}
        %font-awesome-icon{':icon':"['fab', 'github']"}
</template>

<script lang='coffee'>
export default
  props:
    client: Object

  computed:
    show_header: -> @client?.ui_state?.show_header

</script>

<style lang='sass' scoped>
#common-header
  color: #fff
  font-size: 1.25rem
  grid-column-start: 1
  grid-column-end: 4
  grid-row-start: 1
  grid-row-end: 1
  line-height: 3rem
  padding-top: .25rem
  z-index: 1025

  .common-logo
    float: left

    .starpeace-logo
      filter: brightness(0) saturate(100%) invert(100%) sepia(1%) saturate(7498%) hue-rotate(205deg) brightness(105%) contrast(100%)
      background-size: 2.5rem
      display: inline-block
      height: 2.5rem
      margin: 0 0 .5rem
      width: 2.5rem
      vertical-align: middle

    h1
      display: inline-block
      font-size: 3rem
      line-height: 3rem
      margin: .25rem .25rem .5rem
      vertical-align: middle

      &:not(:first-child)
        margin-left: .5rem

  a
    color: #fff

  .welcome
    float: left
    margin: .25rem 0 0 .5rem

    span
      margin-right: 1rem

  .development
    float: right
    padding-top: .25rem

    a
      display: inline-block
      line-height: 3rem
      margin: 0 1rem
      vertical-align: bottom

      &.discord,
      &.github
        font-size: 1.4rem

      &.discord
        line-height: 2.8rem
</style>
