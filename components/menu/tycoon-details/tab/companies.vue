<template lang='pug'>
.sp-tab
  .companies-tab
    .sp-scrollbar
      table.basic-table.sp-striped.sp-solid-header.sp-sticky-header.companies(:class="{'hoverable': is_self}")
        thead
          tr
            th.sp-kv-key {{translate('ui.menu.tycoon_details.tab.companies')}}
            th.has-text-centered.sp-kv-key.column-seal {{translate('ui.menu.tycoon_details.tab.companies.seal')}}
            th.has-text-right.sp-kv-key.column-building-count {{translate('ui.menu.tycoon_details.tab.companies.building_count')}}
            th.column-action

        tbody
          tr(v-for='company in sorted_companies' :class="{'is-selected': is_company_selected(company.id)}" @click.stop.prevent='select_company(company.id)')
            td.is-size-5 {{company.name}}
            td.has-text-centered {{company.seal_name}}
            td.has-text-right {{company.building_count}}
            td.column-action
              .is-flex.is-justify-content-center
                button.button.is-small.is-starpeace(disabled) {{translate('ui.menu.tycoon_details.tab.companies.actions.rename')}}
                button.button.is-small.is-starpeace(disabled) {{translate('ui.menu.tycoon_details.tab.companies.actions.delete')}}

        tfoot(v-if='has_corporation && is_self')
          tr
            td.has-text-centered.py-4(colspan=4)
              button.button.is-starpeace(@click.stop.prevent='toggle_form_company_menu') {{translate('ui.menu.company.form.action.form')}}

    .is-flex.is-align-items-center.is-justify-content-center
      //- company P&L

</template>

<script lang='coffee'>
import _ from 'lodash';

import Utils from '~/plugins/starpeace-client/utils/utils.coffee'

export default
  props:
    managers: Object
    clientState: Object
    tycoonId: String
    corporationId: String

  computed:
    has_corporation: -> @corporationId?.length
    is_self: -> @clientState.player.tycoon_id == @tycoonId

    corporation: -> if @has_corporation then @clientState.core.corporation_cache.metadata_for_id(@corporationId) else null
    companies: -> @corporation?.companies || []
    sorted_companies: ->
      _.orderBy(@companies, ['name'], ['asc']).map((c) =>
        {
          id: c.id
          name: @clientState.name_for_company_id(c.id)
          seal_name: @clientState.core.planet_library.seal_for_id(@clientState.seal_for_company_id(c.id))?.name_long
          building_count: (@clientState.corporation.buildings_ids_by_company_id?[c.id] || []).length
        }
      )

  methods:
    translate: (text_key) -> @managers?.translation_manager?.text(text_key)

    is_company_selected: (company_id) -> @clientState.player.company_id == company_id
    select_company: (company_id) -> @clientState.player.company_id = company_id

    toggle_form_company_menu: () -> @clientState.menu.toggle_menu('company_form') if @has_corporation && @is_self

</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-menus'
@import '~/assets/stylesheets/starpeace-menus-tycoon-details'

.companies-tab
  display: grid
  grid-template-columns: auto max(40vw, 50rem)
  height: 100%

  .sp-scrollbar
    overflow-y: scroll

.basic-table
  td
    &.column-action
      .is-flex
        column-gap: 1rem

  &.companies
    th
      &.column-seal
        width: 16rem

      &.column-building-count
        width: 8rem

      &.column-prestige
        width: 10rem

      &.column-action
        width: 20rem

</style>
