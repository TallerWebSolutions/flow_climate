# frozen_string_literal: true

RSpec.describe SlackConfiguration, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:info_type).with_values(average_demand_cost: 0, current_week_throughput: 1, last_week_delivered_demands_info: 2, demands_wip_info: 3) }
  end

  context 'associations' do
    it { is_expected.to belong_to :team }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :team }
      it { is_expected.to validate_presence_of :room_webhook }
      it { is_expected.to validate_presence_of :notification_hour }
    end

    context 'complex ones' do
      context 'uniqueness' do
        context 'name to product' do
          let(:team) { Fabricate :team }
          let!(:slack_configuration) { Fabricate :slack_configuration, team: team, info_type: 0 }

          context 'same type in same team' do
            let(:other_slack_configuration) { Fabricate.build :slack_configuration, team: team, info_type: 0 }

            it 'does not accept the model' do
              expect(other_slack_configuration.valid?).to be false
              expect(other_slack_configuration.errors[:info_type]).to eq [I18n.t('slack_configuration.info_type.uniqueness')]
            end
          end

          context 'different type in same product' do
            let(:other_slack_configuration) { Fabricate.build :slack_configuration, team: team, info_type: 1 }

            it { expect(other_slack_configuration.valid?).to be true }
          end

          context 'same type in other team' do
            let(:other_team) { Fabricate :team }
            let(:other_slack_configuration) { Fabricate.build :slack_configuration, team: other_team, info_type: 0 }

            it { expect(other_slack_configuration.valid?).to be true }
          end
        end
      end
    end
  end
end
