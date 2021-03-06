# frozen_string_literal: true

module FilterHelper
  def period_options(selected_value = :month)
    options_for_select([[I18n.t('general.filter.period.option.last_week'), 'week'], [I18n.t('general.filter.period.option.last_month'), 'month'], [I18n.t('general.filter.period.option.last_quarter'), 'quarter'], [I18n.t('general.filter.period.option.all_period'), 'all']], selected_value)
  end

  def demand_state_options(selected_value = :all_demands)
    options_for_select([[I18n.t('demands.filter.demand_state.all_demands'), :all_demands], [I18n.t('demands.filter.demand_state.discarded_demands'), :discarded], [I18n.t('demands.filter.demand_state.not_discarded_demands'), :not_discarded], [I18n.t('demands.filter.demand_state.not_started'), :not_started], [I18n.t('demands.filter.demand_state.not_committed'), :not_committed], [I18n.t('demands.filter.demand_state.work_in_progress'), :wip], [I18n.t('demands.filter.demand_state.delivered_demands'), :delivered]], selected_value)
  end

  def demand_type_options(selected_value = :all_types)
    options_for_select([[I18n.t('demands.filter.demand_type.all_types'), :all_types], [I18n.t('activerecord.attributes.demand.enums.demand_type.feature'), :feature], [I18n.t('activerecord.attributes.demand.enums.demand_type.bug'), :bug], [I18n.t('activerecord.attributes.demand.enums.demand_type.chore'), :chore], [I18n.t('activerecord.attributes.demand.enums.demand_type.performance_improvement'), :performance_improvement], [I18n.t('activerecord.attributes.demand.enums.demand_type.ui'), :ui], [I18n.t('activerecord.attributes.demand.enums.demand_type.wireframe'), :wireframe]], selected_value)
  end

  def class_of_service_options(selected_value = :all_classes)
    options_for_select([[I18n.t('demands.filter.class_of_service.all_classes'), :all_classes], [I18n.t('activerecord.attributes.demand.enums.class_of_service.standard'), :standard], [I18n.t('activerecord.attributes.demand.enums.class_of_service.expedite'), :expedite], [I18n.t('activerecord.attributes.demand.enums.class_of_service.fixed_date'), :fixed_date], [I18n.t('activerecord.attributes.demand.enums.class_of_service.intangible'), :intangible]], selected_value)
  end

  def grouping_period_to_charts_options(selected_value = 'month')
    options_for_select([[I18n.t('general.monthly'), 'month'], [I18n.t('general.weekly'), 'week'], [I18n.t('general.daily'), 'day']], selected_value)
  end

  def form_input_periods(selected_value = 'day')
    options_for_select([[I18n.t('general.days'), 'day'], [I18n.t('general.weeks'), 'week'], [I18n.t('general.hours'), 'hour']], selected_value)
  end

  def teams_in_company_options(company, selected_value)
    options_for_select(company.teams.map { |team| [team.name, team.id.to_s] }, selected_value)
  end

  def customers_in_company_options(company, selected_value)
    options_for_select(company.customers.map { |customer| [customer.name, customer.id.to_s] }, selected_value)
  end

  def products_in_company_options(company, selected_value)
    options_for_select(company.products.map { |product| [product.name, product.id.to_s] }, selected_value)
  end

  def project_statuses_options(selected_value)
    options_for_select(Project.statuses.map { |key, _value| [I18n.t("activerecord.attributes.project.enums.status.#{key}"), key] }, selected_value)
  end

  def ordering_options(selected_value)
    options_for_select([[Demand.human_attribute_name(:external_id), :external_id],
                        [I18n.t('demands.index.cost_to_project'), :cost_to_project],
                        [Demand.human_attribute_name(:leadtime), :leadtime],
                        [Demand.human_attribute_name(:created_date), :created_date],
                        [Demand.human_attribute_name(:commitment_date), :commitment_date],
                        [Demand.human_attribute_name(:end_date), :end_date]], selected_value)
  end
end
