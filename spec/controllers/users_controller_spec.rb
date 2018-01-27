# frozen_string_literal: true

RSpec.describe UsersController, type: :controller do
  context 'unauthenticated' do
    describe 'PATCH #activate_email_notifications' do
      before { patch :activate_email_notifications }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PATCH #deactivate_email_notifications' do
      before { patch :deactivate_email_notifications }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    describe 'PATCH #activate_email_notifications' do
      context 'with valid parameters' do
        before { patch :activate_email_notifications, xhr: true }
        it 'assigns the instance variable and renders the template' do
          expect(User.last.email_notifications?).to be true
          expect(response).to render_template 'users/reload_notifications.js.erb'
          expect(response).to render_template 'layouts/_signed_actions'
        end
      end
    end

    describe 'PATCH #deactivate_email_notifications' do
      context 'with valid parameters' do
        before { patch :deactivate_email_notifications, xhr: true }
        it 'assigns the instance variable and renders the template' do
          expect(User.last.email_notifications?).to be false
          expect(response).to render_template 'users/reload_notifications.js.erb'
          expect(response).to render_template 'layouts/_signed_actions'
        end
      end
    end
  end
end
