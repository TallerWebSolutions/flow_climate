# frozen_string_literal: true

RSpec.describe Highchart::DemandsChartsAdapter, type: :data_object do
  before { travel_to Time.zone.local(2018, 9, 3, 12, 20, 31) }

  after { travel_back }

  let(:start_date) { 6.months.ago }
  let(:end_date) { Time.zone.today }

  context 'having demands' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    let(:first_project) { Fabricate :project, customers: [customer], status: :executing, start_date: 4.months.ago, end_date: 1.week.from_now }
    let(:second_project) { Fabricate :project, customers: [customer], status: :waiting, start_date: 5.months.ago, end_date: 2.weeks.from_now }
    let(:third_project) { Fabricate :project, customers: [customer], status: :maintenance, start_date: 3.months.ago, end_date: 3.weeks.from_now }

    let!(:first_demand) { Fabricate :demand, project: first_project, commitment_date: 4.months.ago, end_date: 3.months.ago, effort_downstream: 16, effort_upstream: 123 }
    let!(:second_demand) { Fabricate :demand, project: second_project, commitment_date: 5.months.ago, end_date: 3.months.ago, effort_downstream: 7, effort_upstream: 221 }
    let!(:third_demand) { Fabricate :demand, project: first_project, commitment_date: 3.months.ago, end_date: 2.months.ago, effort_downstream: 11, effort_upstream: 76 }
    let!(:fourth_demand) { Fabricate :demand, project: second_project, commitment_date: 2.months.ago, end_date: 1.month.ago, effort_downstream: 32, effort_upstream: 332 }
    let!(:fifth_demand) { Fabricate :demand, project: third_project, commitment_date: 2.months.ago, end_date: Time.zone.today, effort_downstream: 76, effort_upstream: 12 }

    describe '#throughput_chart_data' do
      it 'computes and extracts the information of the throughput' do
        throughput_chart_data = Highchart::DemandsChartsAdapter.new(Demand.all, start_date, end_date, 'week').throughput_chart_data

        expect(throughput_chart_data[:x_axis]).to eq TimeService.instance.weeks_between_of(Date.new(2018, 3, 4), Date.new(2018, 9, 2))
        expect(throughput_chart_data[:y_axis][0][:name]).to eq I18n.t('general.delivered')
        expect(throughput_chart_data[:y_axis][0][:data]).to eq [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0]
      end
    end

    describe '#creation_chart_data' do
      it 'computes and extracts the information of the creation_date' do
        creation_chart_data = Highchart::DemandsChartsAdapter.new(Demand.all, start_date, end_date, 'week').creation_chart_data

        expect(creation_chart_data[:x_axis]).to eq TimeService.instance.weeks_between_of(Date.new(2018, 3, 4), Date.new(2018, 9, 2))
        expect(creation_chart_data[:y_axis][0][:name]).to eq I18n.t('demands.charts.creation_date')
        expect(creation_chart_data[:y_axis][0][:data]).to eq [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5]
      end
    end

    describe '#committed_chart_data' do
      it 'computes and extracts the information of the throughput' do
        committed_chart_data = Highchart::DemandsChartsAdapter.new(Demand.all, start_date, end_date, 'week').committed_chart_data

        expect(committed_chart_data[:x_axis]).to eq TimeService.instance.weeks_between_of(Date.new(2018, 3, 4), Date.new(2018, 9, 2))
        expect(committed_chart_data[:y_axis][0][:name]).to eq I18n.t('demands.charts.commitment_date')
        expect(committed_chart_data[:y_axis][0][:data]).to eq [0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0]
      end
    end

    describe '#leadtime_on_time_chart_data' do
      it 'computes and extracts the information of the throughput' do
        leadtime_on_time_chart_data = Highchart::DemandsChartsAdapter.new(Demand.all, start_date, end_date, 'week').leadtime_percentiles_on_time_chart_data

        expect(leadtime_on_time_chart_data[:x_axis]).to eq TimeService.instance.weeks_between_of(Date.new(2018, 5, 28), Date.new(2018, 9, 3))
        expect(leadtime_on_time_chart_data[:y_axis][0][:name]).to eq I18n.t('projects.charts.leadtime_evolution.legend.leadtime_80_confidence')
        expect(leadtime_on_time_chart_data[:y_axis][0][:data]).to eq [0, 0, 0, 0, 0, 30.0, 0, 0, 0, 31.0, 0, 0, 0, 0, 61.48575231481482]

        expect(leadtime_on_time_chart_data[:y_axis][1][:name]).to eq I18n.t('projects.charts.leadtime_evolution.legend.leadtime_80_confidence_accumulated')
        expect(leadtime_on_time_chart_data[:y_axis][1][:data]).to eq [0, 55.0, 55.0, 55.0, 55.0, 49.0, 49.0, 49.0, 49.0, 43.000000000000014, 43.000000000000014, 43.000000000000014, 43.000000000000014, 43.000000000000014, 61.097150462962965]
      end
    end
  end

  context 'having no demands' do
    describe '.initialize' do
      subject(:throughput_chart_data) { Highchart::DemandsChartsAdapter.new(Demand.all, start_date, end_date, 'week').throughput_chart_data }

      it 'returns empty information' do
        expect(throughput_chart_data).to be_nil
      end
    end
  end
end
