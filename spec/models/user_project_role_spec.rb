# frozen_string_literal: true

RSpec.describe UserProjectRole, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:role_in_project).with(user: 0, manager: 1, owner: 2) }
  end

  context 'associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :project }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :project }
    it { is_expected.to validate_presence_of :role_in_project }
  end
end
