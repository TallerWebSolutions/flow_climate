# frozen_string_literal: true

RSpec.describe DeviseCustom::DeviseCustomers::RegistrationsController do
  before { request.env['devise.mapping'] = Devise.mappings[:devise_customer] }

  describe 'GET #new' do
    before { get :new }

    it { expect(response).to render_template 'devise/registrations/new' }
  end

  describe 'GET #create' do
    context 'with simple new registration' do
      it 'signs in the user and redirects to the boards index' do
        expect_any_instance_of(Devise::RegistrationsController).to receive(:sign_up).once.and_call_original
        post :create, params: { devise_customer: { first_name: 'Xpto', last_name: 'Bla', email: 'foo@bar.com', language: 'en', password: 'abc123', password_confirmation: 'abc123' } }

        expect(assigns(:devise_customer).valid?).to be true
        expect(assigns(:devise_customer).first_name).to eq 'Xpto'
        expect(assigns(:devise_customer).last_name).to eq 'Bla'
        expect(assigns(:devise_customer).email).to eq 'foo@bar.com'
        expect(assigns(:devise_customer).language).to eq 'en'
        expect(response).to redirect_to root_path
      end
    end

    context 'with invite to a customer' do
      let(:customer) { Fabricate :customer }
      let!(:user_invite) { Fabricate :user_invite, invite_object_id: customer.id, invite_email: 'foo@bar.com', invite_status: :pending, invite_type: :customer }

      it 'signs in the user, adds the redirects to the boards index' do
        expect_any_instance_of(Devise::RegistrationsController).to receive(:sign_up).once.and_call_original
        post :create, params: { devise_customer: { first_name: 'Xpto', last_name: 'Bla', email: 'foo@bar.com', password: 'abc123', password_confirmation: 'abc123' } }

        expect(assigns(:devise_customer).valid?).to be true
        expect(assigns(:devise_customer).first_name).to eq 'Xpto'
        expect(assigns(:devise_customer).last_name).to eq 'Bla'
        expect(assigns(:devise_customer).email).to eq 'foo@bar.com'
        expect(assigns(:devise_customer).customers).to eq [customer]
        expect(user_invite.reload).to be_accepted
        expect(response).to redirect_to root_path
      end
    end
  end
end
