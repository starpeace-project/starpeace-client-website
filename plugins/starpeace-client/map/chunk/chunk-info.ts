import { DateTime }  from 'luxon';

export default class ChunkInfo {
  chunk_x: number;
  chunk_y: number;
  width: number;
  height: number;
  max_age_mins: number;

  refresh_promise: any;

  last_updated: DateTime | null;
  expires: DateTime | null;

  constructor (chunk_x: number, chunk_y: number, width: number, height: number, max_age_mins: number) {
    this.chunk_x = chunk_x;
    this.chunk_y = chunk_y;
    this.width = width;
    this.height = height;
    this.max_age_mins = max_age_mins;

    this.refresh_promise = null;
    this.last_updated = null;
    this.expires = null;
  }

  x_offset (): number { return this.chunk_x * this.width; }
  y_offset (): number { return this.chunk_y * this.height; }

  is_current (now: DateTime): boolean { return !!this.expires && this.expires > now; }

  update () {
    this.last_updated = DateTime.now();
    this.expires = this.last_updated.plus({ minutes: this.max_age_mins });
  }
}
