
const ROAD_X_START = 190;
const ROAD_X_END = 250;
const ROAD_Y_START = 50;
const ROAD_Y_END = 400;

export default class SandboxRoads {
  emptyBuffer: ArrayBuffer;
  chunkDataByKey: Record<string, Uint8Array>;

  constructor (emptyBuffer: ArrayBuffer, chunkDataByKey: Record<string, Uint8Array>) {
    this.emptyBuffer = emptyBuffer;
    this.chunkDataByKey = chunkDataByKey;
  }

  static create (): SandboxRoads {
    const roadChunkData: Record<string, Uint8Array> = {};
    for (let y = ROAD_Y_START; y <= ROAD_Y_END; y++) {
      for (let x = ROAD_X_START; x <= ROAD_X_END; x++) {
        const x_line = (x - 190) % 20 == 0;
        const y_line = y % 10 == 0;

        if (!x_line && !y_line) {
          continue;
        }

        const chunk_x = Math.floor(x / 20);
        const chunk_y = Math.floor(y / 20);
        const chunk_key = `${chunk_x}x${chunk_y}`;
        if (!roadChunkData[chunk_key]) {
          roadChunkData[chunk_key] = new Uint8Array(20 * 20);
        }

        const has_n: number = x_line && y > ROAD_Y_START ? 1 : 0;
        const has_e: number = y_line && x < ROAD_X_END ? 1 : 0;
        const has_s: number = x_line && y < ROAD_Y_END ? 1 : 0;
        const has_w: number = y_line && x > ROAD_X_START ? 1 : 0;

        const index = 20 * (y - chunk_y * 20) + (x - chunk_x * 20);
        roadChunkData[chunk_key][index] = ((has_n & 0x01) << 0) | ((has_e & 0x01) << 1) | ((has_s & 0x01) << 2) | ((has_w & 0x01) << 3);
      }
    }


    const chunkDataByKey: Record<string, Uint8Array> = {};
    for (const chunkKey of Object.keys(roadChunkData)) {
      chunkDataByKey[chunkKey] = new Uint8Array(roadChunkData[chunkKey].length * .5);
      for (let index = 0; index < chunkDataByKey[chunkKey].length; index++) {
        chunkDataByKey[chunkKey][index] = ((roadChunkData[chunkKey][index * 2 + 0] & 0x0F) << 4) | ((roadChunkData[chunkKey][index * 2 + 1] & 0x0F) << 0);
      }
    }

    return new SandboxRoads(new Uint8Array(20 * 20 * .5).buffer, chunkDataByKey);
  }
}