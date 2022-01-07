# frozen_string_literal: true

RSpec.describe UserInvite, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :company }
  end

  context 'validations' do
    context 'simple ones' do
      it { is_expected.to validate_presence_of :invite_type }
      it { is_expected.to validate_presence_of :invite_status }
      it { is_expected.to validate_presence_of :invite_email }
      it { is_expected.to validate_presence_of :invite_object_id }
    end

    context 'complex ones' do
      let(:company) { Fabricate :company }

      context 'uniqueness' do
        context 'same email in the same company with the same status' do
          let!(:user_invite) { Fabricate :user_invite, company: company, invite_email: 'aaa@bbb.com', invite_status: :pending }
          let!(:other_invite) { Fabricate.build :user_invite, company: company, invite_email: 'aaa@bbb.com', invite_status: :pending }

          it 'does not accept the model' do
            expect(other_invite.valid?).to be false
            expect(other_invite.errors[:invite_email]).to eq [I18n.t('activerecord.errors.models.user_invite.invite_email.not_same')]
          end
        end

        context 'same email in the same company with the accepted status' do
          let!(:user_invite) { Fabricate :user_invite, company: company, invite_email: 'aaa@bbb.com', invite_status: :accepted }
          let!(:other_invite) { Fabricate.build :user_invite, company: company, invite_email: 'aaa@bbb.com', invite_status: :pending }

          it 'does not accept the model' do
            expect(other_invite.valid?).to be false
            expect(other_invite.errors[:invite_email]).to eq [I18n.t('activerecord.errors.models.user_invite.invite_email.not_same')]
          end
        end

        context 'with status change' do
          let!(:user_invite) { Fabricate :user_invite, company: company, invite_email: 'aaa@bbb.com', invite_status: :accepted }

          before { user_invite.pending! }

          it { expect(user_invite).to be_pending }
        end

        context 'same email in the same company with the cancelled status' do
          let!(:user_invite) { Fabricate :user_invite, company: company, invite_email: 'aaa@bbb.com', invite_status: :cancelled }
          let!(:other_invite) { Fabricate.build :user_invite, company: company, invite_email: 'aaa@bbb.com', invite_status: :pending }

          it { expect(other_invite.valid?).to be true }
        end

        context 'different email' do
          let!(:user_invite) { Fabricate :user_invite, company: company, invite_email: 'aaa@ccc.com', invite_status: :pending }
          let!(:other_invite) { Fabricate.build :user_invite, company: company, invite_email: 'aaa@bbb.com', invite_status: :pending }

          it { expect(other_invite.valid?).to be true }
        end

        context 'different company' do
          let!(:user_invite) { Fabricate :user_invite, company: company, invite_email: 'aaa@bbb.com', invite_status: :pending }
          let!(:other_invite) { Fabricate.build :user_invite, invite_email: 'aaa@bbb.com', invite_status: :pending }

          it { expect(other_invite.valid?).to be true }
        end
      end
    end
  end
end
