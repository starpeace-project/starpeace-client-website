<template lang='pug'>
.research-list-container.sp-scrollbar
  .status-title.sp-kv-key.mb-1.pb-1 {{ $translate('ui.menu.research.status.available') }}
  ul
    template(v-if='availableResearch.length')
      li(v-for='research in availableResearch')
        a(@click.stop.prevent='selectInvention(research.id)') {{ $translate(research.name) }}

    template(v-else)
      li {{ $translate('ui.menu.research.none.label') }}


  .status-title.sp-kv-key.mt-3.mb-1.pb-1 {{ $translate('ui.menu.research.status.in_progress') }}
  ul
    template(v-if='pendingResearch.length')
      li(v-for='research in pendingResearch')
        a(@click.stop.prevent='selectInvention(research.id)') {{ $translate(research.name) }}

    template(v-else)
      li {{ $translate('ui.menu.research.none.label') }}


  .status-title.sp-kv-key.mt-3.mb-1.pb-1 {{ $translate('ui.menu.research.status.completed') }}
  ul
    template(v-if='completedResearch.length')
      li(v-for='research in completedResearch')
        a(@click.stop.prevent='selectInvention(research.id)') {{ $translate(research.name) }}

    template(v-else)
      li {{ $translate('ui.menu.research.none.label') }}

</template>

<script lang='ts'>
import _ from 'lodash';

import CompanyInventions from '~/plugins/starpeace-client/invention/company-inventions';
import InventionDefintion from '~/plugins/starpeace-client/invention/invention-definition';
import ClientState from '~/plugins/starpeace-client/state/client-state';

interface ResearchState {
  available: Array<any>;
  pending: Array<any>;
  completed: Array<any>;
}

export default {
  props: {
    clientState: { type: ClientState, required: true },

    connectedInventionDefinitions: { type: Array<InventionDefintion>, required: true },
    companyInventions: { type: CompanyInventions, required: false }
  },

  computed: {
    selected_category_id (): string | null { return this.clientState.interface?.inventions_selected_category_id; },
    selected_industry_type_id (): string | null { return this.clientState.interface?.inventions_selected_industry_type_id; },
    selected_invention_id (): string | null { return this.clientState.interface?.inventions_selected_invention_id; },

    companyId (): string | null {
      return this.clientState.player.company_id;
    },

    companyResearch () {
      const research: ResearchState = {
        available: [],
        pending: [],
        completed: []
      };

      for (const invention of this.connectedInventionDefinitions) {
        if (this.companyInventions?.completedIds?.has(invention.id)) {
          research.completed.push({ id: invention.id, name: invention.name });
        }
        else if (this.companyInventions?.isQueued(invention.id)) {
          research.pending.push({ id: invention.id, name: invention.name });
        }
        else {
          research.available.push({ id: invention.id, name: invention.name });
        }
      }

      return {
        available: _.sortBy(research.available, (invention) => invention.text),
        in_progress: research.pending,
        completed: _.sortBy(research.completed, (invention) => invention.text)
      };
    },

    availableResearch (): Array<any> {
      return this.companyResearch?.available ?? [];
    },
    pendingResearch (): Array<any> {
      return this.companyResearch?.in_progress ?? [];
    },
    completedResearch (): Array<any> {
      return this.companyResearch?.completed ?? [];
    }
  },

  methods: {
    selectInvention (invention_id: string) {
      // TODO: move to method/event
      this.clientState.interface.inventions_selected_invention_id = invention_id;
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace-variables'

.research-list-container
  overflow-y: scroll
  padding: 1rem .5rem 0
  width: 20rem

  .status-title
    border-bottom: 1px solid $sp-primary

</style>
