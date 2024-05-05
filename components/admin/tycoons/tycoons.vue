<template lang='pug'>
.card.is-starpeace
  .card-header
    .card-header-title Tycoons
  .card-content.sp-menu-background.columns.m-0.p-0
    .column.is-narrow
      aside.menu.is-starpeace.tycoon-selection
        ul.menu-list
          li(v-for='tycoon in sortedTycoons')
            a(:class="{'is-active': tycoonId == tycoon.id}" @click.stop.prevent='switchTycoon(tycoon.id)')
              span {{ tycoon.name }}
              span.tag.is-primary.is-starpeace.ml-3(v-if='tycoon.admin') Admin
              span.tag.is-info.ml-3(v-else-if='tycoon.gameMaster') GM
              span.tag.is-danger.ml-3(v-if='tycoon.bannedAt') Banned

    .column.p-0
      .columns.m-0.p-0
        .column.is-narrow.actions-column
          .is-flex.is-flex-direction-column(v-if='selectedTycoon')
            button.button.is-starpeace(disabled) Change Username
            button.button.is-starpeace.mt-1(disabled) Rename Tycoon
            button.button.is-starpeace.mt-1(disabled) Reset Password
            button.button.is-starpeace.mt-3(:disabled='selectedTycoon.admin || !!selectedTycoon.bannedAt' @click.stop.prevent='makeGameMaster' v-if='!selectedTycoon.gameMaster') Make GM
            button.button.is-starpeace.mt-3(v-else @click.stop.prevent='removeGameMaster') Remove GM
            button.button.is-starpeace.mt-1(:disabled='selectedTycoon.admin || selectedTycoon.gameMaster' @click.stop.prevent='banTycoon' v-if='!selectedTycoon.bannedAt') Ban Tycoon
            button.button.is-starpeace.mt-1(v-else @click.stop.prevent='unbanTycoon') Unban Tycoon

        .column
          template(v-if='selectedTycoon')
            div
              span.sp-kv-key ID:
              span.sp-kv-value {{ selectedTycoon.id }}
            div
              span.sp-kv-key Username:
              span.sp-kv-value {{ selectedTycoon.username }}
            div
              span.sp-kv-key Name:
              span.sp-kv-value {{ selectedTycoon.name }}
            div
              span.sp-kv-key Admin:
              span.sp-kv-value
                template(v-if='selectedTycoon.admin') Yes
                template(v-else) No
            div
              span.sp-kv-key GM:
              span.sp-kv-value
                template(v-if='selectedTycoon.gameMaster') Yes
                template(v-else) No
            div
              span.sp-kv-key Banned:
              span.sp-kv-value
                template(v-if='selectedTycoon.bannedAt')
                  span {{ selectedTycoon.bannedAt }}
                  span.ml-1 by {{ selectedTycoon.bannedBy }}
                  span.ml-1 {{ selectedTycoon.bannedReason }}
                template(v-else)
                  span No

        .column.is-narrow
          aside.menu.is-starpeace.corporation-selection(v-if='selectedTycoon')
            ul.menu-list(v-if='corporationIdentifiers.length')
              li(v-for='identifier in corporationIdentifiers')
                a(:class="{'is-active': corporationId == identifier.id}" @click.stop.prevent='switchCorporation(identifier.id)')
                  span {{ identifier.name }}
            p.menu-label.px-3.py-2(v-else) No Corporations

        .column.is-narrow
          aside.menu.is-starpeace.company-selection(v-if='selectedTycoon')
            ul.menu-list(v-if='companyIdentifiers.length')
              li(v-for='identifier in companyIdentifiers')
                a(:class="{'is-active': companyId == identifier.id}" @click.stop.prevent='switchCompany(identifier.id)')
                  misc-company-seal-icon(:seal_id='identifier.sealId')
                  span.ml-2 {{ identifier.name }}
            p.menu-label.px-3.py-2(v-else) No Companies


      .columns.columns.p-0.my-0.mb-0.mt-4
        .column.is-narrow.actions-column
          .is-flex.is-flex-direction-column(v-if='selectedCorporationIdentifier')
            button.button.is-starpeace(disabled) Rename Corporation
            button.button.is-starpeace.mt-1(disabled) Rename Company
            button.button.is-starpeace.mt-3(disabled) Add Cash
            button.button.is-starpeace.mt-1(disabled) Remove Cash

        .column
          .corporation-container.is-flex.is-flex-direction-column(v-if='selectedCorporationIdentifier')
            span.name.p-2 {{ selectedCorporationIdentifier.name }}
            span.p-2.is-flex.is-flex-direction-column
              div
                span.sp-kv-key ID:
                span.sp-kv-value {{ selectedCorporationIdentifier.id }}
              div
                span.sp-kv-key Name:
                span.sp-kv-value {{ selectedCorporationIdentifier.name }}
              div
                span.sp-kv-key Planet ID:
                span.sp-kv-value {{ selectedCorporationIdentifier.planetId }}
              template(v-if='corporation')
                div
                  span.sp-kv-key Level ID:
                  span.sp-kv-value {{ corporation.levelId }}
                div
                  span.sp-kv-key Prestige:
                  span.sp-kv-value {{ corporation.prestige }}
                div
                  span.sp-kv-key Building Count:
                  span.sp-kv-value {{ corporation.buildingCount }}
                div
                  span.sp-kv-key Cash:
                  span.sp-kv-value {{ $format_money(corporation.cash) }}

        .column
          .company-container.is-flex.is-flex-direction-column(v-if='selectedCompanyIdentifier')
            span.name.p-2 {{ selectedCompanyIdentifier.name }}
            span.p-2.is-flex.is-flex-direction-column
              div
                span.sp-kv-key ID:
                span.sp-kv-value {{ selectedCompanyIdentifier.id }}
              div
                span.sp-kv-key Name:
                span.sp-kv-value {{ selectedCompanyIdentifier.name }}
              div
                span.sp-kv-key Seal ID:
                span.sp-kv-value {{ selectedCompanyIdentifier.sealId }}

</template>

<script lang='ts'>
import _ from 'lodash';

import Corporation from '~/plugins/starpeace-client/corporation/corporation';
import CorporationIdentifier from '~/plugins/starpeace-client/corporation/corporation-identifier';
import Tycoon from '~/plugins/starpeace-client/tycoon/tycoon';

declare interface AdminTycoonsData {
  tycoonId: string | undefined;

  corporationIdentifiers: Array<CorporationIdentifier>;
  corporationId: string | undefined;
  corporation: Corporation | undefined;
  companyId: string | undefined;
}

export default {
  props: {
    tycoonById: { type: Object, require: true }
  },

  data (): AdminTycoonsData {
    return {
      tycoonId: undefined,

      corporationIdentifiers: [],
      corporationId: undefined,
      corporation: undefined,
      companyId: undefined
    };
  },

  computed: {
    sortedTycoons (): Array<Tycoon> {
      return _.orderBy(Object.values(this.tycoonById), ['name'], ['asc']);
    },

    selectedTycoon (): Tycoon | undefined {
      return this.tycoonId ? this.tycoonById[this.tycoonId] : undefined;
    },
    selectedCorporationIdentifier (): any | undefined {
      return this.corporationIdentifiers.find(c => c.id === this.corporationId);
    },
    selectedCompanyIdentifier (): any | undefined {
      return this.companyIdentifiers.find(c => c.id === this.companyId);
    },

    companyIdentifiers (): Array<any> {
      return _.orderBy(this.corporation?.companies ?? [], ['name'], ['asc']);
    }
  },

  watch: {
    sortedTycoons: {
      immediate: true,
      handler () {
        if (!this.tycoonId && this.sortedTycoons.length > 0) {
          this.tycoonId = this.sortedTycoons[0].id;
        }
      }
    },
    selectedTycoon: {
      immediate: true,
      handler () {
        this.refreshDetails();
      }
    },
    selectedCorporationIdentifier: {
      immediate: true,
      handler () {
        this.refreshCorporation();
      }
    }
  },

  methods: {
    switchTycoon (tycoonId: string): void {
      if (this.tycoonId !== tycoonId) {
        this.tycoonId = tycoonId;
        this.corporationId = undefined;
        this.companyId = undefined;
      }
    },
    switchCorporation (corporationId: string): void {
      if (this.corporationId !== corporationId) {
        this.corporationId = corporationId;
        this.companyId = undefined;
      }
    },
    switchCompany (companyId: string): void {
      if (this.companyId !== companyId) {
        this.companyId = companyId;
      }
    },

    async refreshDetails (): Promise<void> {
      try {
        if (this.selectedTycoon?.id) {
          this.corporationIdentifiers = _.orderBy(await this.$starpeaceClient.api.corporationIdentifiersForTycoonId(this.selectedTycoon.id), ['name'], ['asc']);
          if (!this.corporationId && this.corporationIdentifiers.length) {
            this.corporationId = this.corporationIdentifiers[0].id;
          }
        }
      }
      catch (err) {
        console.error(err);
        this.corporationIdentifiers = [];
      }
    },

    async refreshCorporation (): Promise<void> {
      try {
        this.corporation = undefined;
        if (this.selectedCorporationIdentifier?.id) {
          this.$starpeaceClient.client_state.player.planet_id = this.selectedCorporationIdentifier.planetId;
          this.corporation = await this.$starpeaceClient.api.corporation_for_id(this.selectedCorporationIdentifier.id);

          if (!this.companyId && this.companyIdentifiers.length > 0) {
            this.companyId = this.companyIdentifiers[0].id;
          }
        }
      }
      catch (err) {
        console.error(err);
        this.corporationIdentifiers = [];
      }
    },

    async makeGameMaster (): Promise<void> {
      try {
        if (!!this.selectedTycoon && !this.selectedTycoon.admin && !this.selectedTycoon.bannedAt) {
          this.$emit('tycoon-changed', await this.$starpeaceClient.api.setTycoonRole(this.selectedTycoon.id, 'GM'));
        }
      }
      catch (err) {
        console.error(err);
      }
    },
    async removeGameMaster (): Promise<void> {
      try {
        if (!!this.selectedTycoon && this.selectedTycoon?.gameMaster) {
          this.$emit('tycoon-changed', await this.$starpeaceClient.api.removeTycoonRole(this.selectedTycoon.id, 'GM'));
        }
      }
      catch (err) {
        console.error(err);
      }
    },
    async banTycoon (): Promise<void> {
      try {
        if (!!this.selectedTycoon && !this.selectedTycoon.admin && !this.selectedTycoon.gameMaster && !this.selectedTycoon.bannedAt) {
          this.$emit('tycoon-changed', await this.$starpeaceClient.api.setTycoonBan(this.selectedTycoon.id));
        }
      }
      catch (err) {
        console.error(err);
      }
    },
    async unbanTycoon (): Promise<void> {
      try {
        if (!!this.selectedTycoon && !!this.selectedTycoon.bannedAt) {
          this.$emit('tycoon-changed', await this.$starpeaceClient.api.removeTycoonBan(this.selectedTycoon.id));
        }
      }
      catch (err) {
        console.error(err);
      }
    }
  }
}
</script>

<style lang='sass' scoped>
@import '~/assets/stylesheets/starpeace'
@import '~/assets/stylesheets/starpeace-variables'

.tycoon-selection,
.corporation-selection,
.company-selection
  border: 1px solid $sp-light-bg
  min-width: 20rem

.actions-column
  min-width: 18rem

.button
  letter-spacing: 0.1rem
  text-transform: uppercase

.corporation-container,
.company-container
  border: 1px solid $sp-light-bg

  .name
    background-color: $sp-light-bg
    color: #FFF

</style>
