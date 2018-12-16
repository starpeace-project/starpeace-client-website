
export default class EventListener
  constructor: () ->
    @listeners = {}

  subscribe: (type, callback) ->
    throw new "callback must be a method" unless _.isFunction(callback)
    @listeners[type] = [] unless @listeners[type]?
    @listeners[type].push callback

  notify_listeners: (type, callback_data=null) ->
    setTimeout(=>
      for listener in (@listeners[type] || [])
        do (listener) =>
          setTimeout((=> listener(callback_data)), 0)
    , 5)
