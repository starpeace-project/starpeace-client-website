const fs = require('fs')
const moment = require('moment')
require('moment-timezone')
const marked = require('marked')
const webpack = require('webpack')
const pjson = require('./package.json')

const is_development = process.env.NODE_ENV === 'development'

// var git_version = pjson.version;
// if (!git_version || !git_version.length) {
//   const GitRevisionPlugin = require('git-revision-webpack-plugin')
//   const gitRevisionPlugin = new GitRevisionPlugin({lightweightTags: true})
//   git_version = gitRevisionPlugin.version();
// }
const client_version = 'v' + pjson.version + '-' + moment().tz('America/Los_Angeles').format('YYYY-MM-DD');

var release_notes_html = marked(fs.readFileSync('./RELEASE.md').toString())
release_notes_html = release_notes_html.replace(new RegExp(/\<li\>/, 'g'), "<li class='columns'>");
release_notes_html = release_notes_html.replace(new RegExp(/\<\/li\>/, 'g'), "</span></li>");
release_notes_html = release_notes_html.replace(new RegExp(/\[done\]/, 'g'), "<span class='column is-2'><span class='tag is-link'>done</span></span><span class='column is-10'>");
release_notes_html = release_notes_html.replace(new RegExp(/\[in progress\]/, 'g'), "<span class='column is-2'><span class='tag is-success'>in progress</span></span><span class='column is-10'>");
release_notes_html = release_notes_html.replace(new RegExp(/\[pending\]/, 'g'), "<span class='column is-2'><span class='tag is-warning'>pending</span></span><span class='column is-10'>");

module.exports = {
  css: [
    { src: '~/assets/stylesheets/bulma-starpeace.sass', lang: 'sass' },
    { src: '~/assets/stylesheets/starpeace.sass', lang: 'sass' }
  ],
  head: {
    title: 'STARPEACE',
    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      { hid: 'description', name: 'description', content: 'Client website application for STARPEACE multiplayer economic simulation' }
    ],
    link: [
      { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
      { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css?family=Open+Sans|Varela+Round|Open+Sans+Condensed:300' }
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
    RELEASE_NOTES_HTML: release_notes_html
  },
  build: {
    // analyze: true,
    publicPath: '/assets/',
    vendor: ['lodash', 'javascript-detect-element-resize', 'pixi.js', 'interactjs', 'fpsmeter', 'tinygradient'],
    extend (config, { isDev, isClient }) {
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
    { src: '~/plugins/element-queries', ssr: false },
    { src: '~/plugins/fpsmeter', ssr: false },
    { src: '~/plugins/font-awesome', ssr: false },
    { src: '~/plugins/google-analytics', ssr: false },
    { src: '~/plugins/pixi', ssr: false }
  ]
}
