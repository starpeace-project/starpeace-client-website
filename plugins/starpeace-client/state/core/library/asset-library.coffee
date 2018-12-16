
import EventListener from '~/plugins/starpeace-client/state/event-listener.coffee'

export default class AssetLibrary
  constructor: () ->
    @event_listener = new EventListener()

  subscribe_listener: (listener_callback) -> @event_listener.subscribe('core.library.assets', listener_callback)
  notify_listeners: () -> @event_listener.notify_listeners('core.library.assets')
