import _ from 'lodash';

export default class TreeMenuUtils
  constructor: (@planets_manager, @translation_manager, @ajax_state, @client_state) ->

  organize_buildings: (root_id, buildings) ->
    category_type_buildings = {}
    for building in (buildings || [])
      definition = @client_state.core.building_library.metadata_by_id[building?.definition_id]
      industry_category = @client_state.core.planet_library.category_for_id(definition?.industryCategoryId)
      industry_type = @client_state.core.planet_library.type_for_id(definition?.industryTypeId)
      continue unless definition? && industry_category? && industry_type?

      category_type_buildings[definition.industryCategoryId] = {} unless category_type_buildings[definition.industryCategoryId]?
      category_type_buildings[definition.industryCategoryId][definition.industryTypeId] = {} unless category_type_buildings[definition.industryCategoryId][definition.industryTypeId]?
      category_type_buildings[definition.industryCategoryId][definition.industryTypeId][building.id] = building

    industry_category_label = (id) => @translation_manager.text(@client_state.core.planet_library.category_for_id(id).label) || id
    industry_type_label = (id) => @translation_manager.text(@client_state.core.planet_library.type_for_id(id).label) || id

    _.map(_.orderBy(Object.keys(category_type_buildings), [industry_category_label], ['asc']), (category_id) => {
        id: "#{root_id}-#{category_id}"
        label: industry_category_label(category_id)
        type: 'INDUSTRY_CATEGORY'
        industryCategoryId: category_id
        children: _.map(_.orderBy(Object.keys(category_type_buildings[category_id]), [industry_type_label], ['asc']), (type_id) => {
          id: "#{category_id}-#{type_id}"
          label: industry_type_label(type_id)
          type: 'INDUSTRY_TYPE'
          industryTypeId: type_id
          children: _.map(_.orderBy(_.values(category_type_buildings[category_id][type_id]), ['name'], ['asc']), (building) => {
            id: building.id
            label: building.name
            type: 'MAP_LOCATION'
            building_id: building.id
            map_x: building.map_x
            map_y: building.map_y
            action: () => @client_state.jump_to(building.map_x, building.map_y, building.id)
          })
        })
    })

  organize_building_definitions: (planet_id, town_id, building_definitions) ->
    category_types = {}
    for definition in building_definitions
      industry_category = @client_state.core.planet_library.category_for_id(definition?.industryCategoryId)
      industry_type = @client_state.core.planet_library.type_for_id(definition?.industryTypeId)
      continue unless definition? && industry_category? && industry_type?

      category_types[definition.industryCategoryId] = {} unless category_types[definition.industryCategoryId]?
      category_types[definition.industryCategoryId][definition.industryTypeId] = true

    industry_category_label = (id) => @translation_manager.text(@client_state.core.planet_library.category_for_id(id).label) || id
    industry_type_label = (id) => @translation_manager.text(@client_state.core.planet_library.type_for_id(id).label) || id

    _.map(_.orderBy(Object.keys(category_types), [industry_category_label], ['asc']), (category_id) => {
        id: "#{town_id}-#{category_id}"
        label: industry_category_label(category_id)
        type: 'INDUSTRY_CATEGORY'
        industryCategoryId: category_id
        children: _.map(_.orderBy(Object.keys(category_types[category_id]), [industry_type_label], ['asc']), (type_id) => {
          id: "#{category_id}-#{type_id}"
          label: industry_type_label(type_id)
          type: 'INDUSTRY_TYPE'
          industryTypeId: type_id
          load_children_callback: () => @planets_manager.buildings_by_town(town_id, category_id, type_id)
          convert_children_callback: (buildings) => _.map(_.orderBy(buildings, ['name'], ['asc']), (building) => {
            id: building.id
            label: building.name
            type: 'MAP_LOCATION'
            building_id: building.id
            map_x: building.map_x
            map_y: building.map_y
            action: () => @client_state.jump_to(building.map_x, building.map_y, building.id)
          })
        })
    })
