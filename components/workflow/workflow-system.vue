<template lang='haml'>
.content.is-marginless
  .card.system{'v-for':'system in systems'}
    .card-content
      .level.is-mobile.system-row
        .level-left
          .level-item
            %img.system-image.starpeace-logo.logo-loading{'v-bind:src':"system_animation_url(system)", 'v-on:load':"$event.target.classList.remove('logo-loading')"}

        .level-item.system-item.info
          .content
            .system-name {{system.name}}
            .system-population.system-info-row
              %span Population:
              %span.planet-value {{system.population}}
            .system-planets.system-info-row
              %span Planets:
              %span.planet-value {{system.planets_metadata.length}}
            .system-online.system-info-row
              %span Online:
              %span.planet-value {{system.online_count}}

        .level-right
          .level-item
            %a.button.is-primary.is-medium.is-outlined.workflow-action{'v-on:click.stop.prevent':'select_system(system)', 'v-bind:disabled':'!system.enabled'} Inspect

</template>

<script lang='coffee'>
export default
  props:
    client: Object
    game_state: Object

  computed:
    systems: ->
      # FIXME: TODO: add better stale state support
      if @game_state?.common_metadata?.state_counter? && @game_state.common_metadata.has_systems_metadata_fresh()
        _.sortBy(_.values(@game_state.common_metadata.systems_metadata_by_id), (system) -> system.name)
      else
        []

  methods:
    system_animation_url: (system) -> ''
    select_system: (system) -> @client.select_system_id(system.id) if system.enabled
</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.workflow-action
  &.button
    min-width: 7rem

.card
  &.system
    background-color: opacify(lighten($sp-primary-bg, 1%), .3)
    border: 1px solid rgba(110, 161, 146, .2)
    padding-bottom: .25rem

    &:not(:first-child)
      margin-top: .25rem

    > .card-content
      padding: 1rem

    .system-row
      min-height: 5rem

      .system-image
        background-size: 7.5rem
        height: 7.5rem
        width: 7.5rem

      .system-item
        color: #fff

        &.info
          margin: 0 2rem 0 1rem
          justify-content: left

        > .content
          width: 100%

        .system-info-row
          border-bottom: 1px solid darken($sp-primary, 10%)
          padding-bottom: .25rem
          margin-bottom: .25rem

        .system-name
          font-size: 1.5rem
          font-weight: 1000
          margin-bottom: .25rem

        .planet-value
          margin-left: .5rem

</style>
