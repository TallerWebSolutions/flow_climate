# frozen_string_literal: true

RSpec.describe SlackConfiguration, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :team }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :team }
    it { is_expected.to validate_presence_of :room_webhook }
    it { is_expected.to validate_presence_of :notification_hour }
  end
end
