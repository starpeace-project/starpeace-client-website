import { DateTime } from "luxon";

export default class CorporationPrestigeHistory {
  id: string;
  createdAt: DateTime;
  label: string;
  prestige: number;

  constructor (id: string, createdAt: DateTime, label: string, prestige: number) {
    this.id = id;
    this.createdAt = createdAt;
    this.label = label;
    this.prestige = prestige;
  }

  static fromJson (json: any): CorporationPrestigeHistory {
    return new CorporationPrestigeHistory(
      json.id,
      DateTime.fromISO(json.createdAt),
      json.label,
      json.prestige ?? 0
    );
  }
}
