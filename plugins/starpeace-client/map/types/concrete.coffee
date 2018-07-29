
export default class Concrete
  @TYPES:
    CENTER:
      type: 'CENTER'
      priority: 1
      texture_id: 'concrete.c.solid'
      use_building_layer: false
    CENTER_ROAD:
      type: 'CENTER_ROAD'
      priority: 1
      texture_id: 'concrete.c.solid'
      use_building_layer: false
    PLATFORM_CENTER:
      type: 'PLATFORM_CENTER'
      priority: 1
      texture_id: 'platform.c'
      use_building_layer: false
      is_platform: true
    CENTER_TREEABLE:
      type: 'CENTER_TREEABLE'
      priority: 2
      texture_id: 'concrete.c.plant'
      use_building_layer: true
    BUFFER:
      type: 'BUFFER'
      priority: 3
      texture_id: null
      use_building_layer: false
    BUFFER_ROAD:
      type: 'BUFFER_ROAD'
      priority: 3
      texture_id: null
      use_building_layer: false
    PLATFORM_EDGE_N:
      type: 'PLATFORM_EDGE_N'
      priority: 4
      texture_id: 'platform.e'
      use_building_layer: false
      is_platform: true
    PLATFORM_EDGE_NE:
      type: 'PLATFORM_EDGE_NE'
      priority: 4
      texture_id: 'platform.se'
      use_building_layer: false
      is_platform: true
    PLATFORM_EDGE_E:
      type: 'PLATFORM_EDGE_E'
      priority: 4
      texture_id: 'platform.n'
      use_building_layer: false
      is_platform: true
    PLATFORM_EDGE_SE:
      type: 'PLATFORM_EDGE_SE'
      priority: 4
      texture_id: 'platform.sw'
      use_building_layer: false
      is_platform: true
    PLATFORM_EDGE_S:
      type: 'EDGE_S'
      priority: 4
      texture_id: 'platform.w'
      use_building_layer: false
      is_platform: true
    PLATFORM_EDGE_SW:
      type: 'PLATFORM_EDGE_SW'
      priority: 4
      texture_id: 'platform.nw'
      use_building_layer: false
      is_platform: true
    PLATFORM_EDGE_W:
      type: 'PLATFORM_EDGE_W'
      priority: 4
      texture_id: 'platform.s'
      use_building_layer: false
      is_platform: true
    PLATFORM_EDGE_NW:
      type: 'PLATFORM_EDGE_NW'
      priority: 4
      texture_id: 'platform.ne'
      use_building_layer: false
      is_platform: true
    EDGE_N:
      type: 'EDGE_N'
      priority: 4
      texture_id: 'concrete.n'
      water_texture_id: 'platform.n'
    EDGE_NE_OUTER:
      type: 'EDGE_NE_OUTER'
      priority: 4
      texture_id: 'concrete.ne.outer'
      use_building_layer: false
    EDGE_NE_INNER:
      type: 'EDGE_NE_INNER'
      priority: 4
      texture_id: 'concrete.ne.inner'
      use_building_layer: false
    EDGE_E:
      type: 'EDGE_E'
      priority: 4
      texture_id: 'concrete.e'
      use_building_layer: false
    EDGE_SE_OUTER:
      type: 'EDGE_SE_OUTER'
      priority: 4
      texture_id: 'concrete.se.outer'
      use_building_layer: false
    EDGE_SE_INNER:
      type: 'EDGE_SE_INNER'
      priority: 4
      texture_id: 'concrete.se.inner'
      use_building_layer: false
    EDGE_S:
      type: 'EDGE_S'
      priority: 4
      texture_id: 'concrete.s'
      use_building_layer: false
    EDGE_SW_OUTER:
      type: 'EDGE_SW_OUTER'
      priority: 4
      texture_id: 'concrete.sw.outer'
      use_building_layer: false
    EDGE_SW_INNER:
      type: 'EDGE_SW_INNER'
      priority: 4
      texture_id: 'concrete.sw.inner'
      use_building_layer: false
    EDGE_W:
      type: 'EDGE_W'
      priority: 4
      texture_id: 'concrete.w'
      use_building_layer: false
    EDGE_NW_OUTER:
      type: 'EDGE_NW_OUTER'
      priority: 4
      texture_id: 'concrete.nw.outer'
      use_building_layer: false
    EDGE_NW_INNER:
      type: 'EDGE_NW_INNER'
      priority: 4
      texture_id: 'concrete.nw.inner'
      use_building_layer: false
