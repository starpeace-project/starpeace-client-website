
# starpeace-website-client

## Future Roadmap
Some of the tentative future features and rough planned version are outlined below:

### v0.3

* API authentication
* metadata and gameplay resources from API's
* basic state API integration (new account setup, tycoon info, building data)
* input interaction support for buildings (selection, rendering)

* persist client options
* game music and controls
* camera rotation perspectives
* mini-map rendering
* map interaction support (place buildings, favorites, city integration)


### v0.2 - in progress
#### platform
* [done] basic event and news ticker
* [done] build and package framework migrating to nuxtjs
* [done] client refactor to full native nuxtjs vue application and custom components
* [done] more client/vue internal state separation
* [done] migrate to bulma/buefy/interactjs from bootstrap
* [in progress] main gameplay UI menu layout
* [in progress] city zone and overlay loader
* [pending] building asset and resource loader

#### assets
* [done] tree cleanup and spritesheet generation
* [done] static news support
* [pending] buildings cleanup and spritesheet generation

#### gameplay
* [done] tree rendering
* [done] static news notifications
* [done] seasons support
* [pending] building rendering and animations
* [pending] city zones rendering
* [pending] overlay rendering


## Release Notes

### v0.1.0 - 2018-06-03
#### platform
* [done] client javascript framework, build and deploy logic
* [done] vue integration and basic interaction state
* [done] resource and asset loader and UI integration
* [done] client webgl renderer framework
* [done] basic input support for map drag panning, auto-scrolling at borders, and zoom with mouse-wheel

#### assets
* [done] land tile cleanup and spritesheet generation
* [done] procedural generation of planet gif for selection UI

#### gameplay
* [done] login and planetary selection UI workflows
* [done] land tile rendering from game maps for 0deg perspective and fall season
