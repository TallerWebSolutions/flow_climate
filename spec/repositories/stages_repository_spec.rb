# frozen_string_literal: true

RSpec.describe StagesRepository, type: :repository do
  let(:company) { Fabricate :company }
  let(:customer) { Fabricate :customer, company: company }
  let(:project) { Fabricate :project, customer: customer }
  let(:stage) { Fabricate :stage, projects: [project] }
  let(:other_stage) { Fabricate :stage, projects: [project] }

  describe '#qty_hits_by_weekday' do
    before { travel_to Time.zone.local(2018, 5, 29, 18, 25, 0) }
    after { travel_back }

    let(:demand) { Fabricate :demand, project: project }
    let(:other_demand) { Fabricate :demand, project: project }

    context 'having transitions' do
      let!(:first_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.days.ago, last_time_out: 1.day.ago }
      let!(:second_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 1.day.ago, last_time_out: 1.hour.ago }
      let!(:third_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.now, last_time_out: Time.zone.tomorrow }

      let!(:fourth_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.days.ago, last_time_out: 1.day.ago }
      let!(:fifth_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 1.day.ago, last_time_out: 1.hour.ago }
      let!(:sixth_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 1.day.ago, last_time_out: nil }
      let!(:seventh_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: Time.zone.now, last_time_out: Time.zone.tomorrow }

      it { expect(StagesRepository.instance.qty_hits_by_weekday(stage, :last_time_in)).to eq(0.0 => 2, 1.0 => 3, 2.0 => 1) }
      it { expect(StagesRepository.instance.qty_hits_by_weekday(stage, :last_time_out)).to eq(1.0 => 2, 2.0 => 2, 3.0 => 1) }
    end

    context 'having no transitions' do
      it { expect(StagesRepository.instance.qty_hits_by_weekday(stage, :last_time_in)).to eq({}) }
      it { expect(StagesRepository.instance.qty_hits_by_weekday(stage, :last_time_out)).to eq({}) }
    end
  end

  describe '#qty_hits_by_day' do
    before { travel_to Time.zone.local(2018, 5, 29, 18, 25, 0) }
    after { travel_back }

    let(:demand) { Fabricate :demand, project: project }
    let(:other_demand) { Fabricate :demand, project: project }

    context 'having transitions' do
      let!(:first_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.days.ago, last_time_out: 1.day.ago }
      let!(:second_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 1.day.ago, last_time_out: 1.hour.ago }
      let!(:third_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.now, last_time_out: Time.zone.tomorrow }

      let!(:fourth_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.days.ago, last_time_out: 1.day.ago }
      let!(:fifth_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 1.day.ago, last_time_out: 1.hour.ago }
      let!(:sixth_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 1.day.ago, last_time_out: nil }
      let!(:seventh_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: Time.zone.now, last_time_out: Time.zone.tomorrow }

      it { expect(StagesRepository.instance.qty_hits_by_day(stage, :last_time_in)).to eq(27.0 => 2, 28.0 => 3, 29.0 => 1) }
      it { expect(StagesRepository.instance.qty_hits_by_day(stage, :last_time_out)).to eq(28.0 => 2, 29.0 => 2, 30.0 => 1) }
    end

    context 'having no transitions' do
      it { expect(StagesRepository.instance.qty_hits_by_day(stage, :last_time_in)).to eq({}) }
      it { expect(StagesRepository.instance.qty_hits_by_day(stage, :last_time_out)).to eq({}) }
    end
  end

  describe '#qty_hits_by_hour' do
    before { travel_to Time.zone.local(2018, 5, 29, 18, 25, 0) }
    after { travel_back }

    let(:demand) { Fabricate :demand, project: project }
    let(:other_demand) { Fabricate :demand, project: project }

    context 'having transitions' do
      let!(:first_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.hours.ago, last_time_out: 1.hour.ago }
      let!(:second_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 1.hour.ago, last_time_out: 1.hour.ago }
      let!(:third_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.now, last_time_out: Time.zone.tomorrow }

      let!(:fourth_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.hours.ago, last_time_out: 1.hour.ago }
      let!(:fifth_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 1.hour.ago, last_time_out: 1.hour.ago }
      let!(:sixth_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 1.hour.ago, last_time_out: nil }
      let!(:seventh_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: Time.zone.now, last_time_out: Time.zone.tomorrow }

      it { expect(StagesRepository.instance.qty_hits_by_hour(stage, :last_time_in)).to eq(19.0 => 2, 20.0 => 3, 21.0 => 1) }
      it { expect(StagesRepository.instance.qty_hits_by_hour(stage, :last_time_out)).to eq(3.0 => 1, 20.0 => 4) }
    end

    context 'having no transitions' do
      it { expect(StagesRepository.instance.qty_hits_by_hour(stage, :last_time_in)).to eq({}) }
      it { expect(StagesRepository.instance.qty_hits_by_hour(stage, :last_time_out)).to eq({}) }
    end
  end

  describe '#average_seconds_in_stage_per_month' do
    before { travel_to Time.zone.local(2018, 5, 29, 18, 25, 0) }
    after { travel_back }

    let(:demand) { Fabricate :demand, project: project }
    let(:other_demand) { Fabricate :demand, project: project }

    context 'having transitions' do
      let!(:first_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.months.ago, last_time_out: 40.days.ago }
      let!(:second_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 1.month.ago, last_time_out: 25.days.ago }
      let!(:third_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.yesterday, last_time_out: 1.hour.ago }

      let!(:fourth_transition) { Fabricate :demand_transition, demand: other_demand, stage: stage, last_time_in: 2.months.ago, last_time_out: 40.days.ago }
      let!(:fifth_transition) { Fabricate :demand_transition, demand: other_demand, stage: stage, last_time_in: 1.month.ago, last_time_out: nil }
      let!(:sixth_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: Time.zone.yesterday, last_time_out: 1.hour.ago }

      it { expect(StagesRepository.instance.average_seconds_in_stage_per_month(stage)).to eq([[2018.0, 3.0, 1_814_400.0], [2018.0, 4.0, 432_000.0], [2018.0, 5.0, 149_100.0]]) }
    end

    context 'having no transitions' do
      it { expect(StagesRepository.instance.average_seconds_in_stage_per_month(stage)).to eq [] }
    end
  end
end
