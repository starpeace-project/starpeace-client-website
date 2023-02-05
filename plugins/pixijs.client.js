import { extensions, ExtensionType, Texture } from 'pixi.js';

export default defineNuxtPlugin((nuxtApp) => {
  // Graphics.nextRoundedRectBehavior = true
  // Text.nextRoundedRectBehavior = true
  // extensions.remove(InteractionManager)

  extensions.add({
    extension: ExtensionType.LoadParser,
    test: (url) => url.endsWith('.bmp'),
    async load(src) {
      return new Promise((resolve, reject) => {
        const img = new Image();
        img.crossOrigin = 'anonymous';
        img.onload = () => resolve(Texture.from(img));
        img.onerror = reject;
        img.src = src;
      })
    }
  });
});
