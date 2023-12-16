import Vue from 'vue'

import { Translation } from '@starpeace/starpeace-assets-types';

declare module 'vue/types/vue' {
  interface Vue {
    $translate: (key: Translation | string | undefined) => string | undefined;
  }
}
