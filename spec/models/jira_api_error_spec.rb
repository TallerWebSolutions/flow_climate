# frozen-string-literal: true

RSpec.describe JiraApiError, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :demand }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :demand }
  end
end
