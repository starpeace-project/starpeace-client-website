
export default class EventListener
  constructor: () ->
    @listeners = {
      session: []
      system: []
      planet: []
      planet_details: []
      corporation: []
      corporation_metadata: []
      bookmarks_metadata: []
      mail_metadata: []
      company_metadata: []
      asset: []
      map_data: []
      viewport: []
    }

  subscribe: (type, callback) ->
    throw new "callback must be a method" unless _.isFunction(callback)
    @listeners[type].push callback
  notify_listeners: (type, callback_data=null) ->
    setTimeout(=>
      for listener in @listeners[type]
        do (listener) =>
          setTimeout((=> listener(callback_data)), 0)
    , 500)


  subscribe_session_listener: (listener_callback) -> @subscribe('session', listener_callback)
  notify_session_listeners: () -> @notify_listeners('session')

  subscribe_system_listener: (listener_callback) -> @subscribe('system', listener_callback)
  notify_system_listeners: () -> @notify_listeners('system')

  subscribe_planet_listener: (listener_callback) -> @subscribe('planet', listener_callback)
  notify_planet_listeners: () -> @notify_listeners('planet')

  subscribe_planet_details_listener: (listener_callback) -> @subscribe('planet_details', listener_callback)
  notify_planet_details_listeners: () -> @notify_listeners('planet_details')

  subscribe_corporation_listener: (listener_callback) -> @subscribe('corporation', listener_callback)
  notify_corporation_listeners: () -> @notify_listeners('corporation')

  subscribe_corporation_metadata_listener: (listener_callback) -> @subscribe('corporation_metadata', listener_callback)
  notify_corporation_metadata_listeners: () -> @notify_listeners('corporation_metadata')

  subscribe_bookmarks_metadata_listener: (listener_callback) -> @subscribe('bookmarks_metadata', listener_callback)
  notify_bookmarks_metadata_listeners: () -> @notify_listeners('bookmarks_metadata')

  subscribe_mail_metadata_listener: (listener_callback) -> @subscribe('mail_metadata', listener_callback)
  notify_mail_metadata_listeners: () -> @notify_listeners('mail_metadata')

  subscribe_company_metadata_listener: (listener_callback) -> @subscribe('company_metadata', listener_callback)
  notify_company_metadata_listeners: () -> @notify_listeners('company_metadata')

  subscribe_asset_listener: (listener_callback) -> @subscribe('asset', listener_callback)
  notify_asset_listeners: () -> @notify_listeners('asset')

  subscribe_map_data_listener: (listener_callback) -> @subscribe('map_data', listener_callback)
  notify_map_data_listeners: (chunk_event) -> @notify_listeners('map_data', chunk_event)

  subscribe_viewport_listener: (listener_callback) -> @subscribe('viewport', listener_callback)
  notify_viewport_listeners: (event) -> @notify_listeners('viewport', event)
