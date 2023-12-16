import _ from 'lodash';
import { markRaw } from 'vue';

import EventListener from '~/plugins/starpeace-client/state/event-listener'
import CompanyInventions from '~/plugins/starpeace-client/invention/company-inventions'

export default class CorporationState {
  event_listener = new EventListener();

  company_ids: Array<string> | null = null;

  last_mail_at: any | null = null;
  cash: number | null = null;
  cashflow: number | null = null;
  cashflow_by_company_id: Record<string, number> = {};

  buildings_ids_by_company_id: Record<string, Array<string>> = {}
  inventions_metadata_by_company_id: Record<string, CompanyInventions> = {}

  constructor () {
    this.event_listener = markRaw(new EventListener());
  }

  reset_state () {
    this.company_ids = null

    this.last_mail_at = null
    this.cash = null
    this.cashflow = null
    this.cashflow_by_company_id = {}

    this.buildings_ids_by_company_id = {}
    this.inventions_metadata_by_company_id = {}
  }

  has_data (): boolean {
    if (!this.company_ids || this.cash === null || this.cashflow === null) {
      return false;
    }
    for (const companyId of this.company_ids) {
      if (this.cashflow_by_company_id[companyId] === undefined || !this.buildings_ids_by_company_id[companyId] || !this.inventions_metadata_by_company_id[companyId]) {
        return false;
      }
    }
    return true;
  }

  company_ids_with_pending_inventions (): Array<string> {
    return (this.company_ids ?? []).filter((id) => this.inventions_metadata_by_company_id[id]?.isActive());
  }
  completed_invention_ids_for_company (companyId: string): Array<string> {
    return Array.from(this.inventions_metadata_by_company_id[companyId]?.completedIds ?? new Set<string>());
  }

  subscribe_company_ids_listener (callback: () => void): void {
    this.event_listener.subscribe('corporation.company_ids', callback);
  }
  notify_company_ids_listeners (): void {
    this.event_listener.notify_listeners('corporation.company_ids');
  }
  subscribe_cashflow_listener (callback: () => void): void {
    this.event_listener.subscribe('corporation.cashflow', callback);
  }
  notify_cashflow_listeners (): void {
    this.event_listener.notify_listeners('corporation.cashflow');
  }
  subscribe_company_buildings_listener (callback: () => void): void {
    this.event_listener.subscribe('corporation.company_buildings', callback);
  }
  notify_company_buildings_listeners (): void {
    this.event_listener.notify_listeners('corporation.company_buildings');
  }
  subscribe_company_inventions_listener (callback: () => void): void {
    this.event_listener.subscribe('corporation.company_inventions', callback);
  }
  notify_company_inventions_listeners (): void {
    this.event_listener.notify_listeners('corporation.company_inventions');
  }

  set_company_ids (companyIds: Array<string>): void {
    this.company_ids = Array.isArray(companyIds) ? companyIds : [];
    this.notify_company_ids_listeners();
  }

  add_company_id (companyId: string) {
    if (!this.company_ids) {
      this.company_ids = [];
    }
    this.company_ids.push(companyId);
    this.buildings_ids_by_company_id[companyId] = [];
    this.inventions_metadata_by_company_id[companyId] = CompanyInventions.create(companyId);
    this.notify_company_ids_listeners();
    this.notify_company_buildings_listeners();
    this.notify_company_inventions_listeners();
  }

  update_cashflow (last_mail_at: any, cash: number, _cashCurrentYear: any, cashflow: number) {
    this.last_mail_at = last_mail_at;
    this.cash = cash;
    this.cashflow = cashflow;
    this.notify_cashflow_listeners();
  }
  update_cashflow_companies (companies: Array<any>) {
    companies = Array.isArray(companies) ? companies : [companies];
    for (const company of companies) {
      this.cashflow_by_company_id[company.id] = company.cashflow ?? 0;
    }
    this.notify_cashflow_listeners();
  }


  building_ids_for_company (companyId: string): Array<string> {
    return this.buildings_ids_by_company_id[companyId] ?? [];
  }
  set_company_building_ids (companyId: string, buildingIds: Array<string>): void {
    this.buildings_ids_by_company_id[companyId] = buildingIds;
    this.notify_company_buildings_listeners();
  }

  add_company_building_id (companyId: string, buildingId: string) {
    if (!this.buildings_ids_by_company_id[companyId]) {
      this.buildings_ids_by_company_id[companyId] = [];
    }
    this.buildings_ids_by_company_id[companyId].push(buildingId);
    this.notify_company_buildings_listeners();
  }

  update_company_inventions_metadata (companyId: string, inventions_metadata: any): void {
    this.inventions_metadata_by_company_id[companyId] = inventions_metadata;
    this.notify_company_inventions_listeners();
  }
}
