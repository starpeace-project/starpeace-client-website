<template lang='pug'>
#construction-container.card.is-starpeace.has-header(:oncontextmenu="'return ' + !$config.public.disableRightClick")
  .card-header
    .card-header-title {{$translate('ui.menu.construction.header')}}
    .card-header-icon.card-close(@click.stop.prevent="client_state.menu.toggle_menu('construction')")
      font-awesome-icon(:icon="['fas', 'times']")

  .card-content.sp-menu-background.overall-container
    .field.filter-input-container
      .control.has-icons-left.is-expanded
        input.input(type="text", placeholder="Filter")
        span.icon.is-left
          font-awesome-icon(:icon="['fas', 'search-location']")
    nav.breadcrumb.is-medium.menu-breadcrumb
      ul
        li(:class='root_breadcrumb_class')
          a(@click.stop.prevent='select_root_breadcrumb')
            template(v-if='company_seal_id')
              span.icon.is-small
                misc-company-seal-icon.company-seal(:seal_id="company_seal_id")
              span {{company_seal_name}}
            template(v-else-if='true')
              span.icon.is-small
                font-awesome-icon.tycoon-icon(:icon="['fas', 'user-secret']")
              span {{$translate('identity.visitor')}}
        template(v-if='selected_menu_industry_category_id')
          li.is-active
            a.construction-breadcrumb-item
              span {{text_for_category(selected_menu_industry_category_id)}}

    #construction-image-pending(ref="pendingContainer")
      #construction-image-webgl-container(ref="previewContainer")

    aside.sp-menu-category.sp-scrollbar(v-if="has_selected_menu_category")
      template(v-for="info in sort_buildings(buildings_for_company_by_category[selected_menu_industry_category_id])")
        a.is-building-item(@click.stop.prevent="toggle_building(info)" :class="{'active': selected_building_id == info.id}")
          misc-industry-type-icon(:industry_type="info.industry_type_id" small)
          span.is-building-label {{building_name(info)}}
          .construction-disabled(v-show="!can_construct_building(info)")

        a.construct-action(@click.stop.prevent="select_building(info)" :disabled='!can_construct_building(info)')
          .tile.is-ancestor.is-item-details(v-show="selected_building_id == info.id")
            .tile.is-parent.is-vertical
              .tile.is-parent.is-item-details-top
                article.tile.is-child.is-7(:ref="'previewItem.' + info.id")
                article.tile.is-child
                  .building-cost
                    misc-money-text(:value='building_cost(info.id)', no_styling=true, as_thousands=true)
                  .building-size {{building_size(info)}}m&sup2;
              .tile.is-parent.is-item-details-bottom
                article.tile.is-child
                  .building-description {{building_description(info)}}
                  .building-research(v-show="info.required_invention_ids.length")
                    span.research-label {{$translate('ui.menu.construction.requires')}}:
                    template(v-for='id,index in info.required_invention_ids')
                      template(v-if='is_invention_completed(id)')
                        span.research-completed {{invention_name(id)}}
                      template(v-else)
                        a.research-pending(@click.stop.prevent='select_invention(id)') {{invention_name(id)}}
                      span.research-separator(v-if="index < info.required_invention_ids.length - 1") {{separator_label_for_index(index, info.required_invention_ids.length)}}
                  button.button.is-fullwidth.is-starpeace.construct-button(@click.stop.prevent="select_building(info)", :disabled='!can_construct_building(info)') {{$translate('ui.menu.construction.construct_building')}}

    aside.sp-menu-overall.sp-scrollbar(v-else)
      .tile.is-ancestor.construction-items
        .tile.is-6.is-vertical.is-parent
          .tile.is-child
            a.construction-toggle(@click.stop.prevent="select_category('SERVICE')" :class="{'disabled': !category_has_buildings('SERVICE')}")
              misc-industry-category-icon(category='SERVICE')
              span.toggle-label {{text_for_category('SERVICE')}}
              .disabled-overlay
          .tile.is-child
            a.construction-toggle(@click.stop.prevent="select_category('INDUSTRY')" :class="{'disabled': !category_has_buildings('INDUSTRY')}")
              misc-industry-category-icon(category='INDUSTRY')
              span.toggle-label {{text_for_category('INDUSTRY')}}
              .disabled-overlay
          .tile.is-child
            a.construction-toggle(@click.stop.prevent="select_category('LOGISTICS')" :class="{'disabled': !category_has_buildings('LOGISTICS')}")
              misc-industry-category-icon(category='LOGISTICS')
              span.toggle-label {{text_for_category('LOGISTICS')}}
              .disabled-overlay
        .tile.is-6.is-vertical.is-parent
          .tile.is-child
            a.construction-toggle(@click.stop.prevent="select_category('CIVIC')" :class="{'disabled': !category_has_buildings('CIVIC')}")
              misc-industry-category-icon(category='CIVIC')
              span.toggle-label {{text_for_category('CIVIC')}}
              .disabled-overlay
          .tile.is-child
            a.construction-toggle(@click.stop.prevent="select_category('COMMERCE')" :class="{'disabled': !category_has_buildings('COMMERCE')}")
              misc-industry-category-icon(category='COMMERCE')
              span.toggle-label {{text_for_category('COMMERCE')}}
              .disabled-overlay
          .tile.is-child
            a.construction-toggle(@click.stop.prevent="select_category('REAL_ESTATE')" :class="{'disabled': !category_has_buildings('REAL_ESTATE')}")
              misc-industry-category-icon(category='REAL_ESTATE')
              span.toggle-label {{text_for_category('REAL_ESTATE')}}
              .disabled-overlay

  #no-company-modal.modal-background(v-show='has_no_company')
    .content
      span {{$translate('ui.menu.construction.company_required.label')}}
      a(@click.stop.prevent='toggle_form_company_menu') {{$translate('ui.menu.construction.company_required.action')}}

</template>

<script lang='ts'>
import _ from 'lodash';
import ClientState from '~/plugins/starpeace-client/state/client-state.coffee';

export default {
  props: {
    client_state: { type: ClientState, required: true }
  },

  computed: {
    is_ready (): boolean { return this.client_state?.workflow_status === 'ready'; },
    is_visible (): boolean { return this.is_ready && (this.client_state?.menu?.is_visible('construction') ?? false); },

    is_tycoon () { return this.is_ready && this.client_state?.is_tycoon(); },
    company_id () { return this.is_tycoon ? this.client_state.player.company_id : null; },
    company_seal_id () { return this.company_id ? this.client_state.seal_for_company_id(this.company_id) : null; },
    company_seal_name () { return this.company_seal_id ? this.$translate(this.client_state.core.planet_library.seal_for_id(this.company_seal_id)?.name_short) : null; },

    has_no_company () { return this.is_ready && this.is_tycoon && !this.client_state.player.company_id; },

    root_breadcrumb_class () { return this.selected_menu_industry_category_id ? '' : 'is-active'; },

    has_selected_menu_category () { return this.selected_menu_industry_category_id?.length > 0; },
    selected_menu_industry_category_id () { return this.client_state.interface.construction_selected_category_id; },
    selected_building_id () { return this.client_state.interface.construction_selected_building_id; },

    buildings_for_company_by_category () {
      const definitions = this.company_seal_id ? this.client_state.core.building_library.definitions_for_seal(this.company_seal_id) : _.values(this.client_state.core.building_library.metadata_by_id);
      return _.groupBy(_.filter(definitions || [], (info) => !info.restricted), (info) => info.industry_category_id);
    }
  },

  watch: {
    company_id (new_value, old_value) {
      this.client_state.interface.construction_selected_category_id = null;
      this.client_state.interface.construction_building_id = null;
    }
  },

  mounted () {
    this.client_state.corporation.subscribe_company_inventions_listener(() => {
      if (this.is_visible) {
        this.$forceUpdate()
      }
    });
    this.client_state?.options?.subscribe_options_listener(() => {
      if (this.is_visible) {
        this.$forceUpdate()
      }
    });
  },

  methods: {
    toggle_form_company_menu (): void { this.client_state.menu.toggle_menu('company_form'); },

    building_cost (definition_id: string): number { return this.$starpeaceClient.managers?.building_manager?.cost_for_building_definition_id(definition_id) ?? 0; },
    sort_buildings (buildings: Array<any>): Array<any> { return _.sortBy(buildings, (info) => `${info.industry_type}-${_.padStart(this.building_cost(info.id), 12, '0')}`); },

    separator_label_for_index (index: number, length: number): string {
      return length > 2 ? (index == length - 2 ? ', and ' : ', ') : ' and ';
    },

    category_has_buildings (category_id: string) { return this.buildings_for_company_by_category[category_id]?.length > 0; },
    text_for_category (category_id: string) { return category_id ? this.$starpeaceClient.managers.translation_manager.text(this.client_state.core.planet_library.category_for_id(category_id)?.label) : category_id; },

    can_construct_building (building_info) { return this.client_state.has_construction_requirements(building_info.id); },

    building_name (building_info) { return this.$starpeaceClient.managers.translation_manager.text(building_info.name); },
    building_description (building_info) { return this.$starpeaceClient.managers.translation_manager.description_for_building(building_info); },

    building_size (building_info) {
      const building_definition = this.client_state.core.building_library.metadata_by_id[building_info.id];
      if (!building_definition) return 0;
      const building_image = this.client_state.core.building_library.images_by_id[building_definition.image_id];
      if (!building_image) return 0;
      return (building_image.w * 20) * (building_image.h * 20);
    },

    invention_name (id: string): string {
      const metadata = this.client_state.core.invention_library.metadata_for_id(id);
      return metadata ? this.$starpeaceClient.managers.translation_manager.text(metadata.name) : id;
    },

    is_invention_completed (id: string): boolean {
      return this.company_id && this.client_state.corporation.completed_invention_ids_for_company(this.company_id).indexOf(id) >= 0;
    },


    select_root_breadcrumb (): void {
      if (!this.selected_menu_industry_category_id) return;
      this.client_state.interface.construction_selected_category_id = null;
      if (this.selected_building_id && this.$refs.previewContainer && this.$refs.pendingContainer) {
        this.client_state.interface.construction_selected_building_id = null;
        this.$refs.previewContainer.parentElement.removeChild(this.$refs.previewContainer);
        this.$refs.pendingContainer.appendChild(this.$refs.previewContainer);
      }
    },

    select_category (category: string): void {
      if (!this.category_has_buildings(category)) return;
      this.client_state.interface.construction_selected_category_id = category;
    },

    toggle_building (info): void {
      if (!this.$refs.previewContainer || !this.$refs.pendingContainer) return;
      this.$refs.previewContainer.parentElement.removeChild(this.$refs.previewContainer);
      if (this.selected_building_id == info.id) {
        this.client_state.interface.construction_selected_building_id = null;
        this.$refs.pendingContainer.appendChild(this.$refs.previewContainer);
      }
      else {
        this.client_state.interface.construction_selected_building_id = info.id;
        const preview_container: any = this.$refs[`previewItem.${info.id}`];
        if (preview_container) {
          if (Array.isArray(preview_container)) {
            preview_container[0].appendChild(this.$refs.previewContainer);
          }
          else {
            preview_container.appendChild(this.$refs.previewContainer);
          }
        }
      }
    },

    select_building (info) {
      if (!this.can_construct_building(info)) return;
      this.client_state.initiate_building_construction(info.id);
    },

    select_invention (id: string) {
      this.client_state.interface.inventions_selected_invention_id = id;
      this.client_state.menu.toggle_menu('research');
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

#construction-container
  grid-column: start-right / end-right
  grid-row: start-render / end-inspect
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
    font-weight: normal

    &.disabled
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

    .research-pending
      font-weight: bold

    .construct-button
      letter-spacing: .05rem
      margin-top: .5rem
      text-transform: uppercase

  .construction-toggle
    border: 1px solid lighten($sp-primary-bg, 5%)
    display: inline-block
    padding: 1rem .5rem
    position: relative
    text-align: center

    &:not(.disabled)
      &:hover
        background-color: lighten($sp-primary-bg, 2.5%)

      &:active
        background-color: lighten($sp-primary-bg, 7.5%)

    :deep(img)
      filter: invert(75%) sepia(8%) saturate(1308%) hue-rotate(111deg) brightness(93%) contrast(83%)
      width: 50%

    .toggle-label
      display: block
      font-size: 1.1rem
      margin-top: .5rem

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

    &.disabled
      .disabled-overlay
        display: block

#no-company-modal
  align-items: center
  display: flex
  justify-content: center
  padding: 1rem
  text-align: center
  top: 3.4rem
  z-index: 1000

  .content
    color: $sp-primary
    font-size: 1.5rem
    font-style: italic

  a
    font-weight: bold
    color: $sp-primary
    margin-left: .4rem

    &:not(.disabled)
      &:hover,
      &.is-hover
        color: $sp-light

      &:active,
      &.is-active
        color: #fff


</style>
