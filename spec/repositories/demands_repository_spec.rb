# frozen_string_literal: true

RSpec.describe DemandsRepository, type: :repository do
  describe '#demands_for_company_and_week' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    let(:first_project) { Fabricate :project, customer: customer, start_date: 1.week.ago }
    let(:second_project) { Fabricate :project, customer: customer, start_date: 1.week.ago }
    let(:third_project) { Fabricate :project, customer: customer, end_date: 1.week.from_now }
    let(:fourth_project) { Fabricate :project, customer: customer, end_date: 1.week.from_now }

    let(:first_project_result) { Fabricate :project_result, project: first_project, result_date: 1.week.ago }
    let(:second_project_result) { Fabricate :project_result, project: second_project, result_date: 1.week.ago }
    let(:third_project_result) { Fabricate :project_result, project: third_project, result_date: Time.zone.today }

    let!(:first_demand) { Fabricate :demand, project_result: first_project_result, demand_id: 'zzz' }
    let!(:second_demand) { Fabricate :demand, project_result: first_project_result, demand_id: 'aaa' }
    let!(:third_demand) { Fabricate :demand, project_result: second_project_result, demand_id: 'sss' }
    let!(:fourth_demand) { Fabricate :demand, project_result: third_project_result }

    it { expect(DemandsRepository.instance.demands_for_company_and_week(company, 1.week.ago.to_date)).to eq [second_demand, third_demand, first_demand] }
  end

  describe '#known_scope_to_date' do
    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    let(:first_project) { Fabricate :project, customer: customer, start_date: 1.week.ago }
    let(:second_project) { Fabricate :project, customer: customer, start_date: 1.week.ago }

    let!(:first_demand) { Fabricate :demand, project: first_project, created_date: 3.days.ago }
    let!(:second_demand) { Fabricate :demand, project: first_project, created_date: 2.days.ago }
    let!(:third_demand) { Fabricate :demand, project: first_project, created_date: 2.days.ago }
    let!(:fourth_demand) { Fabricate :demand, project: first_project, created_date: 1.day.ago }
    let!(:fifth_demand) { Fabricate :demand, project: second_project, created_date: 2.days.ago }

    it { expect(DemandsRepository.instance.known_scope_to_date(first_project, 2.days.ago)).to eq 3 }
  end

  pending '#full_demand_destroy!'

  describe '#selected_grouped_by_project_and_week' do
    let(:first_project) { Fabricate :project, start_date: 3.weeks.ago }
    let(:second_project) { Fabricate :project, start_date: 3.weeks.ago }

    context 'having data' do
      let!(:first_demand) { Fabricate :demand, project: first_project, commitment_date: 3.weeks.ago }
      let!(:second_demand) { Fabricate :demand, project: first_project, commitment_date: 2.weeks.ago }
      let!(:third_demand) { Fabricate :demand, project: first_project, commitment_date: 1.week.ago }
      let!(:fourth_demand) { Fabricate :demand, project: first_project, commitment_date: 1.week.ago }
      let!(:fifth_demand) { Fabricate :demand, project: second_project, commitment_date: 1.week.ago }

      it { expect(DemandsRepository.instance.selected_grouped_by_project_and_week(Project.all, 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear)).to match_array [third_demand, fourth_demand, fifth_demand] }
    end
    context 'having no data' do
      it { expect(DemandsRepository.instance.selected_grouped_by_project_and_week(Project.all, 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear)).to eq [] }
    end
  end

  describe '#throughput_by_project_and_week' do
    let(:first_project) { Fabricate :project, start_date: 3.weeks.ago }
    let(:second_project) { Fabricate :project, start_date: 3.weeks.ago }

    context 'having data' do
      let!(:first_demand) { Fabricate :demand, project: first_project, end_date: 3.weeks.ago }
      let!(:second_demand) { Fabricate :demand, project: first_project, end_date: 2.weeks.ago }
      let!(:third_demand) { Fabricate :demand, project: first_project, end_date: 1.week.ago }
      let!(:fourth_demand) { Fabricate :demand, project: first_project, end_date: 1.week.ago }
      let!(:fifth_demand) { Fabricate :demand, project: second_project, end_date: 1.week.ago }

      it { expect(DemandsRepository.instance.throughput_by_project_and_week(Project.all, 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear)).to match_array [third_demand, fourth_demand, fifth_demand] }
    end
    context 'having no data' do
      it { expect(DemandsRepository.instance.throughput_by_project_and_week(Project.all, 1.week.ago.to_date.cweek, 1.week.ago.to_date.cwyear)).to eq [] }
    end
  end

  describe '#working_in_progress_for' do
    before { travel_to Time.zone.local(2018, 4, 5, 10, 0, 0) }
    after { travel_back }

    let(:project) { Fabricate :project }

    context 'having demands' do
      let!(:first_demand) { Fabricate :demand, project: project, commitment_date: Time.zone.yesterday, end_date: nil }
      let!(:second_demand) { Fabricate :demand, project: project, commitment_date: 2.days.ago, end_date: Time.zone.tomorrow }
      let!(:third_demand) { Fabricate :demand, project: project, commitment_date: 3.days.ago, end_date: Time.zone.local(2018, 4, 5, 20, 59, 59) }
      let!(:fourth_demand) { Fabricate :demand, project: project, commitment_date: Time.zone.yesterday, end_date: Time.zone.yesterday }
      let!(:fifth_demand) { Fabricate :demand, project: project, commitment_date: Time.zone.tomorrow, end_date: Time.zone.tomorrow }
      let!(:sixth_demand) { Fabricate :demand, project: project, commitment_date: Time.zone.now, end_date: Time.zone.tomorrow }

      context 'having demands in progress' do
        it { expect(DemandsRepository.instance.work_in_progress_for([project], Time.zone.today)).to eq [third_demand, second_demand, first_demand, sixth_demand] }
      end
    end

    context 'having no demands' do
      context 'having demands in progress' do
        it { expect(DemandsRepository.instance.work_in_progress_for([project], Time.zone.today)).to eq [] }
      end
    end
  end

  describe '#grouped_by_effort_upstream_per_month' do
    before { travel_to Time.zone.local(2018, 4, 5, 10, 0, 0) }
    after { travel_back }

    let(:project) { Fabricate :project, start_date: 2.months.ago, end_date: 2.months.from_now }

    context 'having demands' do
      let!(:first_demand) { Fabricate :demand, project: project, commitment_date: 60.days.ago, end_date: 57.days.ago, effort_upstream: 10, effort_downstream: 5 }
      let!(:second_demand) { Fabricate :demand, project: project, commitment_date: 58.days.ago, end_date: 55.days.ago, effort_upstream: 12, effort_downstream: 20 }
      let!(:third_demand) { Fabricate :demand, project: project, commitment_date: 30.days.ago, end_date: 24.days.ago, effort_upstream: 27, effort_downstream: 40 }
      let!(:fourth_demand) { Fabricate :demand, project: project, commitment_date: 29.days.ago, end_date: 22.days.ago, effort_upstream: 80, effort_downstream: 34 }
      let!(:fifth_demand) { Fabricate :demand, project: project, commitment_date: 10.days.ago, end_date: 7.days.ago, effort_upstream: 56, effort_downstream: 25 }
      let!(:sixth_demand) { Fabricate :demand, project: project, commitment_date: 10.days.ago, end_date: 5.days.ago, effort_upstream: 32, effort_downstream: 87 }
      let!(:seventh_demand) { Fabricate :demand, project: project, commitment_date: 10.days.ago, end_date: nil, effort_upstream: 32, effort_downstream: 87 }

      context 'having demands in progress' do
        it { expect(DemandsRepository.instance.grouped_by_effort_upstream_per_month([project])).to eq([2018.0, 2.0] => 22.0, [2018.0, 3.0] => 195.0) }
      end
    end

    context 'having no demands' do
      context 'having demands in progress' do
        it { expect(DemandsRepository.instance.grouped_by_effort_upstream_per_month([project])).to eq({}) }
      end
    end
  end

  describe '#grouped_by_effort_downstream_per_month' do
    before { travel_to Time.zone.local(2018, 4, 5, 10, 0, 0) }
    after { travel_back }

    let(:project) { Fabricate :project, start_date: 2.months.ago, end_date: 2.months.from_now }

    context 'having demands' do
      let!(:first_demand) { Fabricate :demand, project: project, commitment_date: 60.days.ago, end_date: 57.days.ago, effort_upstream: 10, effort_downstream: 5 }
      let!(:second_demand) { Fabricate :demand, project: project, commitment_date: 58.days.ago, end_date: 55.days.ago, effort_upstream: 12, effort_downstream: 20 }
      let!(:third_demand) { Fabricate :demand, project: project, commitment_date: 30.days.ago, end_date: 24.days.ago, effort_upstream: 27, effort_downstream: 40 }
      let!(:fourth_demand) { Fabricate :demand, project: project, commitment_date: 29.days.ago, end_date: 22.days.ago, effort_upstream: 80, effort_downstream: 34 }
      let!(:fifth_demand) { Fabricate :demand, project: project, commitment_date: 10.days.ago, end_date: 7.days.ago, effort_upstream: 56, effort_downstream: 25 }
      let!(:sixth_demand) { Fabricate :demand, project: project, commitment_date: 10.days.ago, end_date: 5.days.ago, effort_upstream: 32, effort_downstream: 87 }
      let!(:seventh_demand) { Fabricate :demand, project: project, commitment_date: 10.days.ago, end_date: nil, effort_upstream: 32, effort_downstream: 87 }

      context 'having demands in progress' do
        it { expect(DemandsRepository.instance.grouped_by_effort_downstream_per_month([project])).to eq([2018.0, 2.0] => 25.0, [2018.0, 3.0] => 186.0) }
      end
    end

    context 'having no demands' do
      context 'having demands in progress' do
        it { expect(DemandsRepository.instance.grouped_by_effort_downstream_per_month([project])).to eq({}) }
      end
    end
  end
end
