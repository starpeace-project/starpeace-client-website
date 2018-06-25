
###
global PIXI
###

SHADER = "precision mediump float;" +
    "varying vec2 vTextureCoord;" +
    "uniform sampler2D uSampler;" +
    "uniform vec3 rgbColor;" +
    "void main(void) {" +
    "gl_FragColor = texture2D(uSampler, vTextureCoord);" +
    "gl_FragColor.r = rgbColor.r * gl_FragColor.a;" +
    "gl_FragColor.g = rgbColor.g * gl_FragColor.a;" +
    "gl_FragColor.b = rgbColor.b * gl_FragColor.a;" +
    "}"

VERT = "attribute vec2 aVertexPosition;" +
  "attribute vec2 aTextureCoord;" +
  "uniform mat3 projectionMatrix;" +
  "varying vec2 vTextureCoord;" +
  "void main(void)" +
  "{" +
  "gl_Position = vec4((projectionMatrix * vec3(aVertexPosition, 1.0)).xy, 0.0, 1.0);" +
  "vTextureCoord = aTextureCoord;" +
  "}"

class ColorFill extends PIXI.Filter
  constructor: (@hexColor) ->
    super(VERT, SHADER)

  Object.defineProperties @prototype,
    rgbColor:
      get: -> @uniforms.rgbColor
      set: (value) -> @uniforms.rgbColor = value

    hexColor:
      get: -> console.log(@hexColor); PIXI.utils.rgb2hex(@uniforms.rgbColor)
      set: (value) -> @uniforms.rgbColor = PIXI.utils.hex2rgb(value)

export default ColorFill
