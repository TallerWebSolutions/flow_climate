# frozen_string_literal: true

RSpec.describe DemandDataProcessment, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :user_plan }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :user_plan }
    it { is_expected.to validate_presence_of :downloaded_content }
    it { is_expected.to validate_presence_of :project_key }
  end
end
