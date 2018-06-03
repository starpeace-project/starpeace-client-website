

window.starpeace ||= {}
window.starpeace.renderer ||= {}
window.starpeace.renderer.Utils = class Utils

  @iso_to_i: (half_height, half_width, x, y) ->
    Math.round(((y / half_height) + (x / half_width)) / 2)

  @iso_to_j: (half_height, half_width, x, y) ->
    Math.round(((y / half_height) - (x / half_width)) / 2)

