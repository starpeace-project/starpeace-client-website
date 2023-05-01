import Tycoon from '~/plugins/starpeace-client/tycoon/tycoon'

export default class TycoonManager {
  apiClient: any;
  ajaxState: any;
  clientState: any;

  constructor (apiClient: any, ajaxState: any, clientState: any) {
    this.apiClient = apiClient;
    this.ajaxState = ajaxState;
    this.clientState = clientState;
  }

  async load_metadata_by_tycoon_id (tycoonId: string): Promise<Tycoon> {
    if (!this.clientState.has_session() || !tycoonId) throw Error();
    const tycoon: Tycoon | null = this.clientState.core.tycoon_cache.metadata_for_id(tycoonId);
    if (tycoon) return tycoon;

    return await this.ajaxState.locked('tycoon_metadata', tycoonId, async () => {
      const tycoonJson: any = await this.apiClient.tycoon_for_id(tycoonId);
      const tycoon: Tycoon = Tycoon.from_json(tycoonJson);

      this.clientState.core.tycoon_cache.set_tycoon_metadata(tycoon)
      // this.clientState.core.corporation_cache.load_tycoon_corporations(tycoon.id, tycoon.corporations)
      // for (const corporation of tycoon.corporations) {
      //   this.clientState.core.company_cache.load_companies_metadata(corporation.companies);
      // }

      return tycoon;
    });
  }

}
