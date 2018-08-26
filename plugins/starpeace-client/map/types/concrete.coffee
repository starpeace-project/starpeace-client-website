
export default class Concrete
  @FILL_TYPE:
    NO_FILL:
      type: 'NO_FILL'
    FILLED:
      type: 'FILLED'
    EDGE:
      type: 'EDGE'

  @TYPES:
    CENTER:
      type: 'CENTER'
      texture_id: 'concrete.c.solid'
      is_flat: true
    CENTER_TREEABLE:
      type: 'CENTER_TREEABLE'
      texture_id: 'concrete.c.plant'

    EDGE_N:
      type: 'EDGE_N'
      texture_id: 'concrete.n'
      water_texture_id: 'platform.n'
    EDGE_N_FLAT:
      type: 'EDGE_N_FLAT'
      texture_id: 'concrete.n.flat'
      is_flat: true
    EDGE_NE_OUTER:
      type: 'EDGE_NE_OUTER'
      texture_id: 'concrete.ne.outer'
    EDGE_NE_INNER:
      type: 'EDGE_NE_INNER'
      texture_id: 'concrete.ne.inner'

    EDGE_E:
      type: 'EDGE_E'
      texture_id: 'concrete.e'
    EDGE_E_FLAT:
      type: 'EDGE_E_FLAT'
      texture_id: 'concrete.e.flat'
      is_flat: true
    EDGE_SE_OUTER:
      type: 'EDGE_SE_OUTER'
      texture_id: 'concrete.se.outer'
    EDGE_SE_INNER:
      type: 'EDGE_SE_INNER'
      texture_id: 'concrete.se.inner'

    EDGE_S:
      type: 'EDGE_S'
      texture_id: 'concrete.s'
    EDGE_S_FLAT:
      type: 'EDGE_S_FLAT'
      texture_id: 'concrete.s.flat'
      is_flat: true
    EDGE_SW_OUTER:
      type: 'EDGE_SW_OUTER'
      texture_id: 'concrete.sw.outer'
    EDGE_SW_INNER:
      type: 'EDGE_SW_INNER'
      texture_id: 'concrete.sw.inner'

    EDGE_W:
      type: 'EDGE_W'
      texture_id: 'concrete.w'
    EDGE_W_FLAT:
      type: 'EDGE_W_FLAT'
      texture_id: 'concrete.w.flat'
      is_flat: true
    EDGE_NW_OUTER:
      type: 'EDGE_NW_OUTER'
      texture_id: 'concrete.nw.outer'
    EDGE_NW_INNER:
      type: 'EDGE_NW_INNER'
      texture_id: 'concrete.nw.inner'

    EDGE_NE_OUTER_N:
      type: 'EDGE_NE_OUTER_N'
      texture_id: 'concrete.ne.outer.n'
    EDGE_NE_OUTER_W:
      type: 'EDGE_NE_OUTER_W'
      texture_id: 'concrete.ne.outer.w'
    EDGE_SE_OUTER_E:
      type: 'EDGE_SE_OUTER_E'
      texture_id: 'concrete.se.outer.e'
    EDGE_SE_OUTER_N:
      type: 'EDGE_SE_OUTER_N'
      texture_id: 'concrete.se.outer.n'
    EDGE_SW_OUTER_E:
      type: 'EDGE_SW_OUTER_E'
      texture_id: 'concrete.sw.outer.e'
    EDGE_SW_OUTER_S:
      type: 'EDGE_SW_OUTER_S'
      texture_id: 'concrete.sw.outer.s'
    EDGE_NW_OUTER_W:
      type: 'EDGE_NW_OUTER_W'
      texture_id: 'concrete.nw.outer.w'
    EDGE_NW_OUTER_S:
      type: 'EDGE_NW_OUTER_S'
      texture_id: 'concrete.nw.outer.s'

    PLATFORM_CENTER:
      type: 'PLATFORM_CENTER'
      texture_id: 'platform.c'
      is_platform: true
      is_flat: true
    PLATFORM_EDGE_N:
      type: 'PLATFORM_EDGE_N'
      texture_id: 'platform.e'
      is_platform: true
    PLATFORM_EDGE_NE:
      type: 'PLATFORM_EDGE_NE'
      texture_id: 'platform.se'
      is_platform: true
    PLATFORM_EDGE_E:
      type: 'PLATFORM_EDGE_E'
      texture_id: 'platform.n'
      is_platform: true
    PLATFORM_EDGE_SE:
      type: 'PLATFORM_EDGE_SE'
      texture_id: 'platform.sw'
      is_platform: true
    PLATFORM_EDGE_S:
      type: 'EDGE_S'
      texture_id: 'platform.w'
      is_platform: true
    PLATFORM_EDGE_SW:
      type: 'PLATFORM_EDGE_SW'
      texture_id: 'platform.nw'
      is_platform: true
    PLATFORM_EDGE_W:
      type: 'PLATFORM_EDGE_W'
      texture_id: 'platform.s'
      is_platform: true
    PLATFORM_EDGE_NW:
      type: 'PLATFORM_EDGE_NW'
      texture_id: 'platform.ne'
      is_platform: true
