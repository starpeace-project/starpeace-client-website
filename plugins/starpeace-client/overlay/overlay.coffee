
import tinygradient from 'tinygradient'

export default class Overlay
  @TYPES:
    NONE:
      value: 0
      type: 'NONE'
    ZONES:
      value: 1
      type: 'ZONES'
    TOWNS:
      value: 2
      type: 'TOWNS'
      label_key: 'overlay.towns.label'
    BEAUTY:
      value: 3
      type: 'BEAUTY'
      label_key: 'overlay.beauty.label'
      color_gradient: tinygradient([{pos: 0, color: '#FF0000'}, {pos: .5, color: '#010101'}, {pos: 1, color: '#00FF00'}])

    HC_RESIDENTIAL:
      value: 4
      type: 'HC_RESIDENTIAL'
      label_key: 'overlay.hc_population.label'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#008080'}])
    MC_RESIDENTIAL:
      value: 5
      type: 'MC_RESIDENTIAL'
      label_key: 'overlay.mc_population.label'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#008080'}])
    LC_RESIDENTIAL:
      value: 6
      type: 'LC_RESIDENTIAL'
      label_key: 'overlay.lc_population.label'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#008080'}])

    QOL:
      value: 7
      type: 'QOL'
      label_key: 'overlay.qol.label'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#0000FF'}])
    CRIME:
      value: 8
      type: 'CRIME'
      label_key: 'overlay.crime.label'
      color_gradient: tinygradient([{pos: 0, color: '#0000FF'}, {pos: .5, color: '#010101'}, {pos: 1, color: '#FF0000'}])
    POLLUTION:
      value: 9
      type: 'POLLUTION'
      label_key: 'overlay.pollution.label'
      color_gradient: tinygradient([{pos: 0, color: '#00FF00'}, {pos: .5, color: '#010101'}, {pos: 1, color: '#FF0000'}])
    BAP:
      value: 10
      type: 'BAP'
      label_key: 'overlay.bap.label'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#800080'}])

    APPLIANCES:
      value: 14
      type: 'APPLIANCES'
      label_key: 'overlay.appliance.label'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    AUTOMOBILE:
      value: 15
      type: 'AUTOMOBILE'
      label_key: 'overlay.automobile.label'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    BARS:
      value: 17
      type: 'BARS'
      label_key: 'overlay.bar.label'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    BOOKS:
      value: 24
      type: 'BOOKS'
      label_key: 'overlay.book.label'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    CLOTHES:
      value: 13
      type: 'CLOTHES'
      label_key: 'overlay.clothes.label'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    COMPACT_DISCS:
      value: 25
      type: 'COMPACT_DISCS'
      label_key: 'overlay.compact_disc.label'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    COMPUTERS:
      value: 22
      type: 'COMPUTERS'
      label_key: 'overlay.computer.label'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    FRESH_FOOD:
      value: 11
      type: 'FRESH_FOOD'
      label_key: 'overlay.fresh_food.label'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    FUNERAL_SERVICES:
      value: 26
      type: 'FUNERAL_SERVICES'
      label_key: 'overlay.funeral_services.label'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    FURNITURE:
      value: 23
      type: 'FURNITURE'
      label_key: 'overlay.furniture.label'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    GASOLINE:
      value: 21
      type: 'GASOLINE'
      label_key: 'overlay.gasoline.label'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    MOVIES:
      value: 20
      type: 'MOVIES'
      label_key: 'overlay.movie.label'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    PHARMACEUTICAL:
      value: 19
      type: 'PHARMACEUTICAL'
      label_key: 'overlay.pharmaceutical.label'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    PROCESSED_FOOD:
      value: 12
      type: 'PROCESSED_FOOD'
      label_key: 'overlay.processed_food.label'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    RESTAURANTS:
      value: 16
      type: 'RESTAURANTS'
      label_key: 'overlay.restaurant.label'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    TOYS:
      value: 18
      type: 'TOYS'
      label_key: 'overlay.toy.label'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])


  @deserialize_chunk: (type, width, height, data) ->
    overlay = Overlay.TYPES[type]
    throw "unknown overlay type #{type}" unless overlay?
    overlay_data = new Array(width * height)

    data_chunks = data.match(/.{1,2}/g)
    for y in [0...height]
      for x in [0...width]
        overlay_value = parseInt(data_chunks[y * width + x], 16)
        overlay_data[y * width + x] = {
          value: overlay_value
          color: parseInt(overlay.color_gradient.rgbAt(overlay_value / 255).toHex(), 16)
        }

    overlay_data
