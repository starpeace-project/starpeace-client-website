
export default class ServiceType {
  static labelForTypeId (typeId: string): string {
    switch (typeId) {
      case 'COLLEGE': return 'ui.menu.politics.details.colleges.label'
      case 'GARBAGE': return 'ui.menu.politics.details.garbage.label'
      case 'FIRE': return 'ui.menu.politics.details.fire.label'
      case 'HOSPITAL': return 'ui.menu.politics.details.health.label'
      case 'PRISON': return 'ui.menu.politics.details.prisons.label'
      case 'MUSEUM': return 'ui.menu.politics.details.museums.label'
      case 'POLICE': return 'ui.menu.politics.details.police.label'
      case 'SCHOOL': return 'ui.menu.politics.details.schools.label'
      case 'PARK': return 'ui.menu.politics.details.parks.label'
      case 'TAX_REVENUE': return 'ui.menu.politics.details.tax_revenue.label'
      case 'EMPLOYMENT': return 'ui.menu.politics.details.employment.label'
      case 'POPULATION_GROWTH': return 'ui.menu.politics.details.population_growth.label'
      case 'ECONOMIC_GROWTH': return 'ui.menu.politics.details.economic_growth.label'
      default: return typeId
    }
  }
}
