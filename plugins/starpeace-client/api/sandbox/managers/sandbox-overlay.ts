
export const TYPES = [
  'ZONES', 'BEAUTY', 'HC_RESIDENTIAL', 'MC_RESIDENTIAL', 'LC_RESIDENTIAL', 'QOL',
  'CRIME', 'POLLUTION', 'BAP', 'FRESH_FOOD', 'PROCESSED_FOOD', 'CLOTHES', 'APPLIANCES',
  'CARS', 'RESTAURANTS', 'BARS', 'TOYS', 'DRUGS', 'MOVIES', 'GASOLINE', 'COMPUTERS',
  'FURNITURE', 'BOOKS', 'COMPACT_DISCS', 'FUNERAL_PARLORS'
];

interface ChunkInfo {
  chunkX: number;
  chunkY: number;
  width: number;
  height: number;
  data: ArrayBuffer;
}

export default class SandboxOverlays {
  emptyChunKData: ArrayBuffer;
  chunkInfoByKey: Record<string, ChunkInfo>;

  constructor (emptyChunKData: ArrayBuffer, chunkInfoByKey: Record<string, ChunkInfo>) {
    this.emptyChunKData = emptyChunKData;
    this.chunkInfoByKey = chunkInfoByKey;
  }

  static create (): SandboxOverlays {
    const chunkDataByKey: Record<string, ChunkInfo> = {};

    for (const type of TYPES) {
      for (let chunkY = 2; chunkY < 9; chunkY++) {
        for (let chunkX = 8; chunkX < 14; chunkX++) {

          let typeData: ArrayBuffer;
          if (type === 'ZONES') {
            const rawValues = "1111122222333334444411111222223333344444111112222233333444441111122222333334444411111222223333344444" +
                "5555566666777778888855555666667777788888555556666677777888885555566666777778888855555666667777111888" +
                "9999900000000012100099999000000000111000999990000000000000009999900000000000000099999000000000000000" +
                "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
            typeData = Uint8Array.from(rawValues.split("").map(parseInt)).buffer;
          }
          else {
            const magnitude = 0.5 + 0.5 * Math.random();
            const data = new Array(20 * 20);
            for (let y = 0; y < 20; y++) {
              for (let x = 0; x < 20; x++) {
                const distance = Math.sqrt((10 - x) * (10 - x) + (10 - y) * (10 - y));
                data[y * 20 + x] = Math.round(255 * (1 - Math.min(1, magnitude * (distance / 10))));
              }
            }
            typeData = Uint8Array.from(data).buffer;
          }

          chunkDataByKey[`${type}x${chunkX}x${chunkY}`] = {
            chunkX: chunkX,
            chunkY: chunkY,
            width: 20,
            height: 20,
            data: typeData
          };
        }
      }
    }

    const emptyChunKData = Uint8Array.from(("0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" +
        "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" +
        "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" +
        "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000").split("").map(parseInt)).buffer;

    return new SandboxOverlays(emptyChunKData, chunkDataByKey);
  }
}