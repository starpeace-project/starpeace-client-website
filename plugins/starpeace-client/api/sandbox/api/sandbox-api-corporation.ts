import _ from 'lodash';
import { DateTime } from 'luxon';

import SandboxApiAdapter from '~/plugins/starpeace-client/api/sandbox/api/sandbox-api-adapter';


export default class SandboxApiCorporation {

  static configure (adapter: SandboxApiAdapter, sandbox: any): void {

    adapter.get('corporations/(.+?)/rankings', (_config: any, corporation_id: string): any => {
      return sandbox.sandbox_data.metadata.core.rankingTypes.map((t: any) => {
        return {
          rankingTypeId: t.id,
          rank: Math.random() > 0.5 ? Math.ceil(Math.random() * 50) : 0
        };
      });
    });
    adapter.get('corporations/(.+?)/prestige-history', (_config: any, corporation_id: string): any => {
      const corporation: any = sandbox.sandbox_data.corporation.corporationById[corporation_id];
      const currentTime = sandbox.sandbox_data.planet_id_dates[corporation.planetId].toISO();
      return _.cloneDeep([{
        id: 'id-1',
        createdAt: '2200-01-01',
        label: 'history.prestige.planet.joined',
        prestige: 5
      },
      {
        id: 'id-2',
        createdAt: currentTime ?? '2250-01-01',
        label: 'history.prestige.research',
        prestige: 100
      },
      {
        id: 'id-3',
        createdAt: currentTime ?? '2250-01-01',
        label: 'history.prestige.empire',
        prestige: 100
      }, {
        id: 'id-4',
        createdAt: '2210-01-01',
        label: 'history.prestige.promotion',
        prestige: 5
      }, {
        id: 'id-6',
        createdAt: '2215-01-01',
        label: 'history.prestige.planet.mayor.term',
        prestige: 300
      }, {
        id: 'id-7',
        createdAt: '2220-01-01',
        label: 'history.prestige.planet.mayor.fired',
        prestige: 300
      }]);
    });
    adapter.get('corporations/(.+?)/loan-payments', (_config: any, corporation_id: string): any => {
      const corporation: any = sandbox.sandbox_data.corporation.corporationById[corporation_id];
      const currentTime = sandbox.sandbox_data.planet_id_dates[corporation.planetId];
      return _.cloneDeep([{
        id: 'loan-id-1',
        bankerType: 'IFEL',
        createdAt: '2200-01-01',
        nextPaymentAt: currentTime.plus({month: 2}).toISO(),
        nextPaymentAmount: 10000000,
        principleBalance: 300000000,
        termYears: 150,
        interestRate: 0.04
      }, {
        id: 'loan-id-2',
        bankerType: 'IFEL',
        createdAt: '2220-01-01',
        nextPaymentAt: currentTime.plus({month: 6}).toISO(),
        nextPaymentAmount: 8000000,
        principleBalance: 150000000,
        termYears: 70,
        interestRate: 0.08
      }]);
    });
    adapter.get('corporations/(.+?)/loan-offers', (_config: any, corporation_id: string): any => {
      return _.cloneDeep([{
        id: 'loan-offer-1',
        bankerType: 'IFEL',
        maxAmount: 200000000,
        maxTermYears: 150,
        interestRate: 0.0655
      }]);
    });
    adapter.get('corporations/(.+?)/strategies', (_config: any, corporation_id: string): any => {
      return _.cloneDeep(sandbox.sandbox_data.corporation.strategiesByCorporationId[corporation_id] ?? []);
    });

    adapter.get('corporations/(.+?)/bookmarks', (_config: any, corporation_id: string): any => {
      return sandbox.sandbox_bookmarks.get_bookmarks(corporation_id);
    });
    adapter.post('corporations/(.+?)/bookmarks', (_config: any, corporation_id: string, parameters: any): any => {
      return sandbox.sandbox_bookmarks.create_bookmark(corporation_id, parameters);
    });
    adapter.patch('corporations/(.+?)/bookmarks', (_config: any, corporation_id: string, parameters: any): any => {
      return sandbox.sandbox_bookmarks.update_bookmarks(corporation_id, parameters.deltas);
    });

    adapter.get('corporations/(.+?)/mail', (_config: any, corporation_id: string): any => {
      return sandbox.sandbox_mail.get(corporation_id);
    });
    adapter.post('corporations/(.+?)/mail', (_config: any, corporation_id: string, parameters: any): any => {
      return sandbox.sandbox_mail.create(corporation_id, parameters);
    });
    adapter.put('corporations/(.+?)/mail/(.+)/mark-read', (_config: any, corporation_id: string, mail_id: string): any => {
      return sandbox.sandbox_mail.mark_read(corporation_id, mail_id);
    });
    adapter.delete('corporations/(.+?)/mail/(.+)', (_config: any, corporation_id: string, mail_id: string): any => {
      return sandbox.sandbox_mail.delete(corporation_id, mail_id);
    });

    adapter.post('corporations', (_config: any, params: any): any => {
      throw new Error('500');
    });
    adapter.get('corporations/(.+)', (_config: any, corporation_id: string): any => {
      if (!sandbox.sandbox_data?.corporation.corporationById?.[corporation_id]) {
        throw new Error('404');
      }
      const corporation: any = _.cloneDeep(sandbox.sandbox_data.corporation.corporationById[corporation_id]);
      corporation.cashAsOf = sandbox.sandbox_data.planet_id_dates[corporation.planetId].toISO();
      corporation.cash = sandbox.sandbox_data.corporation.cashflowByCorporationId[corporation_id]?.cash ?? 0;
      corporation.cashCurrentYear = sandbox.sandbox_data.corporation.cashflowByCorporationId[corporation_id]?.cashCurrentYear ?? 0;
      corporation.prestige = Math.ceil(Math.random() * 200);
      return corporation;
    });

  }
}
