

window.starpeace ||= {}
window.starpeace.asset ||= {}
window.starpeace.asset.AssetManager = class AssetManager

  constructor: (@client) ->
    @loaded = false

    PIXI.loader.onProgress.add (e) =>
      @loading_progress = e.progress

#     PIXI.loader.add 'ancoeus.texture.map.png', 'https://cdn.starpeace.io/ancoeus.texture.map.png'
    PIXI.loader.load (loader, resources) =>
      @loaded = true

  is_loaded: () ->
    @loaded

