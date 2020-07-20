# frozen-string-literal: true

RSpec.describe DemandTransitionNotification, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :stage }
    it { is_expected.to belong_to :demand }
  end

  context 'validations' do
    context 'with simple ones' do
      it { is_expected.to validate_presence_of :stage }
      it { is_expected.to validate_presence_of :demand }
    end

    context 'complex ones' do
      context 'uniqueness' do
        let(:stage) { Fabricate :stage }
        let(:demand) { Fabricate :demand }

        it 'rejects duplications and accepts unique ones' do
          Fabricate :demand_transition_notification, stage: stage, demand: demand

          other_stage_notification = Fabricate.build :demand_transition_notification, demand: demand
          expect(other_stage_notification.valid?).to eq true
          expect(other_stage_notification.errors_on(:stage)).to eq []

          other_demand_notification = Fabricate.build :demand_transition_notification, stage: stage
          expect(other_demand_notification.valid?).to eq true
          expect(other_demand_notification.errors_on(:stage)).to eq []

          same_notification = Fabricate.build :demand_transition_notification, stage: stage, demand: demand
          expect(same_notification.valid?).to eq false
          expect(same_notification.errors_on(:stage)).to eq [I18n.t('demand_transition_notification.validations.stage.uniqueness')]
        end
      end
    end
  end
end
