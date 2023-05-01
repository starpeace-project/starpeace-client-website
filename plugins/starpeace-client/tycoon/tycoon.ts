import { DateTime }  from 'luxon';

import Corporation from '~/plugins/starpeace-client/corporation/corporation';

export default class Tycoon {
  id: string;
  username: string;
  name: string;
  corporations: Corporation[];

  as_of: DateTime;

  constructor (id: string, username: string, name: string, corporations: Corporation[]) {
    this.id = id;
    this.username = username;
    this.name = name;
    this.corporations = corporations;
    this.as_of = DateTime.now();
  }

  is_fresh (): boolean {
    // TODO: probably too slow, needed?
    return this.as_of && DateTime.now() < this.as_of.plus({ minutes: 15 });
  }

  static from_json (json: any): Tycoon {
    return new Tycoon(
      json.id,
      json.username,
      json.name,
      (json.corporations ?? []).map(Corporation.from_json)
    );
  }
}


