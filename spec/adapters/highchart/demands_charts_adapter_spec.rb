# frozen_string_literal: true

RSpec.describe Highchart::DemandsChartsAdapter, type: :data_object do
  before { travel_to Time.zone.local(2018, 9, 3, 12, 20, 31) }

  let(:start_date) { 6.months.ago }
  let(:end_date) { Time.zone.today }

  context 'with demands' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }
    let(:item_type) { Fabricate :work_item_type, company: company, name: 'foo' }
    let(:other_item_type) { Fabricate :work_item_type, company: company, name: 'bar' }

    let(:first_project) { Fabricate :project, customers: [customer], status: :executing, start_date: 4.months.ago, end_date: 1.week.from_now, name: 'first_project' }
    let(:second_project) { Fabricate :project, customers: [customer], status: :waiting, start_date: 5.months.ago, end_date: 2.weeks.from_now, name: 'second_project' }
    let(:third_project) { Fabricate :project, customers: [customer], status: :maintenance, start_date: 3.months.ago, end_date: 3.weeks.from_now, name: 'third_project' }

    let!(:first_demand) { Fabricate :demand, project: first_project, work_item_type: item_type, external_id: 'first_demand', commitment_date: 4.months.ago, end_date: 3.months.ago, effort_downstream: 16, effort_upstream: 123 }
    let!(:second_demand) { Fabricate :demand, project: second_project, work_item_type: item_type, external_id: 'second_demand', commitment_date: 5.months.ago, end_date: 4.months.ago, effort_downstream: 7, effort_upstream: 221 }
    let!(:third_demand) { Fabricate :demand, project: first_project, work_item_type: item_type, external_id: 'third_demand', commitment_date: 3.months.ago, end_date: 2.months.ago, effort_downstream: 11, effort_upstream: 76 }
    let!(:fourth_demand) { Fabricate :demand, project: second_project, work_item_type: other_item_type, external_id: 'fourth_demand', commitment_date: 2.months.ago, end_date: 1.month.ago, effort_downstream: 32, effort_upstream: 332 }
    let!(:fifth_demand) { Fabricate :demand, project: third_project, work_item_type: other_item_type, external_id: 'fifth_demand', commitment_date: 2.months.ago, end_date: Time.zone.today, effort_downstream: 76, effort_upstream: 12 }

    let(:daily_demands_chart_adapter) { described_class.new(Demand.all, start_date, end_date, 'day') }
    let(:weekly_demands_chart_adapter) { described_class.new(Demand.all, start_date, end_date, 'week') }
    let(:monthly_demands_chart_adapter) { described_class.new(Demand.all, start_date, end_date, 'month') }

    describe '#x_axis' do
      it { expect(daily_demands_chart_adapter.x_axis).to eq TimeService.instance.days_between_of(Date.new(2018, 3, 3), Date.new(2018, 9, 3)) }
      it { expect(weekly_demands_chart_adapter.x_axis).to eq TimeService.instance.weeks_between_of(Date.new(2018, 3, 4), Date.new(2018, 9, 9)) }
      it { expect(monthly_demands_chart_adapter.x_axis).to eq TimeService.instance.months_between_of(Date.new(2018, 3, 4), Date.new(2018, 9, 9)) }
    end

    describe '#throughput_chart_data' do
      it 'computes and extracts the information of the throughput' do
        expect(daily_demands_chart_adapter.throughput_chart_data).to eq [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]
        expect(weekly_demands_chart_adapter.throughput_chart_data).to eq [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1]
        expect(monthly_demands_chart_adapter.throughput_chart_data).to eq [0, 0, 1, 1, 1, 1, 1]
      end
    end

    describe '#creation_chart_data' do
      it 'computes and extracts the information of the creation_date' do
        expect(daily_demands_chart_adapter.creation_chart_data).to eq [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0]
        expect(weekly_demands_chart_adapter.creation_chart_data).to eq [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0]
        expect(monthly_demands_chart_adapter.creation_chart_data).to eq [0, 0, 0, 0, 0, 5, 0]
      end
    end

    describe '#committed_chart_data' do
      it 'computes and extracts the information of the throughput' do
        expect(daily_demands_chart_adapter.committed_chart_data).to eq [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        expect(weekly_demands_chart_adapter.committed_chart_data).to eq [0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        expect(monthly_demands_chart_adapter.committed_chart_data).to eq [0, 1, 1, 1, 2, 0, 0]
      end
    end

    describe '#leadtime_on_time_chart_data' do
      it 'computes and extracts the information of the throughput' do
        leadtime_on_time_chart_data = described_class.new(Demand.all, start_date, end_date, 'week').leadtime_percentiles_on_time_chart_data

        expect(leadtime_on_time_chart_data[:y_axis][0][:name]).to eq I18n.t('projects.charts.leadtime_evolution.legend.leadtime_80_confidence')
        expect(leadtime_on_time_chart_data[:y_axis][0][:data]).to eq [0, 0, 0, 0, 0, 0, 0, 0, 0, 30.0, 0, 0, 0, 31.0, 0, 0, 0, 0, 30.0, 0, 0, 0, 31.0, 0, 0, 0, 0, 61.48575231481482]

        expect(leadtime_on_time_chart_data[:y_axis][1][:name]).to eq I18n.t('projects.charts.leadtime_evolution.legend.leadtime_80_confidence_accumulated')
        expect(leadtime_on_time_chart_data[:y_axis][1][:data]).to eq [0, 0, 0, 0, 0, 0, 0, 0, 0, 30.0, 30.0, 30.0, 30.0, 30.0, 30.8, 30.8, 30.8, 30.8, 30.6, 30.6, 30.6, 30.6, 31.0, 31.0, 31.0, 31.0, 31.0, 37.09715046296297]
      end
    end

    describe '#demands_by_project' do
      context 'with data' do
        it 'computes and extracts the information of the demands count' do
          demands_by_project = described_class.new(Demand.all, start_date, end_date, 'week').demands_by_project

          expect(demands_by_project[:x_axis]).to match_array Demand.all.map(&:project_name).uniq
          expect(demands_by_project[:y_axis][0][:name]).to eq I18n.t('general.demands')
          expect(demands_by_project[:y_axis][0][:data]).to match_array [1, 2, 2]
        end
      end

      context 'with no data' do
        subject(:demands_by_project) { described_class.new(Demand.none, start_date, end_date, 'week').demands_by_project }

        it { expect(demands_by_project).to be_nil }
      end
    end

    describe '#demands_by_type' do
      context 'with data' do
        it 'computes and extracts the information of the demands count' do
          demands_chart_adapter = described_class.new(Demand.all, start_date, end_date, 'week')

          expect(demands_chart_adapter.demands_by_type).to eq([{ name: 'foo', y: 3 }, { name: 'bar', y: 2 }])
        end
      end

      context 'with no data' do
        subject(:demands_by_type) { described_class.new(Demand.none, start_date, end_date, 'week').demands_by_type }

        it { expect(demands_by_type).to be_nil }
      end
    end

    describe '#not_delivered_count' do
      context 'with data' do
        it 'computes and extracts the information of the demands count' do
          Fabricate :demand, company: company, commitment_date: Time.zone.yesterday, end_date: nil

          demands_chart_adapter = described_class.new(Demand.all, start_date, end_date, 'week')

          expect(demands_chart_adapter.not_delivered_count).to eq 1
        end
      end

      context 'with no data' do
        subject(:not_delivered_count) { described_class.new(Demand.none, start_date, end_date, 'week').not_delivered_count }

        it { expect(not_delivered_count).to eq 0 }
      end
    end

    describe '#delivered_count' do
      context 'with data' do
        it 'computes and extracts the information of the demands count' do
          Fabricate :demand, company: company, commitment_date: Time.zone.yesterday, end_date: nil

          demands_chart_adapter = described_class.new(Demand.all, start_date, end_date, 'week')

          expect(demands_chart_adapter.delivered_count).to eq 5
        end
      end

      context 'with no data' do
        subject(:delivered_count) { described_class.new(Demand.none, start_date, end_date, 'week').delivered_count }

        it { expect(delivered_count).to eq 0 }
      end
    end

    describe '#lead_time_control_chart' do
      context 'with data' do
        it 'computes and extracts the information of the demands count' do
          Fabricate :demand, company: company, commitment_date: Time.zone.yesterday, end_date: nil

          demands_chart_adapter = described_class.new(Demand.all, start_date, end_date, 'week')

          expect(demands_chart_adapter.lead_time_control_chart[:x_axis]).to eq %w[second_demand first_demand third_demand fourth_demand fifth_demand]
          expect(demands_chart_adapter.lead_time_control_chart[:lead_times]).to eq [second_demand.leadtime_in_days, first_demand.leadtime_in_days, third_demand.leadtime_in_days, fourth_demand.leadtime_in_days, fifth_demand.leadtime_in_days]
          expect(demands_chart_adapter.lead_time_control_chart[:lead_time_95p]).to be_within(0.1).of(55.3)
          expect(demands_chart_adapter.lead_time_control_chart[:lead_time_80p]).to be_within(0.1).of(37)
          expect(demands_chart_adapter.lead_time_control_chart[:lead_time_65p]).to be_within(0.1).of(37)
        end
      end

      context 'with no data' do
        subject(:lead_time_control_chart) { described_class.new(Demand.none, start_date, end_date, 'week').lead_time_control_chart }

        it { expect(lead_time_control_chart).to eq({ lead_time_65p: 0, lead_time_80p: 0, lead_time_95p: 0, lead_times: [], x_axis: [] }) }
      end
    end
  end

  context 'with no demands' do
    describe '.initialize' do
      subject(:throughput_chart_data) { described_class.new(Demand.all, start_date, end_date, 'week').throughput_chart_data }

      it 'returns empty information' do
        expect(throughput_chart_data).to be_nil
      end
    end
  end
end
