# frozen-string-literal: true

RSpec.describe Jira::JiraApiError, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :demand }
  end
end
