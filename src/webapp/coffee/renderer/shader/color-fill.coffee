
SHADER = "precision mediump float;" +
    "varying vec2 vTextureCoord; +"
    "uniform sampler2D uSampler;" +
    "uniform vec3 rgbColor;" +
    "void main(void) {" + 
    "gl_FragColor = texture2D(uSampler, vTextureCoord);" +
    "gl_FragColor.r = rgbColor.r * gl_FragColor.a;" +
    "gl_FragColor.g = rgbColor.g * gl_FragColor.a;" +
    "gl_FragColor.b = rgbColor.b * gl_FragColor.a;" +
    "}"

window.starpeace ||= {}
window.starpeace.renderer ||= {}
window.starpeace.renderer.shader ||= {}
window.starpeace.renderer.shader.ColorFill = class ColorFill extends PIXI.Filter
  constructor: (@hexColor) ->
    super(starpeace.renderer.shader.DefaultVert, SHADER)

  Object.defineProperties @prototype,
    rgbColor:
      get: -> @uniforms.rgbColor
      set: (value) -> @uniforms.rgbColor = value

    hexColor:
      get: -> console.log(@hexColor); PIXI.utils.rgb2hex(@uniforms.rgbColor)
      set: (value) -> @uniforms.rgbColor = PIXI.utils.hex2rgb(value)
