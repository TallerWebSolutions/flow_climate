# frozen_string_literal: true

RSpec.describe UserInviteService, type: :service do
  describe '#add_user_to_customer' do
    let(:user) { Fabricate :user }

    let(:company) { Fabricate :company }
    let(:customer) { Fabricate :customer, company: company }

    context 'with no existent user' do
      it 'creates the user invite and sends the email do notify the new user' do
        mail_message = instance_double(Mail::Message)

        expect(UserNotifierMailer).to(receive(:user_invite_to_customer).with('foo@bar.com.br', customer.name, 'xpto.com.br/bla').once { mail_message })
        expect(mail_message).to(receive(:deliver)).once

        invite_customer_message = described_class.instance.invite_customer(company, customer.id, 'foo@bar.com.br', 'xpto.com.br/bla')

        expect(UserInvite.count).to eq 1
        expect(UserInvite.last.invite_email).to eq 'foo@bar.com.br'
        expect(UserInvite.last.invite_object_id).to eq customer.id
        expect(UserInvite.last.invite_type).to eq 'customer'
        expect(UserInvite.last.invite_status).to eq 'pending'
        expect(invite_customer_message).to eq I18n.t('user_invites.create.success')
      end
    end

    context 'with an existent user' do
      it 'adds the user to the customer' do
        user_stubbed = instance_double(DeviseCustomer)
        expect(DeviseCustomer).to(receive(:find_by).once { user_stubbed })
        expect_any_instance_of(Customer).to(receive(:add_user).with(user_stubbed))

        invite_customer_message = described_class.instance.invite_customer(company, customer.id, user.email, 'xpto.com.br/bla')

        expect(invite_customer_message).to eq I18n.t('customers.add_user_to_customer.success')
        expect(UserInvite.count).to eq 0
      end
    end
  end
end
