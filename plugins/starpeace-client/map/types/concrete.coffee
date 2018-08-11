
export default class Concrete
  @TYPES:
    CENTER:
      type: 'CENTER'
      priority: 1
      texture_id: 'concrete.c.solid'
      is_flat: true
    CENTER_ROAD:
      type: 'CENTER_ROAD'
      priority: 1
      texture_id: 'concrete.c.solid'
      is_flat: true
    PLATFORM_CENTER:
      type: 'PLATFORM_CENTER'
      priority: 1
      texture_id: 'platform.c'
      is_flat: true
      is_platform: true
    CENTER_TREEABLE:
      type: 'CENTER_TREEABLE'
      priority: 2
      texture_id: 'concrete.c.plant'
    BUFFER:
      type: 'BUFFER'
      priority: 3
      texture_id: null
    BUFFER_ROAD:
      type: 'BUFFER_ROAD'
      priority: 3
      texture_id: null
    PLATFORM_EDGE_N:
      type: 'PLATFORM_EDGE_N'
      priority: 4
      texture_id: 'platform.e'
      is_platform: true
    PLATFORM_EDGE_NE:
      type: 'PLATFORM_EDGE_NE'
      priority: 4
      texture_id: 'platform.se'
      is_platform: true
    PLATFORM_EDGE_E:
      type: 'PLATFORM_EDGE_E'
      priority: 4
      texture_id: 'platform.n'
      is_platform: true
    PLATFORM_EDGE_SE:
      type: 'PLATFORM_EDGE_SE'
      priority: 4
      texture_id: 'platform.sw'
      is_platform: true
    PLATFORM_EDGE_S:
      type: 'EDGE_S'
      priority: 4
      texture_id: 'platform.w'
      is_platform: true
    PLATFORM_EDGE_SW:
      type: 'PLATFORM_EDGE_SW'
      priority: 4
      texture_id: 'platform.nw'
      is_platform: true
    PLATFORM_EDGE_W:
      type: 'PLATFORM_EDGE_W'
      priority: 4
      texture_id: 'platform.s'
      is_platform: true
    PLATFORM_EDGE_NW:
      type: 'PLATFORM_EDGE_NW'
      priority: 4
      texture_id: 'platform.ne'
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
    EDGE_NE_OUTER_N:
      type: 'EDGE_NE_OUTER_N'
      priority: 4
      texture_id: 'concrete.ne.outer.n'
    EDGE_NE_OUTER_W:
      type: 'EDGE_NE_OUTER_W'
      priority: 4
      texture_id: 'concrete.ne.outer.w'
    EDGE_NE_INNER:
      type: 'EDGE_NE_INNER'
      priority: 4
      texture_id: 'concrete.ne.inner'
    EDGE_E:
      type: 'EDGE_E'
      priority: 4
      texture_id: 'concrete.e'
    EDGE_SE_OUTER:
      type: 'EDGE_SE_OUTER'
      priority: 4
      texture_id: 'concrete.se.outer'
    EDGE_SE_OUTER_E:
      type: 'EDGE_SE_OUTER_E'
      priority: 4
      texture_id: 'concrete.se.outer.e'
    EDGE_SE_OUTER_N:
      type: 'EDGE_SE_OUTER_N'
      priority: 4
      texture_id: 'concrete.se.outer.n'
    EDGE_SE_INNER:
      type: 'EDGE_SE_INNER'
      priority: 4
      texture_id: 'concrete.se.inner'
    EDGE_S:
      type: 'EDGE_S'
      priority: 4
      texture_id: 'concrete.s'
    EDGE_SW_OUTER:
      type: 'EDGE_SW_OUTER'
      priority: 4
      texture_id: 'concrete.sw.outer'
    EDGE_SW_OUTER_E:
      type: 'EDGE_SW_OUTER_E'
      priority: 4
      texture_id: 'concrete.sw.outer.e'
    EDGE_SW_OUTER_S:
      type: 'EDGE_SW_OUTER_S'
      priority: 4
      texture_id: 'concrete.sw.outer.s'
    EDGE_SW_INNER:
      type: 'EDGE_SW_INNER'
      priority: 4
      texture_id: 'concrete.sw.inner'
    EDGE_W:
      type: 'EDGE_W'
      priority: 4
      texture_id: 'concrete.w'
    EDGE_NW_OUTER:
      type: 'EDGE_NW_OUTER'
      priority: 4
      texture_id: 'concrete.nw.outer'
    EDGE_NW_OUTER_W:
      type: 'EDGE_NW_OUTER_W'
      priority: 4
      texture_id: 'concrete.nw.outer.w'
    EDGE_NW_OUTER_S:
      type: 'EDGE_NW_OUTER_S'
      priority: 4
      texture_id: 'concrete.nw.outer.s'
    EDGE_NW_INNER:
      type: 'EDGE_NW_INNER'
      priority: 4
      texture_id: 'concrete.nw.inner'
