# frozen_string_literal: true

RSpec.describe DemandsList, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:artifact_type).with_values(story: 0, epic: 1, theme: 2) }
    it { is_expected.to define_enum_for(:demand_type).with_values(feature: 0, bug: 1, performance_improvement: 2, ui: 3, chore: 4, wireframe: 5) }
    it { is_expected.to define_enum_for(:class_of_service).with_values(standard: 0, expedite: 1, fixed_date: 2, intangible: 3) }
  end

  context 'associations' do
    it { is_expected.to belong_to :project }
    it { is_expected.to belong_to :product }
    it { is_expected.to belong_to :customer }
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
      let!(:first_demand) { Fabricate :demand, downstream: true, end_date: 2.months.ago }
      let!(:second_demand) { Fabricate :demand, downstream: true, end_date: 2.months.ago }
      let!(:third_demand) { Fabricate :demand, downstream: true, end_date: 1.month.ago }
      let!(:fourth_demand) { Fabricate :demand, downstream: false }

      it { expect(DemandsList.grouped_end_date_by_month[[2.months.ago.to_date.cwyear, 2.months.ago.to_date.month]].map(&:id)).to match_array [first_demand.id, second_demand.id] }
      it { expect(DemandsList.grouped_end_date_by_month[[1.month.ago.to_date.cwyear, 1.month.ago.to_date.month]].map(&:id)).to eq [third_demand.id] }
    end

    describe '.grouped_by_customer' do
      let(:company) { Fabricate :company }
      let(:customer) { Fabricate :customer, company: company }
      let(:other_customer) { Fabricate :customer, company: company }

      let(:first_project) { Fabricate :project, customer: customer }
      let(:second_project) { Fabricate :project, customer: other_customer }
      let(:third_project) { Fabricate :project, customer: other_customer }

      let!(:first_demand) { Fabricate :demand, project: first_project, end_date: 2.months.ago }
      let!(:second_demand) { Fabricate :demand, project: first_project, end_date: 2.months.ago }
      let!(:third_demand) { Fabricate :demand, project: second_project }
      let!(:fourth_demand) { Fabricate :demand, project: third_project }

      it { expect(DemandsList.grouped_by_customer[customer.name].map(&:id)).to match_array [first_demand.id, second_demand.id] }
      it { expect(DemandsList.grouped_by_customer[other_customer.name].map(&:id)).to match_array [third_demand.id, fourth_demand.id] }
    end
  end

  describe '#leadtime_in_days' do
    context 'having leadtime' do
      let!(:demand) { Fabricate :demand }
      subject(:demands_list) { DemandsList.first }
      it { expect(demands_list.leadtime_in_days.to_f).to be_within(1.second).of(1) }
    end
    context 'having no leadtime' do
      let!(:demand) { Fabricate :demand, commitment_date: nil, end_date: nil, leadtime: nil }
      subject(:demands_list) { DemandsList.first }
      it { expect(demands_list.leadtime_in_days.to_f).to eq 0 }
    end
  end

  describe '#touch_time_in_days' do
    context 'having touch_time_in_days' do
      let!(:demand) { Fabricate :demand, total_touch_time: (3 * 86_400) }
      subject(:demands_list) { DemandsList.first }
      it { expect(demands_list.touch_time_in_days.to_f).to eq 3 }
    end
    context 'having no leadtime' do
      let!(:demand) { Fabricate :demand, commitment_date: nil, end_date: nil, leadtime: nil, total_touch_time: 0 }
      subject(:demands_list) { DemandsList.first }
      it { expect(demands_list.touch_time_in_days.to_f).to eq 0 }
    end
  end

  describe '#queue_time_in_days' do
    context 'having touch_time_in_days' do
      let!(:demand) { Fabricate :demand, total_queue_time: (3 * 86_400) }
      subject(:demands_list) { DemandsList.first }
      it { expect(demands_list.queue_time_in_days.to_f).to eq 3 }
    end
    context 'having no leadtime' do
      let!(:demand) { Fabricate :demand, commitment_date: nil, end_date: nil, leadtime: nil, total_queue_time: 0 }
      subject(:demands_list) { DemandsList.first }
      it { expect(demands_list.queue_time_in_days.to_f).to eq 0 }
    end
  end
end
