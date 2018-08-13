
import { Howl, Howler } from 'howler'

export default class MusicManager
  @CDN_URL: 'https://cdn.starpeace.io'
  @MUSIC_MP3: ['music.intro.mp3', 'music.inmap1.mp3', 'music.inmap3.mp3', 'music.inmap2.mp3','music.inmap4.mp3'] # 1 & 2 similar

  constructor: (@game_state) ->
    @music_index = Math.floor(Math.random() * MusicManager.MUSIC_MP3.length)
    @music = MusicManager.MUSIC_MP3.map (item) => new Howl({
      src: "#{MusicManager.CDN_URL}/#{item}"
      autoplay: false
      html5: true
      loop: false
      preload: false
      volume: 0.1
      onend: () => @next_song()
    })

  toggle_music: () ->
    if @music[@music_index].playing()
      @music[@music_index].pause()
    else
      @music[@music_index].play()
    @game_state.game_music_playing = !@game_state.game_music_playing

  next_song: () ->
    @music[@music_index].stop() if @music[@music_index].playing()

    @music_index += 1
    @music_index = 0 if @music_index >= MusicManager.MUSIC_MP3.length
    @music[@music_index].play()

  toggle_volume: () ->
    @game_state.game_music_volume = !@game_state.game_music_volume
    Howler.mute(!@game_state.game_music_volume)
