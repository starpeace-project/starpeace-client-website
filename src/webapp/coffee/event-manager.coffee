
EVENT_CHANGE_SPEED = 30000

window.starpeace ||= {}
window.starpeace.EventManager = class EventManager

  constructor: (@client) ->
    @static_news_index = -1

    @update_loop = setInterval((=> @update_message()), EVENT_CHANGE_SPEED)

  update_message: () ->
    static_news = @client.asset_manager?.static_news || []
    return unless static_news.length && @client.renderer.initialized

    @static_news_index = Math.floor(Math.random() * static_news.length) if @static_news_index < 0
    @client.ui_state.event_ticker_message = static_news[@static_news_index]

    @static_news_index += 1
    @static_news_index = 0 if @static_news_index >= static_news.length
