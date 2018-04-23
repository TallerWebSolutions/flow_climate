# frozen_string_literal: true

RSpec.describe FlowReportData, type: :data_object do
  context 'having projects' do
    before { travel_to Time.zone.local(2018, 4, 6, 10, 0, 0) }
    after { travel_back }

    let(:first_project) { Fabricate :project, status: :executing, start_date: 2.weeks.ago, end_date: 1.week.from_now }
    let(:second_project) { Fabricate :project, status: :waiting, start_date: 1.week.from_now, end_date: 2.weeks.from_now }
    let(:third_project) { Fabricate :project, status: :maintenance, start_date: 2.weeks.from_now, end_date: 3.weeks.from_now }

    let(:first_project_result) { Fabricate :project_result, project: first_project, result_date: 2.weeks.ago }
    let(:second_project_result) { Fabricate :project_result, project: second_project, result_date: 1.week.ago }
    let(:third_project_result) { Fabricate :project_result, project: second_project, result_date: 1.week.ago }

    let!(:first_demand) { Fabricate :demand, project: first_project, end_date: 1.week.ago, downstream: false, effort_upstream: 1000 }
    let!(:second_demand) { Fabricate :demand, project: first_project, end_date: 1.week.ago, effort_downstream: 120 }
    let!(:third_demand) { Fabricate :demand, project: second_project, end_date: 1.week.ago, effort_downstream: 20 }
    let!(:fourth_demand) { Fabricate :demand, project: second_project, end_date: 1.week.ago, effort_downstream: 60 }
    let!(:fifth_demand) { Fabricate :demand, project: third_project, end_date: 1.week.ago, effort_downstream: 12 }

    let!(:sixth_demand) { Fabricate :demand, project: first_project, commitment_date: 1.week.ago, effort_downstream: 16 }
    let!(:seventh_demand) { Fabricate :demand, project: second_project, commitment_date: 1.week.ago, effort_downstream: 7 }
    let!(:eigth_demand) { Fabricate :demand, project: first_project, commitment_date: 1.week.ago, effort_downstream: 11 }
    let!(:nineth_demand) { Fabricate :demand, project: second_project, commitment_date: 1.week.ago, effort_downstream: 32 }
    let!(:tenth_demand) { Fabricate :demand, project: third_project, commitment_date: 1.week.ago, effort_downstream: 76 }

    let!(:out_date_processed_demand) { Fabricate :demand, project: third_project, end_date: 2.weeks.ago }
    let!(:out_date_selected_demand) { Fabricate :demand, project: third_project, commitment_date: 2.weeks.ago }

    describe '.initialize' do
      let(:selected_demands) { DemandsRepository.instance.selected_grouped_by_project_and_week(Project.all, 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear).group_by(&:project) }
      let(:processed_demands) { DemandsRepository.instance.throughput_by_project_and_week(Project.all, 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear).group_by(&:project) }

      it 'extracts the information of flow' do
        first_project_result.add_demand!(first_demand)
        first_project_result.add_demand!(second_demand)
        second_project_result.add_demand!(third_demand)
        second_project_result.add_demand!(fourth_demand)
        third_project_result.add_demand!(fifth_demand)

        first_project_result.add_demand!(sixth_demand)
        second_project_result.add_demand!(seventh_demand)
        first_project_result.add_demand!(eigth_demand)
        second_project_result.add_demand!(nineth_demand)
        third_project_result.add_demand!(tenth_demand)

        flow_data = FlowReportData.new(Project.all, 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear)
        expect(flow_data.projects_in_chart).to match_array [first_project, second_project, third_project]
        expect(flow_data.total_arrived).to eq [2, 2, 1]
        expect(flow_data.total_processed_upstream).to eq [2, 2, 1]
        expect(flow_data.total_processed_downstream).to eq [0, 0, 0]

        expect(flow_data.projects_demands_selected[first_project]).to match_array [sixth_demand, eigth_demand]
        expect(flow_data.projects_demands_selected[second_project]).to match_array [seventh_demand, nineth_demand]
        expect(flow_data.projects_demands_selected[third_project]).to match_array [tenth_demand]

        expect(flow_data.projects_demands_processed[first_project]).to match_array [first_demand, second_demand]
        expect(flow_data.projects_demands_processed[second_project]).to match_array [third_demand, fourth_demand]
        expect(flow_data.projects_demands_processed[third_project]).to match_array [fifth_demand]

        expect(flow_data.processing_rate_data[first_project]).to match_array [first_demand, second_demand, sixth_demand, eigth_demand]
        expect(flow_data.processing_rate_data[second_project]).to match_array [third_demand, fourth_demand, seventh_demand, nineth_demand]
        expect(flow_data.processing_rate_data[third_project]).to match_array [fifth_demand, tenth_demand]

        expect(flow_data.wip_per_day[0][:data]).to eq [1, 1, 1, 1, 6, 6, 6]
        expect(flow_data.demands_in_wip[Date.new(2018, 3, 26).to_s]).to eq [out_date_selected_demand]
        expect(flow_data.demands_in_wip[Date.new(2018, 3, 27).to_s]).to eq [out_date_selected_demand]
        expect(flow_data.demands_in_wip[Date.new(2018, 3, 28).to_s]).to eq [out_date_selected_demand]
        expect(flow_data.demands_in_wip[Date.new(2018, 3, 29).to_s]).to eq [out_date_selected_demand]
        expect(flow_data.demands_in_wip[Date.new(2018, 3, 30).to_s]).to eq [out_date_selected_demand, sixth_demand, seventh_demand, eigth_demand, nineth_demand, tenth_demand]
        expect(flow_data.demands_in_wip[Date.new(2018, 3, 31).to_s]).to eq [out_date_selected_demand, sixth_demand, seventh_demand, eigth_demand, nineth_demand, tenth_demand]
        expect(flow_data.demands_in_wip[Date.new(2018, 4, 1).to_s]).to eq [out_date_selected_demand, sixth_demand, seventh_demand, eigth_demand, nineth_demand, tenth_demand]

        expect(flow_data.column_chart_data).to eq([{ name: I18n.t('demands.charts.processing_rate.arrived'), data: [2, 2, 1], stack: 0, yaxis: 0 }, { name: I18n.t('demands.charts.processing_rate.processed_downstream'), data: [0, 0, 0], stack: 1, yaxis: 1 }, { name: I18n.t('demands.charts.processing_rate.processed_upstream'), data: [2, 2, 1], stack: 1, yaxis: 1 }])

        expect(flow_data.x_axis_month_data).to eq [[2018.0, 3.0]]
        expect(flow_data.hours_per_project_per_month).to eq [1212]
      end
    end
  end
  context 'having no projects' do
    describe '.initialize' do
      let(:selected_demands) { DemandsRepository.instance.selected_grouped_by_project_and_week(Project.all, 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear).group_by(&:project) }
      let(:processed_demands) { DemandsRepository.instance.throughput_by_project_and_week(Project.all, 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear).group_by(&:project) }
      subject(:flow_data) { FlowReportData.new(Project.all, 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear) }

      it 'extracts the information of flow' do
        expect(flow_data.projects_in_chart).to eq []
        expect(flow_data.total_arrived).to eq []
        expect(flow_data.total_processed_upstream).to eq []
        expect(flow_data.total_processed_downstream).to eq []

        expect(flow_data.projects_demands_selected).to eq({})
        expect(flow_data.projects_demands_processed).to eq({})
        expect(flow_data.processing_rate_data).to eq({})

        expect(flow_data.column_chart_data).to eq([{ name: I18n.t('demands.charts.processing_rate.arrived'), data: [], stack: 0, yaxis: 0 }, { name: I18n.t('demands.charts.processing_rate.processed_downstream'), data: [], stack: 1, yaxis: 1 }, { name: I18n.t('demands.charts.processing_rate.processed_upstream'), data: [], stack: 1, yaxis: 1 }])
      end
    end
  end
end
