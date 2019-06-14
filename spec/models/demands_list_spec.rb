# frozen_string_literal: true

RSpec.describe DemandsList, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:artifact_type).with_values(story: 0, epic: 1, theme: 2) }
    it { is_expected.to define_enum_for(:demand_type).with_values(feature: 0, bug: 1, performance_improvement: 2, ui: 3, chore: 4, wireframe: 5) }
    it { is_expected.to define_enum_for(:class_of_service).with_values(standard: 0, expedite: 1, fixed_date: 2, intangible: 3) }
  end

  context 'associations' do
    it { is_expected.to belong_to(:demand).with_foreign_key(:id).inverse_of(:demands_list) }
    it { is_expected.to belong_to :project }
  end

  context 'scopes' do
    let(:project) { Fabricate :project }

    describe '.finished' do
      let!(:first_demand) { Fabricate :demand, project: project, end_date: Time.zone.now }
      let!(:second_demand) { Fabricate :demand, project: project, end_date: Time.zone.now }
      let!(:third_demand) { Fabricate :demand, project: project, end_date: nil }

      it { expect(DemandsList.finished.map(&:id)).to match_array [first_demand.id, second_demand.id] }
    end

    describe '.in_wip' do
      let!(:first_demand) { Fabricate :demand, project: project, commitment_date: Time.zone.now, end_date: Time.zone.now }
      let!(:second_demand) { Fabricate :demand, project: project, commitment_date: Time.zone.now, end_date: nil }
      let!(:third_demand) { Fabricate :demand, project: project, commitment_date: Time.zone.now, end_date: nil }

      it { expect(DemandsList.in_wip.map(&:id)).to match_array [second_demand.id, third_demand.id] }
    end

    describe '.not_started' do
      let!(:first_demand) { Fabricate :demand, project: project, commitment_date: nil, end_date: Time.zone.now }
      let!(:second_demand) { Fabricate :demand, project: project, commitment_date: Time.zone.now, end_date: nil }
      let!(:third_demand) { Fabricate :demand, project: project, commitment_date: nil, end_date: nil }

      it { expect(DemandsList.not_started.map(&:id)).to match_array [third_demand.id] }
    end

    describe '.grouped_end_date_by_month' do
      let!(:first_demand) { Fabricate :demand, commitment_date: Time.zone.now, end_date: 2.months.ago }
      let!(:second_demand) { Fabricate :demand, commitment_date: Time.zone.now, end_date: 2.months.ago }
      let!(:third_demand) { Fabricate :demand, commitment_date: Time.zone.now, end_date: 1.month.ago }
      let!(:fourth_demand) { Fabricate :demand, commitment_date: nil }

      it { expect(DemandsList.grouped_end_date_by_month[[2.months.ago.to_date.cwyear, 2.months.ago.to_date.month]].map(&:id)).to match_array [first_demand.id, second_demand.id] }
      it { expect(DemandsList.grouped_end_date_by_month[[1.month.ago.to_date.cwyear, 1.month.ago.to_date.month]].map(&:id)).to eq [third_demand.id] }
    end

    describe '.to_dates' do
      let!(:first_demand) { Fabricate :demand, commitment_date: Time.zone.now, created_date: 3.months.ago, end_date: 2.months.ago }
      let!(:second_demand) { Fabricate :demand, commitment_date: Time.zone.now, created_date: 1.month.ago, end_date: 15.days.ago }
      let!(:third_demand) { Fabricate :demand, commitment_date: Time.zone.now, created_date: 2.months.ago, end_date: Time.zone.now }
      let!(:fourth_demand) { Fabricate :demand, commitment_date: nil, created_date: 4.months.ago, end_date: 1.day.from_now }

      it { expect(DemandsList.to_dates(1.month.ago, Time.zone.now).map(&:id)).to match_array [second_demand.id, third_demand.id] }
    end

    describe '.finished_with_leadtime' do
      let!(:first_demand) { Fabricate :demand, project: project, end_date: Time.zone.now, leadtime: 2 }
      let!(:second_demand) { Fabricate :demand, project: project, end_date: Time.zone.now, leadtime: 3 }
      let!(:third_demand) { Fabricate :demand, project: project, commitment_date: nil, end_date: Time.zone.now }

      it { expect(DemandsList.finished_with_leadtime.map(&:id)).to match_array [first_demand.id, second_demand.id] }
    end

    describe '.with_effort' do
      it 'returns only the demands with effort' do
        first_demand = Fabricate :demand, project: project, effort_downstream: 10, effort_upstream: 0
        second_demand = Fabricate :demand, project: project, effort_downstream: 0, effort_upstream: 10
        Fabricate :demand, project: project, effort_downstream: 0, effort_upstream: 0

        expect(DemandsList.with_effort.map(&:id)).to match_array [first_demand.id, second_demand.id]
      end
    end
  end

  describe '#leadtime_in_days' do
    context 'having leadtime' do
      subject(:demands_list) { DemandsList.first }

      let!(:demand) { Fabricate :demand }

      it { expect(demands_list.leadtime_in_days.to_f).to be_within(1.second).of(1) }
    end

    context 'having no leadtime' do
      subject(:demands_list) { DemandsList.first }

      let!(:demand) { Fabricate :demand, commitment_date: nil, end_date: nil, leadtime: nil }

      it { expect(demands_list.leadtime_in_days.to_f).to eq 0 }
    end
  end

  describe '#total_effort' do
    subject(:demands_list) { DemandsList.first }

    let!(:demand) { Fabricate :demand, effort_upstream: 10, effort_downstream: 20 }

    it { expect(demands_list.total_effort).to eq 30 }
  end
end
