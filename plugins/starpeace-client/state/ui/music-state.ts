import { markRaw } from 'vue';
import { Howl, Howler } from 'howler';

import AssetManager from '~/plugins/starpeace-client/asset/asset-manager.js';

const MUSIC_MP3 = ['music.intro.mp3', 'music.inmap1.mp3', 'music.inmap3.mp3', 'music.inmap2.mp3','music.inmap4.mp3']; // inmap1 & inmap2 similar

export default class MusicState {
  musicIndex: number;
  music: Array<Howl> = [];

  gameMusicPlaying: boolean;
  gameMusicVolume: boolean;

  constructor () {
    this.musicIndex = Math.floor(Math.random() * MUSIC_MP3.length);

    this.gameMusicPlaying = false;
    this.gameMusicVolume = true;
  }

  reset_state (): void {
    this.gameMusicPlaying = false;
    this.gameMusicVolume = true;
  }

  initialize (): void {
    this.music = markRaw(MUSIC_MP3.map((item) => new Howl({
      src: `${AssetManager.CDN_URL}/${AssetManager.CDN_VERSION}/${item}`,
      autoplay: false,
      html5: true,
      loop: false,
      preload: false,
      volume: 0.1,
      onend: () => this.nextSong()
    })));
  }

  currentSong (): Howl | undefined {
    return this.musicIndex < this.music.length ? this.music[this.musicIndex] : undefined;
  }

  toggleMusic (): void {
    const song: Howl | undefined = this.currentSong();
    this.gameMusicPlaying = song?.playing() ?? false;
    if (song && this.gameMusicPlaying) {
      song.pause();
    }
    else if (song) {
      song.play();
    }
    this.gameMusicPlaying = !this.gameMusicPlaying;
  }

  nextSong (): void {
    this.currentSong()?.stop();

    this.musicIndex += 1;
    if (this.musicIndex >= MUSIC_MP3.length) {
      this.musicIndex = 0;
    }

    this.currentSong()?.play();
  }

  toggleVolume () {
    this.gameMusicVolume = !this.gameMusicVolume;
    Howler.mute(!this.gameMusicVolume);
  }
}
