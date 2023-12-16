import CommerceDetails from '~/plugins/starpeace-client/planet/details/commerce-details'
import EmploymentDetails from '~/plugins/starpeace-client/planet/details/employment-details'
import HousingDetails from '~/plugins/starpeace-client/planet/details/housing-details'
import PopulationDetails from '~/plugins/starpeace-client/planet/details/population-details'
import ServiceLevel from '~/plugins/starpeace-client/planet/details/service-level'
import TaxDetails from '~/plugins/starpeace-client/planet/details/tax-details'

import CurrentTerm from '~/plugins/starpeace-client/planet/politics/current-term'
import NextTerm from '~/plugins/starpeace-client/planet/politics/next-term'

export default class TownDetails {
  id: string | undefined;
  qol: number | undefined;
  services: Array<ServiceLevel> = [];
  commerce: Array<CommerceDetails> = [];
  taxes: Array<TaxDetails> = [];
  population: Array<PopulationDetails> = [];
  employment: Array<EmploymentDetails> = [];
  housing: Array<HousingDetails> = [];
  currentTerm: CurrentTerm | undefined;
  nextTerm: NextTerm | undefined;

  static fromJson (json: any): any {
    const metadata = new TownDetails();
    metadata.id = json.id;
    metadata.qol = json.qol;
    metadata.services = (json.services ?? []).map(ServiceLevel.fromJson);
    metadata.commerce = (json.commerce ?? []).map(CommerceDetails.fromJson);
    metadata.taxes = (json.taxes ?? []).map(TaxDetails.fromJson);
    metadata.population = (json.population ?? []).map(PopulationDetails.fromJson);
    metadata.employment = (json.employment ?? []).map(EmploymentDetails.fromJson);
    metadata.housing = (json.housing ?? []).map(HousingDetails.fromJson);
    metadata.currentTerm = CurrentTerm.fromJson(json.currentTerm);
    metadata.nextTerm = NextTerm.fromJson(json.nextTerm);
    return metadata;
  }
}