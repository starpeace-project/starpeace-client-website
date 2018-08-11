
import * as PIXI from 'pixi.js';

class ColorFillFilter extends PIXI.Filter {
  constructor(hexColor) {
    super(`attribute vec2 aVertexPosition;
      attribute vec2 aTextureCoord;
      uniform mat3 projectionMatrix;
      varying vec2 vTextureCoord;
      void main(void) {
      gl_Position = vec4((projectionMatrix * vec3(aVertexPosition, 1.0)).xy, 0.0, 1.0);
      vTextureCoord = aTextureCoord;
    }`, `precision mediump float;
      varying vec2 vTextureCoord;
      uniform sampler2D uSampler;
      uniform vec3 rgbColor;
      void main(void) {
      gl_FragColor = texture2D(uSampler, vTextureCoord);
      gl_FragColor.r = rgbColor.r * gl_FragColor.a;
      gl_FragColor.g = rgbColor.g * gl_FragColor.a;
      gl_FragColor.b = rgbColor.b * gl_FragColor.a;
    }`);

    this.hexColor = hexColor;
  }

  get rbgColor() { return this.uniforms.rgbColor; }
  set rbgColor(value) { this.uniforms.rgbColor = value; }

  get hexColor() { return PIXI.utils.rgb2hex(this.uniforms.rgbColor); }
  set hexColor(value) { this.uniforms.rgbColor = PIXI.utils.hex2rgb(value); }
}

PIXI.filters.ColorFillFilter = ColorFillFilter
