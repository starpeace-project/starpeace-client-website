<template lang='haml'>
.columns
  .column
    %ul
      %li.system-item{'v-for':'system in planetary_systems'}
        %table.table.system-table
          %tbody
            %tr
              %td.system-image{rowspan:4}
                %img.system-image.starpeace-logo.logo-loading{'v-bind:src':"system_animation_url(system)", 'v-on:load':"$event.target.classList.remove('logo-loading')"}
              %td{colspan:3}
                %h3 {{system.name}}
              %td.system-select{rowspan:4}
                %a.button.is-primary.is-medium.is-outlined.choose-system.float-right{'v-on:click.stop.prevent':'select_planetary_system(system.id)', href:'#'} Inspect
            %tr.system-info-row
              %td Population:
              %td.planet-value {{0}}
            %tr.system-info-row
              %td Planets:
              %td.planet-value {{system.planets.length}}
            %tr.system-info-row
              %td Online:
              %td.planet-value {{0}}
</template>

<script lang='coffee'>
export default
  props:
    client: Object

  computed:
    game_state: -> @client?.game_state
    planetary_metadata_manager: -> @client.planetary_metadata_manager

    planetary_systems: ->
      @planetary_metadata_manager?.systems_metadata || []

  methods:
    select_planetary_system: (planetary_system_id) ->
      system = @planetary_metadata_manager.planetary_system_for_id(planetary_system_id)
      throw "unknown planetary system id <#{planetary_system_id}>" unless system?
      @client.game_state.current_planetary_system = system
      window.document.title = "#{@game_state.current_planetary_system.name} - STARPEACE" if window?.document?
      console.debug "[starpeace] proceeding with planetary system <#{@game_state.current_planetary_system}>"

    system_animation_url: (system) -> ''



</script>

<style lang='sass' scoped>
.columns
  margin: 0

  .column
    padding: 0

.system-item
  background-color: opacify(lighten(#395950, 1%), .3)
  border: 1px solid rgba(110, 161, 146, .2)
  padding-bottom: .25rem

  &:not(:first-child)
    margin-top: .25rem

.system-table
  background-color: transparent
  color: #fff
  margin: 0
  width: 100%

  tr
    &:first-child
      td
        border: 0

    &.system-info-row
      font-size: 1rem

  td
    padding: .25rem
    vertical-align: middle

    &.system-image
      padding: .5rem 1.5rem 0 1rem
      text-align: center
      width: 10rem

      .starpeace-logo
        background-size: 7.5rem
        height: 7.5rem
        width: 7.5rem

  .system-value
    text-align: right

  .system-select
    max-width: 10rem
    padding-left: 1rem
    text-align: center
    width: 10rem
</style>
