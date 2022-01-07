# frozen_string_literal: true

RSpec.describe DemandComment, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :demand }
    it { is_expected.to belong_to :team_member }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :comment_date }
    it { is_expected.to validate_presence_of :comment_text }
  end
end
