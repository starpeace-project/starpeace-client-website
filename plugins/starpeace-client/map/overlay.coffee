

class Overlay
  @TYPES:
    NONE:
      value: 0
      type: 'NONE'
      label: 'None'
    ZONES:
      value: 1
      type: 'ZONES'
      label: 'Building Zones'
    TOWNS:
      value: 2
      type: 'TOWNS'
      label: 'Towns'
    BEAUTY:
      value: 3
      type: 'BEAUTY'
      label: 'Beauty'
      color_scale: [{value: 0, color: 0xFF0000},{value: 128, color: 0x010101},{value: 255, color: 0x00FF00}]
    HC_RESIDENTIAL:
      value: 4
      type: 'HC_RESIDENTIAL'
      label: 'High-class Population'
      color_scale: [{value: 0, color: 0x010101},{value: 255, color: 0x008080}]
    MC_RESIDENTIAL:
      value: 5
      type: 'MC_RESIDENTIAL'
      label: 'Middle-class Population'
      color_scale: [{value: 0, color: 0x010101},{value: 255, color: 0x008080}]
    LC_RESIDENTIAL:
      value: 6
      type: 'LC_RESIDENTIAL'
      label: 'Low-class Population'
      color_scale: [{value: 0, color: 0x010101},{value: 255, color: 0x008080}]

    QOL:
      value: 7
      type: 'QOL'
      label: 'QOL'
      color_scale: [{value: 0, color: 0x010101},{value: 255, color: 0x0000FF}]
    CRIME:
      value: 8
      type: 'CRIME'
      label: 'Crime'
      color_scale: [{value: 0, color: 0x0000FF},{value: 128, color: 0x010101},{value: 255, color: 0xFF0000}]
    POLLUTION:
      value: 9
      type: 'POLLUTION'
      label: 'Pollution'
      color_scale: [{value: 0, color: 0x00FF00},{value: 128, color: 0x010101},{value: 255, color: 0xFF0000}]
    BAP:
      value: 10
      type: 'BAP'
      label: 'BAP'
      color_scale: [{value: 0, color: 0x010101},{value: 255, color: 0x800080}]

    FRESH_FOOD:
      value: 11
      type: 'FRESH_FOOD'
      label: 'Fresh Food'
      color_scale: [{value: 0, color: 0x010101},{value: 255, color: 0xFFFF00}]
    PROCESSED_FOOD:
      value: 12
      type: 'PROCESSED_FOOD'
      label: 'Processed Food'
      color_scale: [{value: 0, color: 0x010101},{value: 255, color: 0xFFFF00}]
    CLOTHES:
      value: 13
      type: 'CLOTHES'
      label: 'Clothes'
      color_scale: [{value: 0, color: 0x010101},{value: 255, color: 0xFFFF00}]
    APPLIANCES:
      value: 14
      type: 'APPLIANCES'
      label: 'Appliances'
      color_scale: [{value: 0, color: 0x010101},{value: 255, color: 0xFFFF00}]
    CARS:
      value: 15
      type: 'CARS'
      label: 'Cars'
      color_scale: [{value: 0, color: 0x010101},{value: 255, color: 0xFFFF00}]
    RESTAURANTS:
      value: 16
      type: 'RESTAURANTS'
      label: 'Restaurants'
      color_scale: [{value: 0, color: 0x010101},{value: 255, color: 0xFFFF00}]
    BARS:
      value: 17
      type: 'BARS'
      label: 'Bars'
      color_scale: [{value: 0, color: 0x010101},{value: 255, color: 0xFFFF00}]
    TOYS:
      value: 18
      type: 'TOYS'
      label: 'Toys'
      color_scale: [{value: 0, color: 0x010101},{value: 255, color: 0xFFFF00}]
    DRUGS:
      value: 19
      type: 'DRUGS'
      label: 'Drugs'
      color_scale: [{value: 0, color: 0x010101},{value: 255, color: 0xFFFF00}]
    MOVIES:
      value: 20
      type: 'MOVIES'
      label: 'Movies'
      color_scale: [{value: 0, color: 0x010101},{value: 255, color: 0xFFFF00}]
    GASOLINE:
      value: 21
      type: 'GASOLINE'
      label: 'Gasoline'
      color_scale: [{value: 0, color: 0x010101},{value: 255, color: 0xFFFF00}]
    COMPUTERS:
      value: 22
      type: 'COMPUTERS'
      label: 'Computers'
      color_scale: [{value: 0, color: 0x010101},{value: 255, color: 0xFFFF00}]
    FURNITURE:
      value: 23
      type: 'FURNITURE'
      label: 'Furniture'
      color_scale: [{value: 0, color: 0x010101},{value: 255, color: 0xFFFF00}]
    BOOKS:
      value: 24
      type: 'BOOKS'
      label: 'Books'
      color_scale: [{value: 0, color: 0x010101},{value: 255, color: 0xFFFF00}]
    COMPACT_DISCS:
      value: 25
      type: 'COMPACT_DISCS'
      label: 'CDs'
      color_scale: [{value: 0, color: 0x010101},{value: 255, color: 0xFFFF00}]
    FUNERAL_PARLORS:
      value: 26
      type: 'FUNERAL_PARLORS'
      label: 'Funeral Parlors'
      color_scale: [{value: 0, color: 0x010101},{value: 255, color: 0xFFFF00}]

  @deserialize_chunk: (width, height, data) ->
    zones = new Array(width * height)
    type_names = Object.keys(Overlay.TYPES)

    for y in [0...height]
      for x in [0...width]
        type_value = parseInt(data[y * width + x], 16)
        type = if type_value > 0 && type_value < type_names.length then Overlay.TYPES[type_names[type_value]] else null
        zones[y * width + x] = type || Overlay.TYPES.NONE

    zones

export default Overlay
