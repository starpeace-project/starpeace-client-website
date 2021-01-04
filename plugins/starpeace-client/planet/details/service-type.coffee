
export default class ServiceType
  @label_for_type: (type) ->
    switch type
      when 'COLLEGE' then 'ui.menu.politics.details.colleges.label'
      when 'GARBAGE' then 'ui.menu.politics.details.garbage.label'
      when 'FIRE' then 'ui.menu.politics.details.fire.label'
      when 'HOSPITAL' then 'ui.menu.politics.details.health.label'
      when 'PRISON' then 'ui.menu.politics.details.prisons.label'
      when 'MUSEUM' then 'ui.menu.politics.details.museums.label'
      when 'POLICE' then 'ui.menu.politics.details.police.label'
      when 'SCHOOL' then 'ui.menu.politics.details.schools.label'
      when 'PARK' then 'ui.menu.politics.details.parks.label'
      when 'TAX_REVENUE' then 'ui.menu.politics.details.tax_revenue.label'
      when 'EMPLOYMENT' then 'ui.menu.politics.details.employment.label'
      when 'POPULATION_GROWTH' then 'ui.menu.politics.details.population_growth.label'
      when 'ECONOMIC_GROWTH' then 'ui.menu.politics.details.economic_growth.label'
      else type
