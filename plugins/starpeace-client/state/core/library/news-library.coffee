import Library from '~/plugins/starpeace-client/state/core/library/library.coffee'
import Logger from '~/plugins/starpeace-client/logger'

export default class NewsLibrary extends Library
  constructor: () ->
    super()

    @static_news = {}

  has_metadata: (language) -> (@static_news[language] || []).length > 0

  load_static_news: (language, static_news) ->
    @static_news[language] = static_news
    @notify_listeners()
