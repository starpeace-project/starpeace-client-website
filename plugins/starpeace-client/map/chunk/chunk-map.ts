
import ChunkInfo from '~/plugins/starpeace-client/map/chunk/chunk-info'

export const CHUNK_WIDTH = 20;
export const CHUNK_HEIGHT = 20;

export default class ChunkMap {
  static CHUNK_WIDTH: number = CHUNK_WIDTH;
  static CHUNK_HEIGHT: number = CHUNK_HEIGHT;

  disabled: boolean = false;
  width: number;
  height: number;
  stalenessMinutes: number;

  refreshCallback: (chunkX: number, chunkY: number, chunkWidth: number, chunkHeight: number) => Promise<any>;
  handleRefreshCallback: (chunkInfo: ChunkInfo, value: any) => void;

  chunk_info: Array<ChunkInfo>;

  constructor (width: number, height: number, stalenessMinutes: number, refreshCallback: (chunkX: number, chunkY: number, chunkWidth: number, chunkHeight: number) => Promise<any>, handleRefreshCallback: (chunkInfo: ChunkInfo, value: any) => void) {
    this.width = width;
    this.height = height;
    this.stalenessMinutes = stalenessMinutes;
    this.refreshCallback = refreshCallback;
    this.handleRefreshCallback = handleRefreshCallback;
    this.chunk_info = new Array(Math.ceil(this.width / CHUNK_WIDTH) * Math.ceil(this.height / CHUNK_HEIGHT));
  }

  stop (): void {
    this.disabled = true;
  }

  async update_at (x: number, y: number): Promise<void> {
    if (this.disabled || x < 0 || y < 0 || x > this.width || y > this.height) {
      return;
    }

    const chunkX = Math.floor(x / CHUNK_WIDTH);
    const chunkY = Math.floor(y / CHUNK_HEIGHT);
    const chunkIndex = chunkY * this.width + chunkX;

    if (!this.chunk_info[chunkIndex]) {
      this.chunk_info[chunkIndex] = new ChunkInfo(chunkX, chunkY, CHUNK_WIDTH, CHUNK_HEIGHT, this.stalenessMinutes);
    }

    if (!!this.chunk_info[chunkIndex].refresh_promise) {
      return;
    }

    this.chunk_info[chunkIndex].refresh_promise = this.refreshCallback(chunkX, chunkY, CHUNK_WIDTH, CHUNK_HEIGHT); // # TODO: remove width & height
    const data = await this.chunk_info[chunkIndex].refresh_promise;

    if (!this.disabled) {
      this.chunk_info[chunkIndex].update();
      this.handleRefreshCallback(this.chunk_info[chunkIndex], data);
    }
    this.chunk_info[chunkIndex].refresh_promise = null;
  }

  info_at (x: number, y: number): ChunkInfo | undefined {
    return this.chunk_info[Math.floor(y / CHUNK_HEIGHT) * this.width + Math.floor(x / CHUNK_WIDTH)]
  }
}
