# frozen_string_literal: true

RSpec.describe FilterHelper, type: :helper do
  describe '#period_options' do
    it { expect(helper.period_options).to eq options_for_select([[I18n.t('general.filter.period.option.last_week'), 'week'], [I18n.t('general.filter.period.option.last_month'), 'month'], [I18n.t('general.filter.period.option.last_quarter'), 'quarter'], [I18n.t('general.filter.period.option.all_period'), 'all']], :month) }
  end

  describe '#flow_status_options' do
    it { expect(helper.flow_status_options).to eq options_for_select([[I18n.t('demands.filter.flow_status.all_demands'), :all_demands], [I18n.t('demands.filter.flow_status.not_committed'), :not_committed], [I18n.t('demands.filter.flow_status.work_in_progress'), :wip], [I18n.t('demands.filter.flow_status.delivered_demands'), :delivered]], :all_demands) }
  end

  describe '#demand_type_options' do
    it { expect(helper.demand_type_options).to eq options_for_select([[I18n.t('demands.filter.demand_type.all_types'), :all_types], [I18n.t('activerecord.attributes.demand.enums.demand_type.feature'), :feature], [I18n.t('activerecord.attributes.demand.enums.demand_type.bug'), :bug], [I18n.t('activerecord.attributes.demand.enums.demand_type.chore'), :chore], [I18n.t('activerecord.attributes.demand.enums.demand_type.performance_improvement'), :performance_improvement], [I18n.t('activerecord.attributes.demand.enums.demand_type.ui'), :ui], [I18n.t('activerecord.attributes.demand.enums.demand_type.wireframe'), :wireframe]], :all_types) }
  end

  describe '#class_of_service_options' do
    it { expect(helper.class_of_service_options).to eq options_for_select([[I18n.t('demands.filter.class_of_service.all_classes'), :all_classes], [I18n.t('activerecord.attributes.demand.enums.class_of_service.standard'), :standard], [I18n.t('activerecord.attributes.demand.enums.class_of_service.expedite'), :expedite], [I18n.t('activerecord.attributes.demand.enums.class_of_service.fixed_date'), :fixed_date], [I18n.t('activerecord.attributes.demand.enums.class_of_service.intangible'), :intangible]], :all_classes) }
  end

  describe '#grouping_period_to_charts_options' do
    it { expect(helper.grouping_period_to_charts_options).to eq options_for_select([[I18n.t('general.monthly'), 'month'], [I18n.t('general.weekly'), 'week'], [I18n.t('general.daily'), 'day']], 'month') }
  end

  describe '#form_input_periods' do
    it { expect(helper.form_input_periods).to eq options_for_select([[I18n.t('general.days'), 'day'], [I18n.t('general.weeks'), 'week'], [I18n.t('general.hours'), 'hour']], 'day') }
  end

  describe '#teams_in_company_options' do
    let(:company) { Fabricate :company }
    let!(:team) { Fabricate :team, company: company }

    it { expect(helper.teams_in_company_options(company, team.id)).to eq options_for_select([[team.name, team.id.to_s]], team.id) }
  end

  describe '#customers_in_company_options' do
    let(:company) { Fabricate :company }
    let!(:customer) { Fabricate :customer, company: company }

    it { expect(helper.customers_in_company_options(company, customer.id)).to eq options_for_select([[customer.name, customer.id.to_s]], customer.id) }
  end

  describe '#products_in_company_options' do
    let(:company) { Fabricate :company }
    let!(:customer) { Fabricate :customer, company: company }
    let!(:product) { Fabricate :product, customer: customer }

    it { expect(helper.products_in_company_options(company, product.id)).to eq options_for_select([[product.name, product.id.to_s]], product.id) }
  end

  describe '#project_statuses_options' do
    it { expect(helper.project_statuses_options('waiting')).to eq options_for_select(Project.statuses.map { |key, _value| [I18n.t("activerecord.attributes.project.enums.status.#{key}"), key] }, 'waiting') }
  end

  describe '#ordering_options' do
    it do
      expect(helper.ordering_options('cost_to_project')).to eq options_for_select([[Demand.human_attribute_name(:external_id), :external_id],
                                                                                   [I18n.t('demands.index.cost_to_project'), :cost_to_project],
                                                                                   [Demand.human_attribute_name(:leadtime), :leadtime],
                                                                                   [Demand.human_attribute_name(:created_date), :created_date],
                                                                                   [Demand.human_attribute_name(:commitment_date), :commitment_date],
                                                                                   [Demand.human_attribute_name(:end_date), :end_date]], 'cost_to_project')
    end
  end
end
