import SandboxMetadata from '~/plugins/starpeace-client/api/sandbox/managers/sandbox-metadata.js';

const COMMERCE_TAX_CATEGORY_IDS = new Set(['COMMERCE', 'INDUSTRY', 'LOGISTICS', 'REAL_ESTATE', 'SERVICE']);
const COMMERCE_TAX_SKIPPED_INDUSTRY_IDS = new Set(['HEADQUARTERS', 'MAUSOLEUM']);

const SERVICE_TYPES = ['COLLEGE', 'GARBAGE', 'FIRE', 'HOSPITAL', 'PRISON', 'MUSEUM', 'POLICE', 'SCHOOL', 'PARK'];
const RATING_TYPES = SERVICE_TYPES.concat(['TAX_REVENUE', 'EMPLOYMENT', 'POPULATION_GROWTH', 'ECONOMIC_GROWTH']);

interface GovernmentDetails {
  qol: number;
  services: Array<any>;
  commerce: Array<any>;
  taxes: Array<any>;
  population: Array<any>;
  employment: Array<any>;
  housing: Array<any>;

  currentTerm: any;
  nextTerm: any;
}

export default class SandboxGovernment {
  planet: GovernmentDetails;
  detailsByTownId: Record<string, GovernmentDetails>;

  constructor (planet: GovernmentDetails, detailsByTownId: Record<string, GovernmentDetails>) {
    this.planet = planet;
    this.detailsByTownId = detailsByTownId;
  }

  static createDetails (commerceTypes: Array<any>, taxTypes: Array<any>): GovernmentDetails {
    return {
      qol: Math.random(),
      services: SERVICE_TYPES.map((t) => {
        return {
          typeId: t,
          value: Math.random()
        }
      }),
      commerce: commerceTypes.map((t) => {
        return {
          industryTypeId: t,
          demand: 0,
          supply: 0,
          capacity: 0,
          ratio: Math.random(),
          ifelPrice: 0,
          averagePrice: 0,
          quality: 0
        };
      }),
      taxes: taxTypes.map((t) => {
        return {
          industryCategoryId: t.c,
          industryTypeId: t.t,
          taxRate: Math.random(),
          lastYear: 0
        };
      }),
      population: [
        {
          typeId: "EXECUTIVE",
          population: 0,
          unemployed: 0,
          homeless: 0
        },
        {
          typeId: "PROFESSIONAL",
          population: 0,
          unemployed: 0,
          homeless: 0
        },
        {
          typeId: "WORKER",
          population: 0,
          unemployed: 0,
          homeless: 0
        }
      ],
      employment: [
        {
          typeId: "EXECUTIVE",
          vacancies: 0,
          spendingPower: .8,
          averageWage: 1,
          minimumWage: 1
        }, {
          typeId: "PROFESSIONAL",
          vacancies: 0,
          spendingPower: .25,
          averageWage: 1,
          minimumWage: 1
        }, {
          typeId: "WORKER",
          vacancies: 0,
          spendingPower: .05,
          averageWage: 1,
          minimumWage: 1,
        }
      ],
      housing: [
        {
          typeId: "EXECUTIVE",
          vacancies: 0,
          averageRent: 1,
          qualityIndex: Math.random()
        },
        {
          typeId: "PROFESSIONAL",
          vacancies: 0,
          averageRent: 1,
          qualityIndex: Math.random()
        },
        {
          typeId: "WORKER",
          vacancies: 0,
          averageRent: 1,
          qualityIndex: Math.random()
        }
      ],
      currentTerm: {
        start: '2230-01-01',
        end: '2240-01-01',
        length: 120,
        politician: Math.random() < 0.5 ? undefined : {
          id: 'tycoon-id-1',
          name: 'Tycoon Name',
          prestige: 300,
          terms: 1
        },
        overallRating: Math.random(),
        serviceRatings: RATING_TYPES.map((t) => {
          return {
            type: t,
            delta: Math.round((Math.random() - .5) * 100),
            rating: Math.random()
          };
        })
      },
      nextTerm: {
        start: '2240-01-01',
        end: '2250-01-01',
        length: 120,
        candidates: Math.random() < 0.75 ? [] : [
          {
            id: 'tycoon-id-1',
            name: 'Tycoon Name',
            prestige: 300,
            votes: 2
          }
        ]
      }
    };
  }

  static create (metadata: SandboxMetadata, townIds: Array<any>): SandboxGovernment {
    const typesByCategorieId: Record<string, Set<string>> = {};
    for (const definition of metadata.building.definitions) {
      if (!COMMERCE_TAX_CATEGORY_IDS.has(definition.industryCategoryId)) {
        continue;
      }
      if (COMMERCE_TAX_SKIPPED_INDUSTRY_IDS.has(definition.industryTypeId)) {
        continue;
      }

      if (!typesByCategorieId[definition.industryCategoryId]) {
        typesByCategorieId[definition.industryCategoryId] = new Set();
      }
      typesByCategorieId[definition.industryCategoryId].add(definition.industryTypeId);
    }

    const commerceTypes = Array.from(typesByCategorieId['COMMERCE'] ?? []);
    const taxTypes = [];
    for (const [category, types] of Object.entries(typesByCategorieId)) {
      for (const type of Array.from(types)) {
        taxTypes.push({ c: category, t: type });
      }
    }

    const detailsByTownId: Record<string, GovernmentDetails> = {};
    for (const townId of townIds) {
      detailsByTownId[townId] = SandboxGovernment.createDetails(commerceTypes, taxTypes);
    }
    return new SandboxGovernment(SandboxGovernment.createDetails(commerceTypes, taxTypes), detailsByTownId);
  }
}