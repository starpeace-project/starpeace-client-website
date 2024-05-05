import ChunkMap from '~/plugins/starpeace-client/map/chunk/chunk-map';

import type OverlayManager from '~/plugins/starpeace-client/overlay/overlay-manager';
import type OverlayType from '~/plugins/starpeace-client/overlay/overlay-type';
import type ClientState from '~/plugins/starpeace-client/state/client-state';

import Logger from '~/plugins/starpeace-client/logger';

export default class OverlayMap {
  clientState: ClientState;
  overlayManager: OverlayManager;

  width: number;
  height: number;

  overlayData: Record<string, any> = {};
  chunks: Record<string, any> = {};

  constructor (clientState: ClientState, overlayManager: OverlayManager, width: number, height: number) {
    this.clientState = clientState;
    this.overlayManager = overlayManager;
    this.width = width;
    this.height = height;

    for (const typeId of ['ZONES', 'TOWNS', ...this.clientState.core.planet_library.allOverlayTypes().map((t: OverlayType) => t.id)]) {
      this.overlayData[typeId] = new Array(this.width * this.height);
      this.chunks[typeId] = new ChunkMap(this.width, this.height, 5, (chunkX: number, chunkY: number) => this.overlayManager.load_chunk(typeId, chunkX, chunkY), (chunkInfo: any, data: any) => {
        Logger.debug(`Refreshing overlay chunk for ${typeId} at ${chunkInfo.chunk_x}x${chunkInfo.chunk_y}`);

        const offsetChunkX = chunkInfo.x_offset();
        const offsetChunkY = chunkInfo.y_offset();
        for (let y = 0; y < ChunkMap.CHUNK_HEIGHT; y++) {
          for (let x = 0; x < ChunkMap.CHUNK_WIDTH; x++) {
            this.overlayData[typeId][(y + offsetChunkY) * this.width + (x + offsetChunkX)] = data[y * ChunkMap.CHUNK_WIDTH + x];
          }
        }

        this.clientState.planet.notify_map_data_listeners({ type: 'overlay', info: chunkInfo });
      });
    }
  }

  stop (): void {
    for (const chunk of Object.values(this.chunks)) {
      chunk.stop();
    }
  }

  chunk_update_at (type: string, x: number, y: number): void {
    this.chunks[type]?.update_at(x, y);
  }
  chunk_info_at (type: string, x: number, y: number): any {
    return this.chunks[type]?.info_at(x, y);
  }

  overlay_at (type: string, x: number, y: number): any {
    return this.overlayData[type]?.[y * this.width + x];
  }
}
