# frozen_string_literal: true

RSpec.describe Highchart::ProjectStatisticsChartsAdapter, type: :service do
  before { travel_to Time.zone.local(2018, 2, 20, 10, 0, 0) }

  after { travel_back }

  describe '#scope_data_evolution_chart' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    let(:team) { Fabricate :team, company: company }
    let!(:team_member) { Fabricate :team_member, team: team, hours_per_month: 20 }
    let!(:other_team_member) { Fabricate :team_member, team: team, hours_per_month: 160 }

    context 'having projects' do
      let!(:first_project) { Fabricate :project, customer: customer, status: :maintenance, start_date: 3.months.ago, end_date: 2.months.ago, qty_hours: 1000, initial_scope: 95, value: 200.0 }
      let!(:second_project) { Fabricate :project, customer: customer, status: :executing, start_date: 3.months.ago, end_date: 1.month.ago, qty_hours: 500, initial_scope: 40, value: 3_453_220.0 }
      let!(:third_project) { Fabricate :project, customer: customer, status: :maintenance, start_date: 1.month.from_now, end_date: 2.months.from_now, qty_hours: 1500, initial_scope: 22, value: 10_000.0 }
      let!(:fourth_project) { Fabricate :project, customer: customer, status: :executing, start_date: 1.month.from_now, end_date: 2.months.from_now, qty_hours: 700, initial_scope: 100, value: 700.0 }
      let!(:fifth_project) { Fabricate :project, customer: customer, status: :maintenance, start_date: 2.months.from_now, end_date: 3.months.from_now, qty_hours: 200, initial_scope: 42, value: 200.0 }
      let!(:sixth_project) { Fabricate :project, customer: customer, status: :waiting, start_date: 2.months.from_now, end_date: 3.months.from_now, qty_hours: 5000, initial_scope: 78, value: 123.0 }
      let!(:seventh_project) { Fabricate :project, customer: customer, status: :finished, start_date: 2.months.from_now, end_date: 3.months.from_now, qty_hours: 8765, initial_scope: 88, value: 23.0 }
      let!(:eighth_project) { Fabricate :project, customer: customer, status: :cancelled, start_date: 2.months.from_now, end_date: 3.months.from_now, qty_hours: 1232, initial_scope: 11, value: 200.0 }

      let!(:first_demand) { Fabricate :demand, project: first_project, effort_downstream: 200, effort_upstream: 10, created_date: 74.days.ago }
      let!(:second_demand) { Fabricate :demand, project: first_project, effort_downstream: 400, effort_upstream: 130, created_date: 65.days.ago }
      let!(:third_demand) { Fabricate :demand, project: second_project, effort_downstream: 100, effort_upstream: 20, end_date: 2.months.from_now }

      context 'daily basis x axis' do
        it 'builds the data structure for scope_data_evolution' do
          statistics_data = Highchart::ProjectStatisticsChartsAdapter.new([first_project], first_project.start_date, first_project.end_date, 'day', '')

          expect(statistics_data.scope_data_evolution_chart).to eq [{ data: [95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 95, 96, 96, 96, 96, 96, 96, 96, 96, 96, 97, 97, 97, 97], marker: { enabled: true }, name: I18n.t('projects.general.scope') }]
          expect(statistics_data.x_axis).to eq(TimeService.instance.days_between_of(first_project.start_date, first_project.end_date))
          expect(statistics_data.projects).to eq([first_project])
        end
      end

      context 'weekly basis x axis' do
        it 'builds the data structure for scope_data_evolution' do
          statistics_data = Highchart::ProjectStatisticsChartsAdapter.new([first_project], first_project.start_date, first_project.end_date, 'week', '')

          expect(statistics_data.scope_data_evolution_chart).to eq [{ data: [95, 95, 96, 97, 97], marker: { enabled: true }, name: I18n.t('projects.general.scope') }]
          expect(statistics_data.x_axis).to eq(TimeService.instance.weeks_between_of(first_project.start_date, first_project.end_date))
        end
      end

      context 'monthly basis x axis' do
        context 'passing no status filter' do
          it 'builds the data structure for scope_data_evolution' do
            statistics_data = Highchart::ProjectStatisticsChartsAdapter.new([first_project], first_project.start_date, first_project.end_date, 'month', '')

            expect(statistics_data.scope_data_evolution_chart).to eq [{ data: [95, 97], marker: { enabled: true }, name: I18n.t('projects.general.scope') }]
            expect(statistics_data.x_axis).to eq(TimeService.instance.months_between_of(first_project.start_date, first_project.end_date))
          end
        end

        context 'passing a status filter' do
          it 'builds the data structure for scope_data_evolution' do
            statistics_data = Highchart::ProjectStatisticsChartsAdapter.new([first_project, second_project], 3.months.ago, 1.month.from_now, 'month', 'executing')

            expect(statistics_data.projects).to eq([second_project])
          end
        end
      end
    end
  end

  describe '#leadtime_data_evolution_chart' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    let(:team) { Fabricate :team, company: company }
    let!(:team_member) { Fabricate :team_member, team: team, hours_per_month: 20 }
    let!(:other_team_member) { Fabricate :team_member, team: team, hours_per_month: 160 }

    context 'having demands' do
      let!(:first_project) { Fabricate :project, customer: customer, status: :maintenance, start_date: 3.days.ago, end_date: Time.zone.now, qty_hours: 1000, initial_scope: 95, value: 200.0 }

      let!(:first_demand) { Fabricate :demand, project: first_project, commitment_date: 3.days.ago, end_date: Time.zone.now, effort_downstream: 200, effort_upstream: 10, created_date: 74.days.ago }
      let!(:second_demand) { Fabricate :demand, project: first_project, commitment_date: 1.day.ago, end_date: Time.zone.now, effort_downstream: 400, effort_upstream: 130, created_date: 65.days.ago }
      let!(:third_demand) { Fabricate :demand, project: first_project, commitment_date: 7.days.ago, end_date: Time.zone.now, effort_downstream: 100, effort_upstream: 20 }

      let!(:fourth_demand) { Fabricate :demand, project: first_project, commitment_date: 7.days.ago, end_date: 2.days.ago, effort_downstream: 200, effort_upstream: 10, created_date: 74.days.ago }
      let!(:fifth_demand) { Fabricate :demand, project: first_project, commitment_date: 14.days.ago, end_date: 2.days.ago, effort_downstream: 400, effort_upstream: 130, created_date: 65.days.ago }
      let!(:sixth_demand) { Fabricate :demand, project: first_project, commitment_date: 7.days.ago, end_date: 3.days.ago, effort_downstream: 100, effort_upstream: 20 }

      context 'daily basis x axis' do
        it 'builds the data structure for scope_data_evolution' do
          statistics_data = Highchart::ProjectStatisticsChartsAdapter.new([first_project], first_project.start_date, first_project.end_date, 'day', '')

          expect(statistics_data.leadtime_data_evolution_chart(80)).to eq [{ data: [4.0, 9.241666666666667, 9.241666666666667, 7.041666666666667], marker: { enabled: true }, name: I18n.t('projects.general.leadtime', confidence: 80) }]
          expect(statistics_data.x_axis).to eq(TimeService.instance.days_between_of(first_project.start_date, first_project.end_date))
        end
      end

      context 'weekly basis x axis' do
        it 'builds the data structure for scope_data_evolution' do
          statistics_data = Highchart::ProjectStatisticsChartsAdapter.new([first_project], first_project.start_date, first_project.end_date, 'week', '')

          expect(statistics_data.leadtime_data_evolution_chart(80)).to eq [{ data: [4.0, 7.041666666666667], marker: { enabled: true }, name: I18n.t('projects.general.leadtime', confidence: 80) }]
          expect(statistics_data.x_axis).to eq(TimeService.instance.weeks_between_of(first_project.start_date, first_project.end_date))
        end
      end

      context 'monthly basis x axis' do
        it 'builds the data structure for scope_data_evolution' do
          statistics_data = Highchart::ProjectStatisticsChartsAdapter.new([first_project], first_project.start_date, first_project.end_date, 'month', '')

          expect(statistics_data.leadtime_data_evolution_chart(80)).to eq [{ data: [7.041666666666667], marker: { enabled: true }, name: I18n.t('projects.general.leadtime', confidence: 80) }]
          expect(statistics_data.x_axis).to eq(TimeService.instance.months_between_of(first_project.start_date, first_project.end_date))
        end
      end
    end
  end

  describe '#block_data_evolution_chart' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    let(:team) { Fabricate :team, company: company }
    let!(:team_member) { Fabricate :team_member, team: team, hours_per_month: 20 }
    let!(:other_team_member) { Fabricate :team_member, team: team, hours_per_month: 160 }

    context 'having blocks' do
      let!(:first_project) { Fabricate :project, customer: customer, status: :maintenance, start_date: 3.days.ago, end_date: Time.zone.now, qty_hours: 1000, initial_scope: 95, value: 200.0 }

      let!(:first_demand) { Fabricate :demand, project: first_project, commitment_date: 3.days.ago, end_date: Time.zone.now, effort_downstream: 200, effort_upstream: 10, created_date: 74.days.ago }
      let!(:second_demand) { Fabricate :demand, project: first_project, commitment_date: 1.day.ago, end_date: Time.zone.now, effort_downstream: 400, effort_upstream: 130, created_date: 65.days.ago }
      let!(:third_demand) { Fabricate :demand, project: first_project, commitment_date: 7.days.ago, end_date: Time.zone.now, effort_downstream: 100, effort_upstream: 20 }

      let!(:fourth_demand) { Fabricate :demand, project: first_project, commitment_date: 7.days.ago, end_date: 2.days.ago, effort_downstream: 200, effort_upstream: 10, created_date: 74.days.ago }
      let!(:fifth_demand) { Fabricate :demand, project: first_project, commitment_date: 14.days.ago, end_date: 2.days.ago, effort_downstream: 400, effort_upstream: 130, created_date: 65.days.ago }
      let!(:sixth_demand) { Fabricate :demand, project: first_project, commitment_date: 7.days.ago, end_date: 3.days.ago, effort_downstream: 100, effort_upstream: 20 }

      let!(:first_block) { Fabricate :demand_block, demand: first_demand, block_time: 1.hour.ago, unblock_time: Time.zone.today.end_of_day, active: true }
      let!(:second_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago, unblock_time: 2.days.ago }
      let!(:third_block) { Fabricate :demand_block, demand: second_demand, block_time: 2.days.ago, unblock_time: Time.zone.yesterday }
      let!(:fourth_block) { Fabricate :demand_block, demand: first_demand, block_time: 2.days.ago }

      context 'daily basis x axis' do
        it 'builds the data structure for scope_data_evolution' do
          statistics_data = Highchart::ProjectStatisticsChartsAdapter.new([first_project], first_project.start_date, first_project.end_date, 'day', '')

          expect(statistics_data.block_data_evolution_chart).to eq [{ data: [0, 1, 2, 3], marker: { enabled: true }, name: I18n.t('projects.statistics.accumulated_blocks.data_title') }]
          expect(statistics_data.x_axis).to eq(TimeService.instance.days_between_of(first_project.start_date, first_project.end_date))
        end
      end

      context 'weekly basis x axis' do
        it 'builds the data structure for scope_data_evolution' do
          statistics_data = Highchart::ProjectStatisticsChartsAdapter.new([first_project], first_project.start_date, first_project.end_date, 'week', '')

          expect(statistics_data.block_data_evolution_chart).to eq [{ data: [0, 3], marker: { enabled: true }, name: I18n.t('projects.statistics.accumulated_blocks.data_title') }]
          expect(statistics_data.x_axis).to eq(TimeService.instance.weeks_between_of(first_project.start_date, first_project.end_date))
        end
      end

      context 'monthly basis x axis' do
        it 'builds the data structure for scope_data_evolution' do
          statistics_data = Highchart::ProjectStatisticsChartsAdapter.new([first_project], first_project.start_date, first_project.end_date, 'month', '')

          expect(statistics_data.block_data_evolution_chart).to eq [{ data: [3], marker: { enabled: true }, name: I18n.t('projects.statistics.accumulated_blocks.data_title') }]
          expect(statistics_data.x_axis).to eq(TimeService.instance.months_between_of(first_project.start_date, first_project.end_date))
        end
      end
    end
  end
end
