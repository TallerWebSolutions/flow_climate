# frozen_string_literal: true

RSpec.describe StagesRepository, type: :repository do
  let(:company) { Fabricate :company }
  let(:customer) { Fabricate :customer, company: company }
  let(:project) { Fabricate :project, customers: [customer] }
  let(:stage) { Fabricate :stage, projects: [project] }
  let(:other_stage) { Fabricate :stage, projects: [project] }

  shared_context 'transitions to hits' do
    let!(:first_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 2.days.ago, last_time_out: 1.day.ago }
    let!(:second_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 1.day.ago, last_time_out: 1.hour.ago }
    let!(:third_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: Time.zone.now, last_time_out: Time.zone.tomorrow }

    let!(:fourth_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 4.days.ago, last_time_out: 1.day.ago }
    let!(:fifth_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 3.days.ago, last_time_out: 1.hour.ago }
    let!(:sixth_transition) { Fabricate :demand_transition, demand: demand, stage: stage, last_time_in: 5.days.ago, last_time_out: nil }
    let!(:seventh_transition) { Fabricate :demand_transition, demand: demand, stage: other_stage, last_time_in: Time.zone.now, last_time_out: Time.zone.tomorrow }
  end

  describe '#qty_hits_by_weekday' do
    before { travel_to Time.zone.local(2018, 5, 29, 18, 25, 0) }

    let(:demand) { Fabricate :demand, project: project }
    let(:other_demand) { Fabricate :demand, project: project }

    context 'with transitions' do
      include_context 'transitions to hits'

      it 'returns with the hits to each weekday' do
        expect(described_class.instance.qty_hits_by_weekday(stage, :last_time_in).keys).to eq [0.0, 1.0, 2.0, 4.0, 5.0, 6.0]
        expect(described_class.instance.qty_hits_by_weekday(stage, :last_time_in).values).to eq [1.0, 1.0, 1.0, 1.0, 1.0, 1.0]

        expect(described_class.instance.qty_hits_by_weekday(stage, :last_time_out).keys).to eq [1.0, 2.0, 3.0]
        expect(described_class.instance.qty_hits_by_weekday(stage, :last_time_out).values).to eq [2.0, 2.0, 1.0]
      end
    end

    context 'with no transitions' do
      it { expect(described_class.instance.qty_hits_by_weekday(stage, :last_time_in)).to eq({}) }
      it { expect(described_class.instance.qty_hits_by_weekday(stage, :last_time_out)).to eq({}) }
    end
  end

  describe '#qty_hits_by_day' do
    before { travel_to Time.zone.local(2018, 5, 29, 18, 25, 0) }

    let(:demand) { Fabricate :demand, project: project }
    let(:other_demand) { Fabricate :demand, project: project }

    context 'having transitions' do
      include_context 'transitions to hits'

      it 'returns with the hits' do
        expect(described_class.instance.qty_hits_by_day(stage, :last_time_out).keys).to eq [28.0, 29.0, 30.0]
        expect(described_class.instance.qty_hits_by_day(stage, :last_time_out).values).to eq [2, 2, 1]
        expect(described_class.instance.qty_hits_by_day(stage, :last_time_in).keys).to eq [24.0, 25.0, 26.0, 27.0, 28.0, 29.0]
        expect(described_class.instance.qty_hits_by_day(stage, :last_time_in).values).to eq [1, 1, 1, 1, 1, 1]
      end
    end

    context 'having no transitions' do
      it { expect(described_class.instance.qty_hits_by_day(stage, :last_time_in)).to eq({}) }
      it { expect(described_class.instance.qty_hits_by_day(stage, :last_time_out)).to eq({}) }
    end
  end

  describe '#qty_hits_by_hour' do
    before { travel_to Time.zone.local(2018, 5, 29, 18, 25, 0) }

    let(:demand) { Fabricate :demand, project: project }
    let(:other_demand) { Fabricate :demand, project: project }

    context 'having transitions' do
      include_context 'transitions to hits'

      it 'returns the hits by hour' do
        expect(described_class.instance.qty_hits_by_hour(stage, :last_time_in).keys).to eq [21.0]
        expect(described_class.instance.qty_hits_by_hour(stage, :last_time_in).values).to eq [6]

        expect(described_class.instance.qty_hits_by_hour(stage, :last_time_out).keys).to eq [3.0, 20.0, 21.0]
        expect(described_class.instance.qty_hits_by_hour(stage, :last_time_out).values).to eq [1, 2, 2]
      end
    end

    context 'having no transitions' do
      it { expect(described_class.instance.qty_hits_by_hour(stage, :last_time_in)).to eq({}) }
      it { expect(described_class.instance.qty_hits_by_hour(stage, :last_time_out)).to eq({}) }
    end
  end

  describe '#average_seconds_in_stage_per_month' do
    before { travel_to Time.zone.local(2018, 5, 29, 18, 25, 0) }

    let(:demand) { Fabricate :demand, project: project }
    let(:other_demand) { Fabricate :demand, project: project }

    context 'having transitions' do
      include_context 'transitions to hits'

      it { expect(described_class.instance.average_seconds_in_stage_per_month(stage)).to eq([[2018.0, 5.0, 140_820.0]]) }
    end

    context 'having no transitions' do
      it { expect(described_class.instance.average_seconds_in_stage_per_month(stage)).to eq [] }
    end
  end

  describe '#save_stage' do
    let(:team) { Fabricate :team, company: company }
    let!(:new_project) { Fabricate :project, team: team }

    it 'saves the stage and adds team projects' do
      stage_params = { team_id: team.id }
      saved_stage = described_class.instance.save_stage(stage, stage_params)
      expect(saved_stage.projects.map(&:id)).to match_array [new_project.id, project.id]
    end
  end
end
