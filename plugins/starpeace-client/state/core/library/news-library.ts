import Library from '~/plugins/starpeace-client/state/core/library/library'

export default class NewsLibrary extends Library {
  static_news: Record<string, Array<string>> = {};

  constructor () {
    super();
  }

  has_metadata (language: string): boolean {
    return (this.static_news[language] ?? []).length > 0;
  }

  load_static_news (language: string, static_news: Array<string>): void {
    this.static_news[language] = static_news;
    this.notify_listeners();
  }
}
