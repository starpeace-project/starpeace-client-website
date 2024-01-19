
## v0.4.0 - 2024-01-07
### platform
* [done] improve API integration with galaxies [v0.3.1]
* [done] document multiverse API integration [starpeace-server-multiverse-api]
* [done] upgrade platform dependencies (nuxt, PixiJS) [v0.3.2]
* [done] document metadata and gameplay resources [starpeace-assets-types]
* [done] align sandbox with multiverse API [v0.3.2]
* [done] API authentication and authorization [v0.3.2]
* [done] building simulation configurations API [v0.3.2]
* [done] industry and resource configurations API [v0.3.2]
* [done] inventions configurations API [v0.3.2]
* [done] create tycoon account API [v0.3.2]
* [done] manage corporation and company API's [v0.3.2]
* [done] search and rankings API integration [v0.3.3]
* [done] manage mail API integration [v0.3.3]
* [done] cashflow API integration [v0.3.3]
* [done] overlay API integration [v0.3.4]
* [done] buildings (by chunk) API integration [v0.3.4]
* [done] town boundaries and city detection [v0.3.4]
* [done] roads API integration [v0.3.5]
* [done] planet and town details API (services, commerce, taxes, jobs, housing) [v0.3.6]
* [done] system messages and basic error messages [v0.3.7]
* [done] socket network events and API [v0.3.8]
* [done] improve tycoon, corporation, and company creation error handling [v0.3.8]
* [done] visa and tycoon position API integration [v0.3.8]
* [done] major version upgrade of platform dependencies (nuxt, PixiJS) [v0.3.8]
* [done] fixing various defects with previous upgrades [v0.3.9]
* [done] fixing research lifecycle and API integration [v0.3.9]
* [done] fix interaction performance and fps issues [v0.3.11]
* [done] research visualization upgrade fixes [v0.3.11]
* [done] bookmarks manage and performance fixes [v0.3.11]
* [done] tycoon details API [v0.3.12]
* [done] fixed galaxy and research menu bugs  [v0.3.13]
* [done] building inspect API [v0.3.13]
* [done] player and building event handling [v0.3.13]
* [done] admin API [v0.3.14]

### assets
* [done] finish initial language translation for assets [v0.3.1]
* [done] add mine industry and building metadata [v0.3.2]
* [done] building stage metadata (timber, movies, farms) [v0.3.2]
* [done] building construction metadata (all) [v0.3.2]
* [done] office, residential, and civic building simulations and resources [v0.3.2]
* [done] integrate assets from starpeace-assets [v0.3.2]
* [done] town boundaries [v0.3.4]
* [done] building sign assets [v0.3.5]
* [done] headquarters requirements for research per seal [v0.3.5]
* [done] fixing building foundation configurations [v0.3.6]
* [done] fix blur in created sprite spreets [v0.3.14]

### gameplay
* [done] update UI and menus for better concept of universes and galaxies [v0.3.1]
* [done] client language translations and menu option [v0.3.1]
* [done] corporation and company formation menus [v0.3.2]
* [done] town search menu [v0.3.3]
* [done] tycoon search menu [v0.3.3]
* [done] rankings menu [v0.3.3]
* [done] mail menu [v0.3.3]
* [done] city overlay rendering [v0.3.4]
* [done] chat menu [v0.3.4]
* [done] jump to townhall and history widgets [v0.3.4]
* [done] mine building sign rendering [v0.3.5]
* [done] limit research unless constructed required headquarters [v0.3.5]
* [done] improved road orientation metadata [v0.3.5]
* [done] politics menu [v0.3.6]
* [done] townhall inspect menu [v0.3.6]
* [done] trade center inspect menu [v0.3.6]
* [done] building selection container box rendering [v0.3.10]
* [done] onscreen building text rendering on selection [v0.3.10]
* [done] construction descriptions for commerce, real estate, and services [v0.3.10]
* [done] tycoon details menu [v0.3.12]
* [done] building inspect menu [v0.3.13]
* [done] selected building text for IFEL buildings [v0.3.13]
* [done] cashflow and construction included in selected building text [v0.3.13]
* [done] integrate building events with news ticker [v0.3.13]

## v0.3.0 - 2019-01-13
### platform
* [done] improved building rendering around edges [v0.2.1]
* [done] improved z-order rendering across layers [v0.2.2]
* [done] fix broken z-order rendering for buildings, trees, tree concrete, and platforms [v0.2.7]
* [done] sprite layer render refactor and fixes, caching optimizations [v0.2.7]
* [done] initial dynamic layout support (desktop, mobile) [v0.2.8]
* [done] input interaction support for buildings (selection, rendering) [v0.2.10]
* [done] internal options simplification and refactoring [v0.2.12]
* [done] improve client UI grid layout and game menu components [v0.2.12]
* [done] improve game state workflow and initial API integration (mock) [v0.2.12]
* [done] major internal refactor and reorganization of state handling (metadata, game data, player data) [v0.2.12]

### assets
* [done] improved gameplay documentation [v0.2.4]
* [done] improved asset versioning [v0.2.4]
* [done] plane assets [v0.2.4]
* [done] effects assets and building metadata [v0.2.5]
* [done] concrete and platform assets [v0.2.6]
* [done] road and bridge assets [v0.2.7]
* [done] game background music [v0.2.8]
* [done] formal asset versioning [v0.2.9]
* [done] building asset interaction hitboxes [v0.2.10]
* [done] refactor seal asset organization, integrate more game metadata [v0.2.12]
* [done] invention metadata and taxonomy [v0.2.12]
* [done] initial language translation support [v0.2.12]
* [done] client static news and updates info widget [v0.2.12]
* [done] initial building construction metadata (industry, warehouse) [v0.3.0]

### gameplay
* [done] persist client options in localStorage [v0.2.3]
* [done] improve building animation tying render frame to game clock [v0.2.3]
* [done] plane rendering [v0.2.4]
* [done] rendering options support [v0.2.5]
* [done] building footprint layer rendering [v0.2.5]
* [done] building effect layer rendering [v0.2.5]
* [done] improve tree layer rendering [v0.2.6]
* [done] concrete and platform rendering [v0.2.6]
* [done] road rendering [v0.2.7]
* [done] game music controls [v0.2.8]
* [done] bridge rendering [v0.2.9]
* [done] improve concrete rendering (edges, roads) [v0.2.9]
* [done] mini-map rendering [v0.2.11]
* [done] basic map favorites integration [v0.2.12]
* [done] basic research and development UI and menu support [v0.2.12]
* [done] building construction menu and interaction support [v0.3.0]

## v0.2.0 - 2018-07-06
### platform
* [done] build and package framework migrating to nuxtjs
* [done] client refactor to full native vue application and custom components
* [done] more client/vue internal state separation
* [done] migrate from bootstrap to bulma and custom starpeace theme
* [done] client version and release notes integrated in client
* [done] basic event and news ticker
* [done] main gameplay UI menu layout
* [done] city zone and overlay loader
* [done] improved mobile pan controls
* [done] building asset and resource loader

### assets
* [done] tree cleanup and spritesheet generation
* [done] static news support
* [done] buildings cleanup and spritesheet generation

### gameplay
* [done] tree rendering
* [done] static news notifications
* [done] seasons support
* [done] initial notifications UI (mail and ajax loading)
* [done] city zones rendering
* [done] overlay rendering
* [done] building rendering and animations

## v0.1.0 - 2018-06-03
### platform
* [done] client javascript framework, build and deploy logic
* [done] vue integration and basic interaction state
* [done] resource and asset loader and UI integration
* [done] client webgl renderer framework
* [done] basic input support for map drag panning, auto-scrolling at borders, and zoom with mouse-wheel

### assets
* [done] land tile cleanup and spritesheet generation
* [done] procedural generation of planet gif for selection UI

### gameplay
* [done] login and planetary selection UI workflows
* [done] land tile rendering from game maps for 0deg perspective and fall season
