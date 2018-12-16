
import AssetLibrary from '~/plugins/starpeace-client/state/core/library/asset-library.coffee'
import Logger from '~/plugins/starpeace-client/logger.coffee'

export default class NewsLibrary extends AssetLibrary
  constructor: () ->
    super()

    @static_news = []

  has_metadata: () -> @static_news.length > 0

  load_static_news: (static_news) ->
    @static_news = static_news
    @notify_listeners()
