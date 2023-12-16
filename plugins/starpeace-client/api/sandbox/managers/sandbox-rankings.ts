import _ from 'lodash';

import SandboxCorporation from '~/plugins/starpeace-client/api/sandbox/managers/sandbox-corporation.js';
import SandboxMetadata from '~/plugins/starpeace-client/api/sandbox/managers/sandbox-metadata.js';

const maximumRankingValue = (type: string): number => {
  switch (type) {
    case 'CORPORATION': return 15000;
    case 'PROFIT': return 1000000000;
    case 'PRESTIGE': return 1000;
    case 'WEALTH': return 1000000000000;
    default: return 0;
  }
};

export default class SandboxRankings {
  rankingsByPlanetIdTypeId: Record<string, Record<string, any>>;

  constructor (rankingsByPlanetIdTypeId: Record<string, Record<string, any>>) {
    this.rankingsByPlanetIdTypeId = rankingsByPlanetIdTypeId;
  }

  static createRankings (metadata: SandboxMetadata, corporation: SandboxCorporation): Record<string, Record<string, any>> {
    const rankingsByPlanetIdTypeId: Record<string, Record<string, any>> = {};
    for (const planetId of ['planet-1', 'planet-2', 'planet-3']) {
      rankingsByPlanetIdTypeId[planetId] = {};

      const corporations = Object.values(corporation.corporationById).filter((corporation) => corporation.planetId === planetId);

      for (const rankingType of metadata.core.rankingTypes) {
        const maxValue = maximumRankingValue(rankingType.type);
        if (maxValue <= 0) {
          continue;
        }

        const orderedRankings = _.orderBy(corporations.map((corp) => {
          return {
            rank: 0,
            value: Math.round(maxValue * Math.random()),
            tycoonId: corp.tycoonId,
            tycoonName: corporation.tycoonById[corp.tycoonId].name,
            corporationId: corp.id,
            corporationName: corp.name
          };
        }), ['value'], ['desc']);

        for (let index = 0; index < orderedRankings.length; index++) {
          orderedRankings[index].rank = index + 1;
        }

        rankingsByPlanetIdTypeId[planetId][rankingType.id] = orderedRankings;
      }
    }
    return rankingsByPlanetIdTypeId;
  }

  static create (metadata: SandboxMetadata, corporation: SandboxCorporation): SandboxRankings {
    return new SandboxRankings(
      SandboxRankings.createRankings(metadata, corporation)
    );
  }
}
