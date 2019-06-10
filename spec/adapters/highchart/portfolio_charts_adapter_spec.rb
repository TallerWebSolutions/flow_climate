# frozen_string_literal: true

RSpec.describe Highchart::PortfolioChartsAdapter, type: :service do
  before { travel_to Time.zone.local(2018, 2, 20, 10, 0, 0) }

  after { travel_back }

  describe '#block_count_by_project' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    context 'having blocks' do
      let!(:first_project) { Fabricate :project, customers: [customer], status: :maintenance, start_date: 3.days.ago, end_date: 2.days.ago, qty_hours: 1000, initial_scope: 95, value: 200.0 }
      let!(:second_project) { Fabricate :project, customers: [customer], status: :executing, start_date: 3.days.ago, end_date: Time.zone.today, qty_hours: 500, initial_scope: 40, value: 3_453_220.0 }

      let!(:first_demand) { Fabricate :demand, project: first_project, effort_downstream: 200, effort_upstream: 10, created_date: 74.days.ago }
      let!(:second_demand) { Fabricate :demand, project: first_project, effort_downstream: 400, effort_upstream: 130, created_date: 65.days.ago }
      let!(:third_demand) { Fabricate :demand, project: second_project, effort_downstream: 100, effort_upstream: 20, end_date: 2.months.from_now }
      let!(:fourth_demand) { Fabricate :demand, project: first_project, commitment_date: 3.days.ago, end_date: Time.zone.now, effort_downstream: 200, effort_upstream: 10, created_date: 74.days.ago }

      let!(:fifth_demand) { Fabricate :demand, project: first_project, commitment_date: 1.day.ago, end_date: Time.zone.now, effort_downstream: 400, effort_upstream: 130, created_date: 65.days.ago }

      let!(:first_block) { Fabricate :demand_block, demand: first_demand, block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true }
      let!(:second_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago, unblock_time: 2.days.ago }
      let!(:third_block) { Fabricate :demand_block, demand: second_demand, block_time: 2.days.ago, unblock_time: 4.days.ago }
      let!(:fourth_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago, unblock_time: Time.zone.yesterday }
      let!(:fifth_block) { Fabricate :demand_block, demand: third_demand, block_time: 5.days.ago, unblock_time: 3.days.ago }
      let!(:sixth_block) { Fabricate :demand_block, demand: fourth_demand, block_time: 2.days.ago, unblock_time: Time.zone.today }

      context 'passing no status filter' do
        it 'builds the data structure for block_count_by_project' do
          statistics_data = Highchart::PortfolioChartsAdapter.new([first_project, second_project], [first_project.start_date, second_project.start_date].min, [first_project.end_date, second_project.end_date].max, '')

          expect(statistics_data.block_count_by_project[:series]).to eq [{ data: [5], marker: { enabled: true }, name: I18n.t('portfolio.charts.block_count') }]
          expect(statistics_data.block_count_by_project[:x_axis]).to eq([first_project.name])
        end
      end

      context 'passing a status filter' do
        it 'builds the data structure for block_count_by_project' do
          statistics_data = Highchart::PortfolioChartsAdapter.new([first_project, second_project], 10.days.ago, Time.zone.now, 'executing')

          expect(statistics_data.block_count_by_project[:series]).to eq [{ data: [1], marker: { enabled: true }, name: I18n.t('portfolio.charts.block_count') }]
          expect(statistics_data.block_count_by_project[:x_axis]).to eq([second_project.name])
        end
      end
    end

    context 'having no blocks' do
      let!(:first_project) { Fabricate :project, customers: [customer], status: :maintenance, start_date: 3.days.ago, end_date: 2.days.ago, qty_hours: 1000, initial_scope: 95, value: 200.0 }
      let!(:second_project) { Fabricate :project, customers: [customer], status: :executing, start_date: 3.days.ago, end_date: Time.zone.today, qty_hours: 500, initial_scope: 40, value: 3_453_220.0 }

      it 'builds the data structure for scope_data_evolution' do
        statistics_data = Highchart::PortfolioChartsAdapter.new([first_project, second_project], [first_project.start_date, second_project.start_date].min, [first_project.end_date, second_project.end_date].max, '')

        expect(statistics_data.block_count_by_project[:series]).to eq [{ data: [], marker: { enabled: true }, name: I18n.t('portfolio.charts.block_count') }]
        expect(statistics_data.block_count_by_project[:x_axis]).to eq([])
      end
    end
  end

  describe '#aging_by_project' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    context 'having blocks' do
      let!(:first_project) { Fabricate :project, customers: [customer], status: :maintenance, start_date: 3.days.ago, end_date: 2.days.ago, qty_hours: 1000, initial_scope: 95, value: 200.0 }
      let!(:second_project) { Fabricate :project, customers: [customer], status: :executing, start_date: 3.days.ago, end_date: Time.zone.today, qty_hours: 500, initial_scope: 40, value: 3_453_220.0 }

      it 'builds the data structure for aging_by_project' do
        portfolio_data = Highchart::PortfolioChartsAdapter.new([first_project, second_project], [first_project.start_date, second_project.start_date].min, [first_project.end_date, second_project.end_date].max, '')

        expect(portfolio_data.aging_by_project[:series]).to eq [{ data: [1, 3], marker: { enabled: true }, name: I18n.t('portfolio.charts.aging_by_project.data_title') }]
        expect(portfolio_data.aging_by_project[:x_axis]).to eq([first_project.name, second_project.name])
      end
    end
  end

  describe '#throughput_by_project' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    context 'having projects' do
      let!(:first_project) { Fabricate :project, customers: [customer], status: :maintenance, start_date: 3.days.ago, end_date: 1.day.ago }
      let!(:second_project) { Fabricate :project, customers: [customer], status: :executing, start_date: 3.days.ago, end_date: Time.zone.today }

      context 'and no throughput' do
        let!(:first_demand) { Fabricate :demand, project: first_project, end_date: nil }
        let!(:second_demand) { Fabricate :demand, project: first_project, end_date: nil }
        let!(:third_demand) { Fabricate :demand, project: second_project, end_date: nil }

        it 'builds the empty structure' do
          portfolio_data = Highchart::PortfolioChartsAdapter.new([first_project, second_project], [first_project.start_date, second_project.start_date].min, [first_project.end_date, second_project.end_date].max, '')

          expect(portfolio_data.throughput_by_project[:series]).to eq [{ data: [], marker: { enabled: true }, name: I18n.t('portfolio.charts.throughput_by_project.data_title') }]
          expect(portfolio_data.throughput_by_project[:x_axis]).to eq([])
        end
      end

      context 'and having throughputs' do
        let!(:first_demand) { Fabricate :demand, project: first_project, end_date: 1.day.ago }
        let!(:second_demand) { Fabricate :demand, project: first_project, end_date: Time.zone.today }
        let!(:third_demand) { Fabricate :demand, project: second_project, end_date: 2.days.ago }
        let!(:fourth_demand) { Fabricate :demand, project: first_project, end_date: 1.day.ago }
        let!(:fifth_demand) { Fabricate :demand, project: first_project, end_date: 1.day.ago }

        it 'builds the data structure for scope_data_evolution' do
          portfolio_data = Highchart::PortfolioChartsAdapter.new([first_project, second_project], [first_project.start_date, second_project.start_date].min, [first_project.end_date, second_project.end_date].max, '')

          expect(portfolio_data.throughput_by_project[:series]).to eq [{ data: [3, 1], marker: { enabled: true }, name: I18n.t('portfolio.charts.throughput_by_project.data_title') }]
          expect(portfolio_data.throughput_by_project[:x_axis]).to eq [first_project.name, second_project.name]
        end
      end
    end

    context 'having no projects' do
      it 'builds the data structure for scope_data_evolution' do
        portfolio_data = Highchart::PortfolioChartsAdapter.new([], 1.year.ago.to_date, Time.zone.today, '')

        expect(portfolio_data.throughput_by_project[:series]).to eq [{ data: [], marker: { enabled: true }, name: I18n.t('portfolio.charts.throughput_by_project.data_title') }]
        expect(portfolio_data.throughput_by_project[:x_axis]).to eq []
      end
    end
  end
end
