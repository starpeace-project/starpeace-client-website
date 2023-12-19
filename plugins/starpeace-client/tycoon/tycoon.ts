import { DateTime }  from 'luxon';

import Corporation from '~/plugins/starpeace-client/corporation/corporation';

export interface TycoonInterface {
  id: string;
  username: string;
  name: string;
  corporations: Corporation[];

  admin: boolean;
  gameMaster: boolean;

  bannedAt?: DateTime | undefined;
  bannedBy?: string | undefined;
  bannedReason?: string | undefined;
}

export default class Tycoon {
  id: string;
  username: string;
  name: string;
  corporations: Corporation[];

  admin: boolean;
  gameMaster: boolean;

  bannedAt: DateTime | undefined;
  bannedBy: string | undefined;
  bannedReason: string | undefined;

  constructor (parameters: TycoonInterface) {
    this.id = parameters.id;
    this.username = parameters.username;
    this.name = parameters.name;
    this.corporations = parameters.corporations;
    this.admin = parameters.admin ?? false;
    this.gameMaster = parameters.gameMaster ?? false;
    this.bannedAt = parameters.bannedAt;
    this.bannedBy = parameters.bannedBy;
    this.bannedReason = parameters.bannedReason;
  }

  static from_json (json: any): Tycoon {
    return new Tycoon({
      id: json.id,
      username: json.username,
      name: json.name,
      corporations: (json.corporations ?? []).map(Corporation.from_json),
      admin: json.admin,
      gameMaster: json.gameMaster,
      bannedAt: json.bannedAt ? DateTime.fromISO(json.bannedAt) : undefined,
      bannedBy: json.bnnedBy,
      bannedReason: json.bannedReason
    });
  }
}


