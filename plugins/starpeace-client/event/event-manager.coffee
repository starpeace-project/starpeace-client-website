import _ from 'lodash';

EVENT_CHANGE_SPEED = 30000

export default class EventManager
  constructor: (@asset_manager, @ajax_state, @client_state) ->

  initialize: () ->
    clearTimeout(@update_loop) if @update_loop?

    @update_message()
    @update_loop = setInterval(=>
      @update_message() if @client_state.workflow_status == 'ready'
    , EVENT_CHANGE_SPEED)

  queue_asset_load: (completion_callback=null) ->
    current_language = @client_state.options.language()
    return if @client_state.core.news_library.has_metadata(current_language) || @ajax_state.is_locked('assets.static_news', current_language)

    @ajax_state.lock('assets.static_news', current_language)
    @asset_manager.queue("news.static.#{current_language.toLowerCase()}", "./news.static.#{current_language.toLowerCase()}.json", (resource) =>
      # FIXME: TODO: convert json to object
      @client_state.core.news_library.load_static_news(current_language, resource)
      @ajax_state.unlock('assets.static_news', current_language)
      completion_callback() if completion_callback? && _.isFunction(completion_callback)
    )

  update_message: () ->
    language = @client_state.options.language()
    return unless @client_state.core.news_library.has_metadata(language)
    static_news = @client_state.core.news_library.static_news[language]

    @client_state.interface.static_news_index = Math.floor(Math.random() * static_news.length) if @client_state.interface.static_news_index < 0
    @client_state.interface.event_ticker_message = static_news[@client_state.interface.static_news_index]

    @client_state.interface.static_news_index += 1
    @client_state.interface.static_news_index = 0 if @client_state.interface.static_news_index >= static_news.length
