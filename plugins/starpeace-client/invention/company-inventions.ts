
export default class CompanyInventions {
  companyId: string;
  completedIds: Set<string>;
  activeInventionId: string | null;
  activeInvestment: number;
  pendingIds: Array<string>;
  canceledIds: Set<string>;

  constructor (companyId: string, completedIds: Set<string>, activeInventionId: string | null, activeInvestment: number, pendingIds: Array<string>, canceledIds: Set<string>) {
    this.companyId = companyId;
    this.completedIds = completedIds;
    this.activeInventionId = activeInventionId;
    this.activeInvestment = activeInvestment;
    this.pendingIds = pendingIds;
    this.canceledIds = canceledIds;
  }

  isActive (): boolean {
    return !!this.activeInventionId || this.pendingIds.length > 0 || this.canceledIds.size > 0;
  }

  isQueued (inventionId: string): boolean {
    return this.activeInventionId === inventionId || this.pendingIds.indexOf(inventionId) >= 0;
  }
  isCompleted (inventionId: string): boolean {
    return this.completedIds.has(inventionId);
  }

  static fromJson (json: any): CompanyInventions {
    return  new CompanyInventions(
      json.companyId,
      new Set(json.completedIds ?? []),
      json.activeId ?? null,
      json.activeInvestment ?? 0,
      json.pendingIds ?? [],
      new Set(json.canceledIds ?? [])
    );
  }

  static create (companyId: string): CompanyInventions {
    return new CompanyInventions(companyId, new Set(), null, 0, [], new Set());
  }
}
