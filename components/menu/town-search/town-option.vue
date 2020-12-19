<template lang='pug'>
.town-option
  a(:class='result_class' @click.stop.prevent="$emit('toggle', town.id)")
    span.town-icon
      city-icon
    span.town-name {{town.name}}

  .tycoon-section(v-if='expanded')
    template(v-if='is_loading')
      .loading-container
        img.starpeace-logo

    template(v-else)
      menu-panel-town(
        :managers='managers'
        :client-state='clientState'
        :visible='expanded'
        :town='town'
      )

</template>

<script lang='coffee'>
import CityIcon from '~/components/misc/city-icon.vue'
import MenuPanelTown from '~/components/menu/shared/menu-panel/town.vue'

export default
  components: {
    CityIcon
    MenuPanelTown
  }

  props:
    managers: Object
    clientState: Object
    ajaxState: Object

    expanded: Boolean
    town: Object

  computed:
    result_class: ->
      classes = []
      classes.push 'is-active' if @expanded
      classes

    is_loading: -> false


  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

.loading-container
  justify-content: center
  display: flex
  margin: 1rem 0

  .starpeace-logo
    animation: spin-and-blink 1.5s linear infinite
    background-size: 5rem
    filter: $sp-filter-primary
    height: 5rem
    opacity: .7
    width: 5rem

.town-option
  margin-top: 1px

  a
    align-items: center
    background-color: darken($sp-primary-bg, 12.5%)
    display: grid
    grid-template-columns: min-content auto
    grid-template-rows: auto
    font-weight: normal

    &.is-active
      background-color: $sp-primary-bg

.town-icon
  padding: .5rem
  padding-right: .25rem

.town-name
  padding: .5rem
  padding-left: .25rem

</style>
