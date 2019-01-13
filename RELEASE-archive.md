
## v0.3.0 - updated 2019-01-13
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
