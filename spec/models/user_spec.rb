# frozen_string_literal: true

RSpec.describe User, type: :model do
  context 'associations' do
    it { is_expected.to have_and_belong_to_many(:companies) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }
    it { is_expected.to validate_presence_of :email }
  end

  context 'scopes' do
    describe '.to_notify_email' do
      context 'having data' do
        let(:first_user) { Fabricate :user, email_notifications: true }
        let(:second_user) { Fabricate :user, email_notifications: true }
        let(:third_user) { Fabricate :user, email_notifications: false }

        it { expect(User.to_notify_email).to match_array [first_user, second_user] }
      end
      context 'having no data' do
        it { expect(User.to_notify_email).to match_array [] }
      end
    end
  end
end
