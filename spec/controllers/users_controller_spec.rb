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
    describe 'GET #show' do
      before { get :show, params: { id: 'foo' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    describe 'PATCH #activate_email_notifications' do
      context 'with valid parameters' do
        before { patch :activate_email_notifications, xhr: true }
        it 'activates the email notifications and refresh the view' do
          expect(User.last.email_notifications?).to be true
          expect(response).to render_template 'users/reload_notifications.js.erb'
          expect(response).to render_template 'layouts/_signed_actions'
        end
      end
    end

    describe 'PATCH #deactivate_email_notifications' do
      context 'with valid parameters' do
        before { patch :deactivate_email_notifications, xhr: true }
        it 'deactivates the email notifications and refresh the view' do
          expect(User.last.email_notifications?).to be false
          expect(response).to render_template 'users/reload_notifications.js.erb'
          expect(response).to render_template 'layouts/_signed_actions'
        end
      end
    end

    describe 'GET #show' do
      context 'with valid parameters' do
        context 'having user plans' do
          let!(:user_plan) { Fabricate :user_plan, user: user, finish_at: Time.zone.today }
          let!(:other_user_plan) { Fabricate :user_plan, user: user, finish_at: Time.zone.tomorrow }
          before { get :show, params: { id: user } }
          it 'assigns the instance variable and renders the template' do
            expect(assigns(:user)).to eq user
            expect(assigns(:user_plans)).to eq [other_user_plan, user_plan]
            expect(response).to render_template :show
          end
        end
        context 'having no user plans' do
          before { get :show, params: { id: user } }
          it 'assigns the instance variable and renders the template' do
            expect(assigns(:user)).to eq user
            expect(assigns(:user_plans)).to eq []
            expect(response).to render_template :show
          end
        end
      end
    end
  end
end
