
import tinygradient from 'tinygradient'

export default class Overlay
  @TYPES:
    NONE:
      value: 0
      type: 'NONE'
      label: 'None'
    ZONES:
      value: 1
      type: 'ZONES'
      label: 'City Zones'
    TOWNS:
      value: 2
      type: 'TOWNS'
      label: 'Towns'
    BEAUTY:
      value: 3
      type: 'BEAUTY'
      label: 'Beauty'
      color_gradient: tinygradient([{pos: 0, color: '#FF0000'}, {pos: .5, color: '#010101'}, {pos: 1, color: '#00FF00'}])
    HC_RESIDENTIAL:
      value: 4
      type: 'HC_RESIDENTIAL'
      label: 'High-class Population'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#008080'}])
    MC_RESIDENTIAL:
      value: 5
      type: 'MC_RESIDENTIAL'
      label: 'Middle-class Population'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#008080'}])
    LC_RESIDENTIAL:
      value: 6
      type: 'LC_RESIDENTIAL'
      label: 'Low-class Population'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#008080'}])

    QOL:
      value: 7
      type: 'QOL'
      label: 'QOL'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#0000FF'}])
    CRIME:
      value: 8
      type: 'CRIME'
      label: 'Crime'
      color_gradient: tinygradient([{pos: 0, color: '#0000FF'}, {pos: .5, color: '#010101'}, {pos: 1, color: '#FF0000'}])
    POLLUTION:
      value: 9
      type: 'POLLUTION'
      label: 'Pollution'
      color_gradient: tinygradient([{pos: 0, color: '#00FF00'}, {pos: .5, color: '#010101'}, {pos: 1, color: '#FF0000'}])
    BAP:
      value: 10
      type: 'BAP'
      label: 'BAP'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#800080'}])

    FRESH_FOOD:
      value: 11
      type: 'FRESH_FOOD'
      label: 'Fresh Food'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    PROCESSED_FOOD:
      value: 12
      type: 'PROCESSED_FOOD'
      label: 'Processed Food'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    CLOTHES:
      value: 13
      type: 'CLOTHES'
      label: 'Clothes'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    APPLIANCES:
      value: 14
      type: 'APPLIANCES'
      label: 'Appliances'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    CARS:
      value: 15
      type: 'CARS'
      label: 'Cars'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    RESTAURANTS:
      value: 16
      type: 'RESTAURANTS'
      label: 'Restaurants'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    BARS:
      value: 17
      type: 'BARS'
      label: 'Bars'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    TOYS:
      value: 18
      type: 'TOYS'
      label: 'Toys'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    DRUGS:
      value: 19
      type: 'DRUGS'
      label: 'Drugs'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    MOVIES:
      value: 20
      type: 'MOVIES'
      label: 'Movies'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    GASOLINE:
      value: 21
      type: 'GASOLINE'
      label: 'Gasoline'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    COMPUTERS:
      value: 22
      type: 'COMPUTERS'
      label: 'Computers'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    FURNITURE:
      value: 23
      type: 'FURNITURE'
      label: 'Furniture'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    BOOKS:
      value: 24
      type: 'BOOKS'
      label: 'Books'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    COMPACT_DISCS:
      value: 25
      type: 'COMPACT_DISCS'
      label: 'CDs'
      color_gradient: tinygradient([{pos: 0, color: '#010101'}, {pos: 1, color: '#FFFF00'}])
    FUNERAL_PARLORS:
      value: 26
      type: 'FUNERAL_PARLORS'
      label: 'Funeral Parlors'
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
