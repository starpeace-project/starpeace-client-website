
export default class EventListener
  constructor: () ->
    @planet_listeners = []
    @asset_listeners = []

  subscribe_planet_listener: (listener_callback) ->
    throw new "callback must be a method" unless _.isFunction(listener_callback)
    @planet_listeners.push listener_callback

  notify_planet_listeners: () ->
    setTimeout((=> setTimeout((=> listener()), 0) for listener in @planet_listeners), 500)

  subscribe_asset_listener: (listener_callback) ->
    throw new "callback must be a method" unless _.isFunction(listener_callback)
    @asset_listeners.push listener_callback

  notify_asset_listeners: () ->
    setTimeout((=> setTimeout((=> listener()), 0) for listener in @asset_listeners), 500)
