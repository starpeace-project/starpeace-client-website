
EVENT_CHANGE_SPEED = 30000

class EventManager
  constructor: (@client) ->
    @requested_static_news = false
    @static_news_index = -1
    @static_news = []

    @update_loop = setInterval((=> @update_message()), EVENT_CHANGE_SPEED)

  has_assets: () ->
    @static_news.length

  queue_asset_load: () ->
    return if @requested_static_news
    @requested_static_news = true
    @client.asset_manager.queue('news.static.en', './news.static.en.json', (resource) =>
      @static_news = _.shuffle(resource.data)
    )


  update_message: () ->
    static_news = @client.asset_manager?.static_news || []
    return unless static_news.length && @client.renderer.initialized

    @static_news_index = Math.floor(Math.random() * static_news.length) if @static_news_index < 0
    @client.ui_state.event_ticker_message = static_news[@static_news_index]

    @static_news_index += 1
    @static_news_index = 0 if @static_news_index >= static_news.length

export default EventManager
