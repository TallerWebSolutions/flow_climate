# frozen-string-literal: true

RSpec.describe Initiative, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
    it { is_expected.to have_many(:projects).dependent(:nullify) }
    it { is_expected.to have_many(:demands).through(:projects) }
    it { is_expected.to have_many(:tasks).through(:projects) }
    it { is_expected.to have_many(:initiative_consolidations).class_name('Consolidations::InitiativeConsolidation').dependent(:destroy) }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :name }
      it { is_expected.to validate_presence_of :start_date }
      it { is_expected.to validate_presence_of :end_date }
    end

    context 'complex ones' do
      context 'uniqueness' do
        it 'does not accept initiatives using the same name inside the same company' do
          company = Fabricate :company
          first_initiative = Fabricate :initiative, company: company, name: 'foo'
          second_initiative = Fabricate :initiative, company: company
          third_initiative = Fabricate :initiative, name: 'foo'
          invalid = Fabricate.build :initiative, company: company, name: 'foo'

          expect(first_initiative.valid?).to eq true
          expect(second_initiative.valid?).to eq true
          expect(third_initiative.valid?).to eq true
          expect(invalid.valid?).to eq false
        end
      end
    end
  end

  context 'callbacks' do
    context 'before_save' do
      describe '#set_dates' do
        it 'sets new dates when it has new projects' do
          travel_to Time.zone.local(2022, 1, 30, 10, 0, 0) do
            initiative = Fabricate :initiative, start_date: 2.days.ago, end_date: 2.days.from_now
            other_initiative = Fabricate :initiative, start_date: 2.days.ago, end_date: 2.days.from_now

            project = Fabricate :project, start_date: 4.days.ago, end_date: 4.days.from_now
            other_project = Fabricate :project, start_date: 3.days.ago, end_date: 3.days.from_now

            initiative.projects = [project, other_project]
            initiative.save

            other_initiative.save

            expect(initiative.start_date).to eq project.start_date
            expect(initiative.end_date).to eq project.end_date

            expect(other_initiative.start_date).to eq 2.days.ago.to_date
            expect(other_initiative.end_date).to eq 2.days.from_now.to_date
          end
        end
      end
    end
  end

  describe '#remaining_weeks' do
    it 'returns the remaining weeks for the initiative' do
      travel_to Time.zone.local(2022, 1, 30, 10, 0, 0) do
        not_finished_initiative = Fabricate :initiative, start_date: 4.weeks.ago, end_date: 3.weeks.from_now
        finished_initiative = Fabricate :initiative, start_date: 3.months.ago, end_date: 2.months.ago

        expect(not_finished_initiative.remaining_weeks).to eq 4
        expect(not_finished_initiative.remaining_weeks(3.weeks.ago.to_date)).to eq 7
        expect(finished_initiative.remaining_weeks).to eq 0
      end
    end
  end

  describe '#current_tasks_operational_risk' do
    context 'with data' do
      it 'returns current tasks operational risk' do
        travel_to Time.zone.local(2022, 1, 30, 10, 0, 0) do
          initiative = Fabricate :initiative, start_date: 4.weeks.ago, end_date: 3.weeks.from_now
          Fabricate :initiative_consolidation, initiative: initiative, consolidation_date: 2.days.ago, tasks_operational_risk: 0.2
          Fabricate :initiative_consolidation, initiative: initiative, consolidation_date: 1.day.ago, tasks_operational_risk: 0.7
          Fabricate :initiative_consolidation, consolidation_date: Time.zone.now, tasks_operational_risk: 0.4

          expect(initiative.current_tasks_operational_risk).to eq 0.7
        end
      end
    end

    context 'without data' do
      it 'returns zero as tasks operational risk' do
        travel_to Time.zone.local(2022, 1, 30, 10, 0, 0) do
          initiative = Fabricate :initiative, start_date: 4.weeks.ago, end_date: 3.weeks.from_now

          expect(initiative.current_tasks_operational_risk).to eq 0
        end
      end
    end
  end

  describe '#last_update' do
    context 'with data' do
      it 'returns current tasks operational risk' do
        travel_to Time.zone.local(2022, 1, 30, 10, 0, 0) do
          initiative = Fabricate :initiative, start_date: 4.weeks.ago, end_date: 3.weeks.from_now
          Fabricate :initiative_consolidation, initiative: initiative, consolidation_date: 2.days.ago, tasks_operational_risk: 0.2
          Fabricate :initiative_consolidation, initiative: initiative, consolidation_date: 1.day.ago, tasks_operational_risk: 0.7
          Fabricate :initiative_consolidation, consolidation_date: Time.zone.now, tasks_operational_risk: 0.4

          expect(initiative.last_update).to eq initiative.created_at
        end
      end
    end

    context 'without data' do
      it 'returns zero as tasks operational risk' do
        travel_to Time.zone.local(2022, 1, 30, 10, 0, 0) do
          initiative = Fabricate :initiative, start_date: 4.weeks.ago, end_date: 3.weeks.from_now

          expect(initiative.last_update).to eq nil
        end
      end
    end
  end
end
