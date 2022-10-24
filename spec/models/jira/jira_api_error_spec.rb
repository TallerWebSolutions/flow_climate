# frozen_string_literal: true

RSpec.describe Jira::JiraApiError do
  context 'associations' do
    it { is_expected.to belong_to :demand }
  end
end
