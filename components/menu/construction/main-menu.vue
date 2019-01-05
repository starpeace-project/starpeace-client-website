<template lang='haml'>
#construction-container.card.is-starpeace.has-header
  .card-header
    .card-header-title
      Construction
    .card-header-icon.card-close{'v-on:click.stop.prevent':"client_state.menu.toggle_menu('construction')"}
      %font-awesome-icon{':icon':"['fas', 'times']"}

  .card-content.sp-menu-background.overall-container
    .field.filter-input-container
      .control.has-icons-left.is-expanded
        %input.input{type:"text", placeholder:"Filter"}
        %span.icon.is-left
          %font-awesome-icon{':icon':"['fas', 'search-location']"}
    %nav.breadcrumb.is-medium.menu-breadcrumb
      %ul
        %li{':class':'root_breadcrumb_class'}
          %a{'v-on:click.stop.prevent':'select_root_breadcrumb'}
            %template{'v-if':'company_seal_id'}
              %span.icon.is-small
                %company-seal-icon.company-seal{':seal_id':"company_seal_id"}
              %span {{company_seal_name}}
            %template{'v-else-if':'true'}
              %span.icon.is-small
                %font-awesome-icon.tycoon-icon{':icon':"['fas', 'user-secret']"}
              %span Visitor
        %template{'v-if':'selected_menu_category'}
          %li.is-active
            %a.construction-breadcrumb-item
              %span.icon.is-small
                %industry-category-icon{':industry_category':'selected_menu_category', 'no_active':true}
              %span {{text_for_category(selected_menu_category)}}

    #construction-image-pending{'ref':"pendingContainer"}
      #construction-image-webgl-container{'ref':"previewContainer"}

    %aside.sp-menu-category.sp-scrollbar{'v-show':"has_selected_menu_category"}
      %template{'v-for':"info in sort_buildings(buildings_for_company_by_category[selected_menu_category])"}
        %a.is-building-item{'v-on:click.stop.prevent':"toggle_building(info)", ':class':"selected_building_id == info.id ? 'active' : ''"}
          %industry-type-icon{':industry_type':"info.industry_type", ':small':'true'}
          %span.is-building-label {{building_name(info)}}
          .construction-disabled{'v-show':"!can_construct_building(info)"}

        %a.construct-action{'v-on:click.stop.prevent':"select_building(info)", ':disabled':'!can_construct_building(info)'}
          .tile.is-ancestor.is-item-details{'v-show':"selected_building_id == info.id"}
            .tile.is-parent.is-vertical
              .tile.is-parent.is-item-details-top
                %article.tile.is-child.is-7{':ref':"'previewItem.' + info.id"}
                %article.tile.is-child
                  .building-cost
                    %money-text{':value':'info.cost()', 'no_styling':true, 'as_thousands':true}
                  .building-size {{building_size(info)}}m&sup2;
              .tile.is-parent.is-item-details-bottom
                %article.tile.is-child
                  .building-description {{building_description(info)}}
                  .building-research{'v-show':"info.required_invention_ids.length"}
                    %span.research-label Requires:
                    %template{'v-for':'id,index in info.required_invention_ids'}
                      %template{'v-if':'is_invention_completed(id)'}
                        %span.research-completed {{invention_name(id)}}
                      %template{'v-else-if':'true'}
                        %a{'v-on:click.stop.prevent':'select_invention(id)'} {{invention_name(id)}}
                      %span.research-separator{'v-if':"index < info.required_invention_ids.length - 1"} {{separator_label_for_index(index, info.required_invention_ids.length)}}
                  %a.button.is-fullwidth.is-starpeace.construct-button{'v-on:click.stop.prevent':"select_building(info)", ':disabled':'!can_construct_building(info)'} Construct Building

    %aside.sp-menu-overall.sp-scrollbar{'v-show':"!has_selected_menu_category"}
      .tile.is-ancestor.construction-items
        .tile.is-6.is-vertical.is-parent
          .tile.is-child
            %a.construction-toggle{'v-on:click.stop.prevent':"select_category('SERVICE')", ':disabled':"!category_has_buildings('SERVICE')"}
              %img{src:'~/assets/images/icons/services/headquarters.svg'}
              %span.toggle-label {{text_for_category('SERVICE')}}
              .disabled-overlay
          .tile.is-child
            %a.construction-toggle{'v-on:click.stop.prevent':"select_category('INDUSTRY')", ':disabled':"!category_has_buildings('INDUSTRY')"}
              %img{src:'~/assets/images/icons/industries/factory.svg'}
              %span.toggle-label {{text_for_category('INDUSTRY')}}
              .disabled-overlay
          .tile.is-child
            %a.construction-toggle{'v-on:click.stop.prevent':"select_category('LOGISTICS')", ':disabled':"!category_has_buildings('LOGISTICS')"}
              %img{src:'~/assets/images/icons/logistics/warehouse.svg'}
              %span.toggle-label {{text_for_category('LOGISTICS')}}
              .disabled-overlay
        .tile.is-6.is-vertical.is-parent
          .tile.is-child
            %a.construction-toggle{'v-on:click.stop.prevent':"select_category('CIVIC')", ':disabled':"!category_has_buildings('CIVIC')"}
              %img{src:'~/assets/images/icons/civics/fountain.svg'}
              %span.toggle-label {{text_for_category('CIVIC')}}
              .disabled-overlay
          .tile.is-child
            %a.construction-toggle{'v-on:click.stop.prevent':"select_category('COMMERCE')", ':disabled':"!category_has_buildings('COMMERCE')"}
              %img{src:'~/assets/images/icons/commerce/shop.svg'}
              %span.toggle-label {{text_for_category('COMMERCE')}}
              .disabled-overlay
          .tile.is-child
            %a.construction-toggle{'v-on:click.stop.prevent':"select_category('REAL_ESTATE')", ':disabled':"!category_has_buildings('REAL_ESTATE')"}
              %img{src:'~/assets/images/icons/offices/office-block.svg'}
              %span.toggle-label {{text_for_category('REAL_ESTATE')}}
              .disabled-overlay

</template>

<script lang='coffee'>
import MoneyText from '~/components/misc/money-text.vue'
import CompanySealIcon from '~/components/misc/company-seal-icon.vue'
import IndustryCategoryIcon from '~/components/misc/industry-category-icon.vue'
import IndustryTypeIcon from '~/components/misc/industry-type-icon.vue'

import CompanySeal from '~/plugins/starpeace-client/industry/company-seal.coffee'
import IndustryCategory from '~/plugins/starpeace-client/industry/industry-category.coffee'

export default
  props:
    client_state: Object
    managers: Object

  components:
    'money-text': MoneyText
    'company-seal-icon': CompanySealIcon
    'industry-category-icon': IndustryCategoryIcon
    'industry-type-icon': IndustryTypeIcon

  computed:
    is_ready: -> @client_state?.workflow_status == 'ready'
    is_visible: -> @is_ready && @client_state?.menu?.is_visible('construction')

    is_tycoon: -> @is_ready && @client_state?.identity?.identity?.is_tycoon()
    company_id: -> if @is_tycoon then @client_state.player.company_id else null
    company_seal_id: -> if @company_id? then @client_state.seal_for_company_id(@company_id) else null
    company_seal_name: -> if @company_seal_id? then CompanySeal.SEALS[@company_seal_id].name else null

    root_breadcrumb_class: -> if @selected_menu_category? then '' else 'is-active'

    has_selected_menu_category: -> @selected_menu_category?
    selected_menu_category: -> @client_state.interface.construction_selected_category
    selected_building_id: -> @client_state.interface.construction_selected_building_id

    buildings_for_company_by_category: ->
      building_infos = if @company_seal_id? then @client_state.core.building_library.metadata_by_seal_id[@company_seal_id] else _.values(@client_state.core.building_library.metadata_by_id)
      _.groupBy(_.filter(building_infos || [], (info) -> !info.restricted), (info) -> info.category)

  watch:
    company_id: (new_value, old_value) ->
      @client_state.interface.construction_selected_category = null
      @client_state.interface.construction_building_id = null

  mounted: ->
    @client_state.corporation.subscribe_company_inventions_listener => @$forceUpdate() if @is_visible

  methods:
    sort_buildings: (buildings) ->
      _.sortBy(buildings, (info) -> "#{info.industry_type}-#{_.padStart(info.cost(), 12, '0')}")

    separator_label_for_index: (index, length) ->
      if length > 2 then (if index == length - 2 then ', and ' else ', ') else ' and '

    category_has_buildings: (category) -> @buildings_for_company_by_category[category]?.length
    text_for_category: (category) -> if category? then @managers.translation_manager.text(IndustryCategory.CATEGORIES[category].text_key) else ''

    can_construct_building: (building_info) -> @client_state.has_construction_requirements(building_info.id)

    building_name: (building_info) -> @managers.translation_manager.text(building_info.name_key)
    building_description: (building_info) -> @managers.building_manager.description_for_building(building_info)

    building_size: (building_info) ->
      building_definition = @client_state.core.building_library.metadata_by_id[building_info.id]
      return 0 unless building_definition?
      building_image = @client_state.core.building_library.images_by_id[building_definition.image_id]
      return 0 unless building_image?
      (building_image.w * 20) * (building_image.h * 20)

    invention_name: (id) ->
      metadata = @client_state.core.invention_library.metadata_for_id(id)
      if metadata? then @managers.translation_manager.text(metadata.name_key) else id

    is_invention_completed: (id) ->
      return false unless @company_id?
      @client_state.corporation.completed_invention_ids_for_company(@company_id).indexOf(id) >= 0


    select_root_breadcrumb: ->
      return unless @selected_menu_category?
      @client_state.interface.construction_selected_category = null
      if @selected_building_id?
        @client_state.interface.construction_selected_building_id = null
        @$refs.previewContainer.parentElement.removeChild(@$refs.previewContainer)
        @$refs.pendingContainer.appendChild(@$refs.previewContainer)

    select_category: (category) ->
      return unless @category_has_buildings(category)
      @client_state.interface.construction_selected_category = category

    toggle_building: (info) ->
      @$refs.previewContainer.parentElement.removeChild(@$refs.previewContainer)
      if @selected_building_id == info.id
        @client_state.interface.construction_selected_building_id = null
        @$refs.pendingContainer.appendChild(@$refs.previewContainer)
      else
        @client_state.interface.construction_selected_building_id = info.id
        preview_container = @$refs["previewItem.#{info.id}"]
        preview_container = preview_container[0] if Array.isArray(preview_container)
        preview_container.appendChild(@$refs.previewContainer)

    select_building: (info) ->
      return unless @can_construct_building(info)
      @client_state.initiate_building_construction(info.id)

    select_invention: (id) ->
      @client_state.interface.inventions_selected_invention_id = id
      @client_state.menu.toggle_menu('research')

</script>

<style lang='sass' scoped>
@import '~assets/stylesheets/starpeace-variables'

#construction-container
  grid-column-start: 3
  grid-row-start: 2
  grid-column-end: 4
  grid-row-end: 5
  overflow: hidden
  width: 30rem
  z-index: 1100

  .card-content
    height: calc(100% - 3.2rem)
    padding: 0

  .filter-input-container
    height: 3.75rem
    margin-bottom: 1rem
    padding: 1.25rem 1.25rem 0 1.25rem

  .menu-breadcrumb
    height: 2rem
    margin-bottom: .75rem
    padding: 0 1.25rem

  .sp-menu-overall
    padding: 0 1.25rem
    overflow-y: auto

  .sp-menu-category
    overflow-y: scroll

  .sp-menu-overall,
  .sp-menu-category
    height: calc(100% - 4.75rem - 2.75rem - 3.5rem)
    position: absolute
    overflow-x: hidden
    width: 100%

    li
      padding: 0 1.25rem

  #construction-image-pending
    display: none

  #construction-image-webgl-container
    height: 6rem
    width: 12rem

  .is-building-item
    background-color: darken($sp-primary-bg, 9%)
    border-bottom: 1px solid darken($sp-primary-bg, 11%)
    cursor: zoom-in
    display: inline-block
    padding: .5rem .75rem
    position: relative
    width: 100%

    .construction-disabled
      background-color: #000
      height: 100%
      left: 0
      opacity: .5
      pointer-events: none
      position: absolute
      top: 0
      width: 100%
      z-index: 1000

    &:not(.disabled),
    &:not([disabled])
      &:hover
        background-color: darken($sp-primary-bg, 6.5%)
        border-bottom: 1px solid darken($sp-primary-bg, 9%)

      &:active
        color: #8bb3a7
        font-weight: normal

      &.active
        background-color: darken($sp-primary-bg, 4%)
        border-bottom: 1px solid darken($sp-primary-bg, 6%)

      &.active
        cursor: zoom-out

    &.disabled
      cursor: not-allowed

    .is-building-label
      margin-left: .5rem

  .is-item-details
    margin: 0

    > .tile
      &.is-parent
        padding: 0

    .is-item-details-top
      padding-bottom: .25rem

    .is-item-details-bottom
      padding-top: .25rem

  .construct-action
    cursor: pointer

    &[disabled]
      cursor: not-allowed

    article
      position: relative

    .building-cost
      font-size: 1.25rem
      font-weight: bold
      text-align: right

    .building-size
      text-align: right

    .research-label
      margin-right: .5rem

    .research-completed
      font-style: italic

    .construct-button
      margin-top: .5rem

  .construction-toggle
    border: 1px solid lighten($sp-primary-bg, 5%)
    display: inline-block
    padding: 1rem
    position: relative
    text-align: center

    &:not([disabled])
      &:hover
        background-color: lighten($sp-primary-bg, 2.5%)

      &:active
        background-color: lighten($sp-primary-bg, 7.5%)

    img
      filter: invert(75%) sepia(8%) saturate(1308%) hue-rotate(111deg) brightness(93%) contrast(83%)
      width: 50%

    .toggle-label
      display: block
      font-size: 1.25rem

    .disabled-overlay
      background-color: #000
      cursor: not-allowed
      display: none
      height: 100%
      left: 0
      opacity: .5
      position: absolute
      top: 0
      width: 100%

    &[disabled]
      .disabled-overlay
        display: block

  .construction-breadcrumb-item
    img
      height: 1rem
      width: 1rem

  .construction-toggle,
  .construction-breadcrumb-item
    &:not([disabled])
      &:active
        img
          filter: invert(100%)

</style>
