# frozen_string_literal: true

RSpec.describe FlowAnalyticData, type: :data_objects do
  describe '#best_month_to_start_a_project' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    context 'having the company config' do
      let!(:company_config) { Fabricate :company_settings, company: company, max_active_parallel_projects: 2, max_flow_pressure: 3 }
      let!(:projects) { Fabricate.times(2, :project, customer: customer, start_date: Time.zone.today, end_date: Time.zone.today) }
      let!(:other_projects) { Fabricate.times(2, :project, customer: customer, start_date: 1.month.from_now, end_date: 1.month.from_now) }
      subject(:analytic) { FlowAnalyticData.new(company) }
      it 'returns the correct message' do
        best_month = I18n.l(2.months.from_now, format: '%B/%Y')
        expect(analytic.best_month_to_start_a_project(Time.zone.today)).to eq I18n.t('flow_analytics.best_month_to_start.best_month_html', best_month: best_month, active_count: 0, active_limit: 2, project_portfolio_room: 2)
      end
    end
    context 'having no company config' do
      let!(:projects) { Fabricate.times(2, :project, customer: customer, start_date: Time.zone.today, end_date: Time.zone.today) }
      let!(:other_projects) { Fabricate.times(2, :project, customer: customer, start_date: 1.month.from_now, end_date: 1.month.from_now) }
      subject(:analytic) { FlowAnalyticData.new(company) }
      it('returns the correct message') { expect(analytic.best_month_to_start_a_project(Time.zone.today)).to eq I18n.t('flow_analytics.best_month_to_start.no_config') }
    end
  end

  describe '#financial_debt_to_sold_projects' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    context 'having the financial informations' do
      let!(:company_config) { Fabricate :company_settings, company: company, max_active_parallel_projects: 2, max_flow_pressure: 3 }
      let!(:financial_information) { Fabricate :financial_information, company: company, expenses_total: 10 }
      let!(:projects) { Fabricate.times(2, :project, customer: customer, start_date: Time.zone.today, end_date: Time.zone.today, value: 20) }
      let!(:other_projects) { Fabricate.times(2, :project, customer: customer, start_date: 1.month.from_now, end_date: 1.month.from_now, value: 5) }
      subject(:analytic) { FlowAnalyticData.new(company) }
      it 'returns the correct message' do
        debt_month = I18n.l(2.months.from_now, format: '%B/%Y')
        expect(analytic.financial_debt_to_sold_projects(Time.zone.today)).to eq I18n.t('flow_analytics.financial_debt.financial_debt_month_html', debt_month: debt_month, debt_difference: '-R$ 10,00')
      end
    end
    context 'having no company config' do
      let!(:projects) { Fabricate.times(2, :project, customer: customer, start_date: Time.zone.today, end_date: Time.zone.today) }
      let!(:other_projects) { Fabricate.times(2, :project, customer: customer, start_date: 1.month.from_now, end_date: 1.month.from_now) }
      subject(:analytic) { FlowAnalyticData.new(company) }
      it('returns the correct message') { expect(analytic.financial_debt_to_sold_projects(Time.zone.today)).to eq I18n.t('flow_analytics.financial_debt.no_finances') }
    end
  end
end
