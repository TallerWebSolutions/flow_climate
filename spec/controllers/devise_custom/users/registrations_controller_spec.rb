# frozen_string_literal: true

RSpec.describe DeviseCustom::Users::RegistrationsController do
  before { request.env['devise.mapping'] = Devise.mappings[:user] }

  describe 'GET #new' do
    before { get :new }

    it { expect(response).to render_template :new }
  end

  describe 'GET #create' do
    it 'signs in the user and redirects to the boards index' do
      expect_any_instance_of(Devise::RegistrationsController).to receive(:sign_up).once.and_call_original
      post :create, params: { user: { first_name: 'Xpto', last_name: 'Bla', email: 'foo@bar.com', language: 'en', password: 'abc123', password_confirmation: 'abc123' } }
      expect(assigns(:user).valid?).to be true
      expect(assigns(:user).first_name).to eq 'Xpto'
      expect(assigns(:user).last_name).to eq 'Bla'
      expect(assigns(:user).email).to eq 'foo@bar.com'
      expect(assigns(:user).language).to eq 'en'
      expect(response).to redirect_to root_path
    end
  end
end
