import _ from 'lodash';

import { CompanySeal, IndustryCategory, InventionDefinition, ResourceType, ResourceUnit, Translation } from '@starpeace/starpeace-assets-types';

import Client from '~/plugins/starpeace-client/client.js';

export default defineNuxtPlugin((nuxtApp) => {
  const client: Client = new Client(nuxtApp.$config.public.disableRightClick ?? true);

  const translate = (key: Translation | string | undefined): string | undefined => {
    return key ? client.managers.translation_manager?.text(key) : undefined
  };

  const formatPercent = (value: number | undefined | null, denomator: number | undefined = undefined): string => {
    if (denomator !== undefined) {
      value = denomator == 0 ? 0 : (value ?? 0) / denomator;
    }
    return `${Math.round((value ?? 0) * 100)}%`;
  };


  const resourceType = (typeId: string): ResourceType | undefined => {
    return client.client_state.core.planet_library.resource_type_for_id(typeId);
  };
  const resourceTypeUnit = (unitId: string): ResourceUnit | undefined => {
    return client.client_state.core.planet_library.resource_unit_for_id(unitId);
  };
  const industryCategory = (categoryId: string): IndustryCategory | undefined => {
    return client.client_state.core.planet_library.category_for_id(categoryId);
  };
  const companySeal = (sealId: string): CompanySeal | undefined => {
    return client.client_state.core.planet_library.seal_for_id(sealId);
  };
  const invention = (inventionId: string): InventionDefinition | undefined => {
    return client.client_state.core.invention_library.metadata_for_id(inventionId);
  }

  return {
    provide: {
      starpeaceClient: client,

      translate: translate,

      formatPercent: formatPercent,
      format_money: (value: number | string | undefined | null) => _.isNumber(value) ? `$${Math.round(value).toLocaleString()}` : '',
      format_number: (value: number | string | undefined | null) => _.isNumber(value) ? value.toLocaleString() : '',

      debounce: (waitMs: number, callback: (...args : any[]) => any): any => {
        return _.debounce(callback, waitMs, { leading: true, trailing: true });
      },

      resourceType: resourceType,
      resourceTypeLabel (typeId: string): string {
        return translate(resourceType(typeId)?.labelPlural) ?? typeId;
      },
      resourceTypeUnit: resourceTypeUnit,
      resourceTypeUnitLabel (typeId: string): string {
        const unitId: string | undefined = resourceType(typeId)?.unitId;
        return (unitId ? translate(resourceTypeUnit(unitId)?.labelPlural) : undefined) ?? typeId;
      },
      resourceTypePrice (typeId: string): number {
        return resourceType(typeId)?.price ?? 0;
      },
      industryCategory: industryCategory,
      industryCategoryLabel (categoryId: string): string {
        return translate(industryCategory(categoryId)?.label) ?? categoryId;
      },
      companySeal: companySeal,
      companySealShortLabel (sealId: string): string {
        return translate(companySeal(sealId)?.nameShort) ?? sealId;
      },
      companySealLongLabel (sealId: string): string {
        return translate(companySeal(sealId)?.nameLong) ?? sealId;
      },
      invention: invention,
      inventionLabel (inventionId: string): string {
          return translate(invention(inventionId)?.name) ?? inventionId;
      }
    }
  }
});
