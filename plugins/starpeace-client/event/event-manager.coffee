
EVENT_CHANGE_SPEED = 30000

export default class EventManager
  constructor: (@asset_manager, @ajax_state, @client_state) ->


  initialize: () ->
    clearTimeout(@update_loop) if @update_loop?

    @update_message()
    @update_loop = setInterval((=> @update_message()), EVENT_CHANGE_SPEED)


  queue_asset_load: () ->
    return if @client_state.core.news_library.has_metadata() || @ajax_state.is_locked('assets.static_news', 'en')

    @ajax_state.lock('assets.static_news', 'en')
    @asset_manager.queue('news.static.en', './news.static.en.json', (resource) =>
      # FIXME: TODO: convert json to object
      @client_state.core.news_library.load_static_news(resource.data)
      @ajax_state.unlock('assets.static_news', 'en')
    )


  update_message: () ->
    return unless @client_state.core.news_library.has_metadata() && @client_state.workflow_status == 'ready'

    static_news = @client_state.core.news_library.static_news

    @client_state.interface.static_news_index = Math.floor(Math.random() * static_news.length) if @client_state.interface.static_news_index < 0
    @client_state.interface.event_ticker_message = static_news[@client_state.interface.static_news_index]

    @client_state.interface.static_news_index += 1
    @client_state.interface.static_news_index = 0 if @client_state.interface.static_news_index >= static_news.length
