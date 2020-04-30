# frozen_string_literal: true

RSpec.describe UserCompanyRole, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:user_role).with_values(operations: 0, manager: 1, director: 2, customer: 3) }
  end

  context 'associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :company }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :company }

    context 'uniqueness' do
      let!(:company) { Fabricate :company }
      let!(:user) { Fabricate :user }

      let!(:user_company_role) { Fabricate :user_company_role, company: company, user: user }

      let(:same_user_company_role) { Fabricate.build :user_company_role, company: company, user: user }
      let(:other_company_user_company_role) { Fabricate.build :user_company_role, user: user }
      let(:other_user_user_company_role) { Fabricate.build :user_company_role, company: company }

      it 'returns the model invalid with errors on duplicated field' do
        expect(same_user_company_role).not_to be_valid
        expect(same_user_company_role.errors_on(:user)).to eq [I18n.t('user_company_role.validations.user_company')]
      end

      it { expect(other_company_user_company_role).to be_valid }
      it { expect(other_user_user_company_role).to be_valid }
    end
  end
end
