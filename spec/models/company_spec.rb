# frozen_string_literal: true

RSpec.describe Company, type: :model do
  it { is_expected.to have_and_belong_to_many :users }
end
