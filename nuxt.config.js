const fs = require('fs')
const marked = require('marked')
const pjson = require('./package.json');

import coffee from '@bkuri/rollup-plugin-coffeescript';


const is_development = process.env.NODE_ENV === 'development';

const now = new Date();
const year = now.toLocaleString('en-US', { timeZone: 'America/Los_Angeles', year: 'numeric'});
const month = now.toLocaleString('en-US', { timeZone: 'America/Los_Angeles', month: '2-digit'});
const day = now.toLocaleString('en-US', { timeZone: 'America/Los_Angeles', day: '2-digit'});
const nowDate = `${year}-${month}-${day}`;
const client_version = 'v' + pjson.version + '-' + nowDate;

var render_and_convert_markdown = function(markdown) {
  var release_notes_html = marked.marked.parse(markdown, { mangle: false, headerIds: false, headerPrefix: false });
  release_notes_html = release_notes_html.replace(new RegExp(/\<li\>/, 'g'), "<li class='columns is-mobile'>");
  release_notes_html = release_notes_html.replace(new RegExp(/\<\/li\>/, 'g'), "</span></li>");
  release_notes_html = release_notes_html.replace(new RegExp(/\[done\]/, 'g'), "<span class='column is-2'><span class='tag is-link'>done</span></span><span class='column is-10'>");
  release_notes_html = release_notes_html.replace(new RegExp(/\[in progress\]/, 'g'), "<span class='column is-2'><span class='tag is-success'>in progress</span></span><span class='column is-10'>");
  release_notes_html = release_notes_html.replace(new RegExp(/\[pending\]/, 'g'), "<span class='column is-2'><span class='tag is-warning'>pending</span></span><span class='column is-10'>");
  return release_notes_html;
}

var release_notes_html = render_and_convert_markdown(fs.readFileSync('./RELEASE.md').toString());
var release_notes_archive_html = render_and_convert_markdown(fs.readFileSync('./RELEASE-archive.md').toString());

export default defineNuxtConfig({
  css: [
    'bulma',
    '@/assets/stylesheets/starpeace-tooltip.sass',
    '@/assets/stylesheets/starpeace-bulma.sass',
    '@/assets/stylesheets/starpeace-flags.sass',
    '@/assets/stylesheets/starpeace-vue.sass',
    '@/assets/stylesheets/starpeace.sass'
  ],
  app: {
    buildAssetsDir: '/resources/',
    head: {
      title: 'STARPEACE',
      meta: [
        { charset: 'utf-8' },
        { name: 'google', content: 'notranslate' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { hid: 'description', name: 'description', content: 'STARPEACE: a real-time city-building economic simulation and cooperative multiplayer strategy game' }
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico', media: '(prefers-color-scheme:no-preference)'},
        { rel: 'icon', type: 'image/x-icon', href: '/favicon-dark.ico', media: '(prefers-color-scheme:dark)' },
        { rel: 'icon', type: 'image/x-icon', href: '/favicon-light.ico', media: '(prefers-color-scheme:light)' },
        { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css?family=Open+Sans|Varela+Round' }
      ]
    }
  },
  runtimeConfig: {
    public: {
      sendAnalytics: !is_development,
      disableRightClick: !is_development,
      CLIENT_VERSION: client_version,
      RELEASE_NOTES_HTML: release_notes_html,
      RELEASE_NOTES_ARCHIVE_HTML: release_notes_archive_html
    }
  },
  render: {
    resourceHints: false
  },
  generate: {
    fallback: false
  },
  telemetry: false,
  static: {
    prefix: false
  },
  build: {
    standalone: true
  },
  buildModules: ['@nuxt/typescript-build'],
  extensions: [
    '.coffee'
  ],
  vite: {
    extensions: [
      '.coffee'
    ],
    plugins: [
      coffee()
    ]
  }
});
