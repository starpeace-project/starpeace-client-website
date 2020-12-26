

export default class Road
  @TYPES:
    LIGHTS:
      type: 'LIGHTS'
      city_texture_id: 'road.city.lights'
      country_texture_id: null

    CROSS:
      type: 'CROSS'
      city_texture_id: 'road.city.cross'
      country_texture_id: 'road.country.cross'

    T_EW_N:
      type: 'T_EW_N'
      city_texture_id: 'road.city.t.ew.n'
      country_texture_id: 'road.country.t.ew.n'
    T_EW_S:
      type: 'T_EW_S'
      city_texture_id: 'road.city.t.ew.s'
      country_texture_id: 'road.country.t.ew.s'
    T_NS_E:
      type: 'T_NS_E'
      city_texture_id: 'road.city.t.ns.e'
      country_texture_id: 'road.country.t.ns.e'
    T_NS_W:
      type: 'T_NS_W'
      city_texture_id: 'road.city.t.ns.w'
      country_texture_id: 'road.country.t.ns.w'

    EW:
      type: 'EW'
      city_texture_id: 'road.city.ew'
      country_texture_id: 'road.country.ew'
    EW_END_E:
      type: 'EW_END_E'
      city_texture_id: 'road.city.ew.e'
      country_texture_id: 'road.country.ew.e'
    EW_END_W:
      type: 'EW_END_W'
      city_texture_id: 'road.city.ew.w'
      country_texture_id: 'road.country.ew.w'

    NS:
      type: 'NS'
      city_texture_id: 'road.city.ns'
      country_texture_id: 'road.country.ns'
    NS_END_N:
      type: 'NS_END_N'
      city_texture_id: 'road.city.ns.n'
      country_texture_id: 'road.country.ns.n'
    NS_END_S:
      type: 'NS_END_S'
      city_texture_id: 'road.city.ns.s'
      country_texture_id: 'road.country.ns.s'

    NE_CORNER:
      type: 'NE_CORNER'
      city_texture_id: 'road.city.corner.ne'
      country_texture_id: 'road.country.corner.ne'
    NW_CORNER:
      type: 'NW_CORNER'
      city_texture_id: 'road.city.corner.nw'
      country_texture_id: 'road.country.corner.nw'
    SE_CORNER:
      type: 'SE_CORNER'
      city_texture_id: 'road.city.corner.se'
      country_texture_id: 'road.country.corner.se'
    SW_CORNER:
      type: 'SW_CORNER'
      city_texture_id: 'road.city.corner.sw'
      country_texture_id: 'road.country.corner.sw'

    NESW_NW:
      type: 'NESW_NW'
      city_texture_id: 'road.city.nesw.nw'
      country_texture_id: 'road.country.nesw.nw'
    NESW_SE:
      type: 'NESW_SE'
      city_texture_id: 'road.city.nesw.se'
      country_texture_id: 'road.country.nesw.se'
    NWSE_NE:
      type: 'NWSE_NE'
      city_texture_id: 'road.city.nwse.ne'
      country_texture_id: 'road.country.nwse.ne'
    NWSE_SW:
      type: 'NWSE_SW'
      city_texture_id: 'road.city.nwse.sw'
      country_texture_id: 'road.country.nwse.sw'

    CITY_N_COUNTRY_S:
      type: 'CITY_N_COUNTRY_S'
      city_texture_id: 'road.city.n.country.s'
      country_texture_id: 'road.city.n.country.s'
    CITY_S_COUNTRY_N:
      type: 'CITY_S_COUNTRY_N'
      city_texture_id: 'road.city.s.country.n'
      country_texture_id: 'road.city.s.country.n'
    CITY_E_COUNTRY_W:
      type: 'CITY_E_COUNTRY_W'
      city_texture_id: 'road.city.e.country.w'
      country_texture_id: 'road.city.e.country.w'
    CITY_W_COUNTRY_E:
      type: 'CITY_W_COUNTRY_E'
      city_texture_id: 'road.city.w.country.e'
      country_texture_id: 'road.city.w.country.e'

    BRIDGE_EW:
      type: 'BRIDGE_EW'
      city_texture_id: 'bridge.ew'
      country_texture_id: 'bridge.ew'
      is_bridge: true
    BRIDGE_NS:
      type: 'BRIDGE_NS'
      city_texture_id: 'bridge.ns'
      country_texture_id: 'bridge.ns'
      is_bridge: true
    BRIDGE_E_RAMP:
      type: 'BRIDGE_E_RAMP'
      city_texture_id: 'bridge.ramp.e'
      country_texture_id: 'bridge.ramp.e'
      is_bridge: true
    BRIDGE_N_RAMP:
      type: 'BRIDGE_N_RAMP'
      city_texture_id: 'bridge.ramp.n'
      country_texture_id: 'bridge.ramp.n'
      is_bridge: true
    BRIDGE_S_RAMP:
      type: 'BRIDGE_S_RAMP'
      city_texture_id: 'bridge.ramp.s'
      country_texture_id: 'bridge.ramp.s'
      is_bridge: true
    BRIDGE_W_RAMP:
      type: 'BRIDGE_W_RAMP'
      city_texture_id: 'bridge.ramp.w'
      country_texture_id: 'bridge.ramp.w'
      is_bridge: true

  @connects_east: (type) ->
    type == Road.TYPES.CROSS || type == Road.TYPES.EW || type == Road.TYPES.EW_END_W || type == Road.TYPES.T_EW_N || type == Road.TYPES.T_EW_S || type == Road.TYPES.T_NS_W || type == Road.TYPES.NE_CORNER || type == Road.TYPES.SE_CORNER
  @connects_west: (type) ->
    type == Road.TYPES.CROSS || type == Road.TYPES.EW || type == Road.TYPES.EW_END_E || type == Road.TYPES.T_EW_N || type == Road.TYPES.T_EW_S || type == Road.TYPES.T_NS_E || type == Road.TYPES.NW_CORNER || type == Road.TYPES.SW_CORNER
  @connects_north: (type) ->
    type == Road.TYPES.CROSS || type == Road.TYPES.NS || type == Road.TYPES.NS_END_S || type == Road.TYPES.T_NS_E || type == Road.TYPES.T_NS_W || type == Road.TYPES.T_EW_S || type == Road.TYPES.NE_CORNER || type == Road.TYPES.NW_CORNER
  @connects_south: (type) ->
    type == Road.TYPES.CROSS || type == Road.TYPES.NS || type == Road.TYPES.NS_END_N || type == Road.TYPES.T_NS_E || type == Road.TYPES.T_NS_W || type == Road.TYPES.T_EW_N || type == Road.TYPES.SE_CORNER || type == Road.TYPES.SW_CORNER
