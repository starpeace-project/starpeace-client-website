
import AssetManager from '~/plugins/starpeace-client/asset/asset-manager.coffee'

import { Howl, Howler } from 'howler'

MUSIC_MP3 = ['music.intro.mp3', 'music.inmap1.mp3', 'music.inmap3.mp3', 'music.inmap2.mp3','music.inmap4.mp3'] # inmap1 & inmap2 similar

export default class MusicState
  constructor: () ->
    @music_index = Math.floor(Math.random() * MUSIC_MP3.length)
    @music = MUSIC_MP3.map (item) => new Howl({
      src: "#{AssetManager.CDN_URL}/#{AssetManager.CDN_VERSION}/#{item}"
      autoplay: false
      html5: true
      loop: false
      preload: false
      volume: 0.1
      onend: () => @next_song()
    })

    @reset_state()

  reset_state: () ->
    @game_music_playing = false
    @game_music_volume = true

  toggle_music: () ->
    if @music[@music_index].playing()
      @music[@music_index].pause()
    else
      @music[@music_index].play()
    @game_music_playing = !@game_music_playing

  next_song: () ->
    @music[@music_index].stop() if @music[@music_index].playing()

    @music_index += 1
    @music_index = 0 if @music_index >= MUSIC_MP3.length
    @music[@music_index].play()

  toggle_volume: () ->
    @game_music_volume = !@game_music_volume
    Howler.mute(!@game_music_volume)
