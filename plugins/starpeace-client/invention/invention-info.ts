
export default class InventionInfo {
  metadata: any;

  upstream_ids: Array<any> | null = null;
  downstream_ids: Array<any> | null = null;

  constructor (metadata: any) {
    this.metadata = metadata;
  }

  is_related (link: any): boolean {
    return !!this.upstream_ids?.[link.source] && !!this.upstream_ids?.[link.target] || !!this.downstream_ids?.[link.source] && !!this.downstream_ids?.[link.target];
  }
}
