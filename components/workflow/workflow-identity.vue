<template lang='haml'>
.identity-content
  %p.welcome-message
    %span.salut Welcome, Visitor!
    &nbsp;&nbsp;Please select a visa option to begin your STARPEACE adventure!&nbsp;&nbsp;
    %a{href: 'https://docs.starpeace.io'} Learn more

  .columns
    .column
      %h3 Visitor Visa
      %font-awesome-icon.tycoon-icon{':icon':"['fas', 'user-secret']"}
      %ul.fa-ul
        %li
          %font-awesome-icon.fa-li{':icon':"['fas', 'check']"}
          Meet new people
        %li
          %font-awesome-icon.fa-li{':icon':"['fas', 'check']"}
          See what's happening
        %li
          %font-awesome-icon.fa-li{':icon':"['fas', 'check']"}
          Become a Tycoon later
      %a.button.is-medium.is-primary.demo{'v-on:click.stop.prevent':'proceed_as_visitor()', href: '#'} Visitor Visa

    .column
      %h3 Tycoon Visa
      %font-awesome-icon.tycoon-icon{':icon':"['fas', 'user-tie']"}
      %ul.fa-ul
        %li
          %font-awesome-icon.fa-li{':icon':"['fas', 'check']"}
          Get $100,000,000
        %li
          %font-awesome-icon.fa-li{':icon':"['fas', 'check']"}
          Create a company
        %li
          %font-awesome-icon.fa-li{':icon':"['fas', 'check']"}
          Build an Empire!
      %a.button.is-medium.is-info.login{href:'/login.html'} Tycoon Visa
</template>

<script lang='coffee'>
export default
  props:
    game_state: Object

  methods:
    proceed_as_visitor: -> @game_state?.proceed_as_visitor()

</script>

<style lang='sass' scoped>
.welcome-message
  border-bottom: 1px solid #6ea192
  color: #fff
  font-size: 1.5rem
  padding: 0 .5rem 1rem
  margin-bottom: 0

  .salut
    font-weight: bold

  a
    color: #fff
    font-size: 1.25rem

.columns
  margin-top: 0

.column
  text-align: center

  &:first-child
    border-right: 1px solid #6ea192

  h3
    color: #fff
    font-size: 1.75rem
    font-weight: 1000
    letter-spacing: .25rem

  .tycoon-icon
    color: #fff
    font-size: 4rem
    margin: .5rem 0 1rem

  ul
    text-align: left
    margin: 0 0 1.5rem 3rem
    font-size: 1.25rem

    li
      margin-bottom: .25rem

    .fa-li
      margin-top: .25rem

</style>
