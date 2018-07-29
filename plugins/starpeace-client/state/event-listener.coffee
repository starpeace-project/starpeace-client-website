
export default class EventListener
  constructor: () ->
    @planet_listeners = []
    @asset_listeners = []
    @map_data_listeners = []

  subscribe_planet_listener: (listener_callback) ->
    throw new "callback must be a method" unless _.isFunction(listener_callback)
    @planet_listeners.push listener_callback

  notify_planet_listeners: () ->
    setTimeout(=>
      for listener in @planet_listeners
        do (listener) =>
          setTimeout((=> listener()), 0)
    , 500)

  subscribe_asset_listener: (listener_callback) ->
    throw new "callback must be a method" unless _.isFunction(listener_callback)
    @asset_listeners.push listener_callback

  notify_asset_listeners: () ->
    setTimeout(=>
      for listener in @asset_listeners
        do (listener) =>
          setTimeout((=> listener()), 0)
    , 500)

  subscribe_map_data_listener: (listener_callback) ->
    throw new "callback must be a method" unless _.isFunction(listener_callback)
    @map_data_listeners.push listener_callback

  notify_map_data_listeners: (chunk_event) ->
    setTimeout(=>
      for listener in @map_data_listeners
        do (listener) =>
          setTimeout((=> listener(chunk_event)), 0)
    , 50)
