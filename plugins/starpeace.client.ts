import _ from 'lodash';
import Client from '~/plugins/starpeace-client/client.coffee';

export default defineNuxtPlugin((nuxtApp) => {
  const client: Client = new Client(nuxtApp.$config.public.disableRightClick ?? true);

  return {
    provide: {
      starpeaceClient: client,

      translate: (key: string) => client.managers.translation_manager?.text(key) ?? key,

      format_percent: (value: number | string | undefined | null) =>  _.isNumber(value) ? `${Math.round(value * 100)}%` : '',
      format_money: (value: number | string | undefined | null) => _.isNumber(value) ? `$${Math.round(value).toLocaleString()}` : '',
      format_number: (value: number | string | undefined | null) => _.isNumber(value) ? value.toLocaleString() : '',

      debounce: (waitMs: number, callback: (any: any) => any): any => {
        return _.debounce(callback, waitMs, { leading: true, trailing: true });
      }
    }
  }
});
