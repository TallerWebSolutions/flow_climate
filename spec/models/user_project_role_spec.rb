# frozen_string_literal: true

RSpec.describe UserProjectRole do
  context 'enums' do
    it { is_expected.to define_enum_for(:role_in_project).with_values(team: 0, manager: 1, customer: 2) }
  end

  context 'associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :project }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :role_in_project }

    it 'uniqueness of user and project' do
      user = Fabricate :user
      project = Fabricate :project

      described_class.create(user: user, project: project)

      expect(Fabricate.build(:user_project_role, user: user, project: project)).not_to be_valid
      expect(Fabricate.build(:user_project_role, user: user)).to be_valid
      expect(Fabricate.build(:user_project_role, project: project)).to be_valid
    end
  end
end
