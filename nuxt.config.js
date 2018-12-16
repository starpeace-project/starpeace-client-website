const fs = require('fs')
const path = require('path')
const moment = require('moment')
require('moment-timezone')
const marked = require('marked')
const webpack = require('webpack')
const node_externals = require('webpack-node-externals')
const pjson = require('./package.json')

const is_development = process.env.NODE_ENV === 'development'

const client_version = 'v' + pjson.version + '-' + moment().tz('America/Los_Angeles').format('YYYY-MM-DD');

var render_and_convert_markdown = function(markdown) {
  var release_notes_html = marked(markdown);
  release_notes_html = release_notes_html.replace(new RegExp(/\<li\>/, 'g'), "<li class='columns is-mobile'>");
  release_notes_html = release_notes_html.replace(new RegExp(/\<\/li\>/, 'g'), "</span></li>");
  release_notes_html = release_notes_html.replace(new RegExp(/\[done\]/, 'g'), "<span class='column is-2'><span class='tag is-link'>done</span></span><span class='column is-10'>");
  release_notes_html = release_notes_html.replace(new RegExp(/\[in progress\]/, 'g'), "<span class='column is-2'><span class='tag is-success'>in progress</span></span><span class='column is-10'>");
  release_notes_html = release_notes_html.replace(new RegExp(/\[pending\]/, 'g'), "<span class='column is-2'><span class='tag is-warning'>pending</span></span><span class='column is-10'>");
  return release_notes_html;
}

var release_notes_html = render_and_convert_markdown(fs.readFileSync('./RELEASE.md').toString());
var release_notes_archive_html = render_and_convert_markdown(fs.readFileSync('./RELEASE-archive.md').toString());

module.exports = {
  css: [
    { src: '~/assets/stylesheets/starpeace-bulma.sass', lang: 'sass' },
    { src: '~/assets/stylesheets/starpeace-vue.sass', lang: 'sass' },
    { src: '~/assets/stylesheets/starpeace.sass', lang: 'sass' },
    { src: 'v-contextmenu', lang: 'css' }
  ],
  head: {
    title: 'STARPEACE',
    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      { hid: 'description', name: 'description', content: 'STARPEACE client website: a real-time city-building economic simulation and cooperative multiplayer strategy game' }
    ],
    link: [
      { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
      { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css?family=Open+Sans|Varela+Round' }
    ]
  },
  render: {
    resourceHints: false
  },
  generate: {
    fallback: false
  },
  env: {
    CLIENT_VERSION: client_version,
    RELEASE_NOTES_HTML: release_notes_html,
    RELEASE_NOTES_ARCHIVE_HTML: release_notes_archive_html
  },
  build: {
    // analyze: true,
    publicPath: '/assets/',
    vendor: ['fpsmeter', 'howler', 'interactjs', 'javascript-detect-element-resize', 'lodash', 'pixi.js', 'tinygradient', 'v-contextmenu'],
    extend (config, { isDev, isClient, isServer }) {
      config.module.rules.push({
        test: /\.coffee$/,
        use: 'coffee-loader',
        exclude: /(node_modules)/
      });
      config.module.rules.push({
        test: /\.haml$/,
        use: 'haml',
        exclude: /(node_modules)/
      });
      config.module.rules.push({
        test: /RELEASE.md$/,
        use: [ 'html-loader', 'markdown-loader' ],
        exclude: /(node_modules)/
      });
      config.module.rules.push({
        test: /\.js/,
        use: 'babel-loader',
        include: [
          path.resolve('node_modules/vue-echarts'),
          path.resolve('node_modules/resize-detector')
        ]
      });

      if (isServer) {
        config.externals = [
          node_externals({
            whitelist: [/es6-promise|\.(?!(?:js|json)$).{1,5}$/i, /^vue-echarts/]
          })
        ];
      }

      if (!isClient) {
        if (!fs.existsSync('.nuxt/dist/')) {
          fs.mkdirSync('.nuxt/dist/');
        }
        fs.writeFileSync('.nuxt/dist/client-version.json', "{\"version\":\"" + client_version + "\"}");
      }
    }
  },
  modules: [
    '@nuxtjs/moment', ['@nuxtjs/google-analytics', { id: 'UA-120729341-2', debug: { sendHitTask: !is_development } }]
  ],
  plugins: [
    { src: '~/plugins/echarts', ssr: false },
    { src: '~/plugins/element-queries', ssr: false },
    { src: '~/plugins/flaticon', ssr: false },
    { src: '~/plugins/fpsmeter', ssr: false },
    { src: '~/plugins/font-awesome', ssr: false },
    { src: '~/plugins/google-analytics', ssr: false },
    { src: '~/plugins/pixi/pixi', ssr: false }
  ]
}
