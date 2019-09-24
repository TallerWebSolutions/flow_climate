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

    describe 'PATCH #toggle_admin' do
      before { patch :toggle_admin, params: { id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #show' do
      before { get :show, params: { id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PUT #update' do
      before { put :update, params: { id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #admin_dashboard' do
      before { get :admin_dashboard }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated as admin' do
    let(:user) { Fabricate :user, admin: true, first_name: 'aaa', last_name: 'zzz' }

    before { sign_in user }

    describe 'PATCH #toggle_admin' do
      let(:tested_user) { Fabricate :user, admin: true }

      it 'toggles admin and redirects to the users_path' do
        patch :toggle_admin, params: { id: tested_user }

        expect(tested_user.reload).not_to be_admin
        expect(response).to redirect_to admin_dashboard_users_path
      end
    end

    describe 'GET #admin_dashboard' do
      let!(:other_user) { Fabricate :user, admin: false, first_name: 'rrr', last_name: 'vvv' }
      let!(:company) { Fabricate :company, name: 'zzz' }
      let!(:other_company) { Fabricate :company, name: 'aaa' }

      it 'toggles admin and redirects to the users_path' do
        get :admin_dashboard

        expect(assigns(:users_list)).to eq [other_user, user]
        expect(assigns(:companies_list)).to eq [other_company, company]
        expect(response).to render_template :admin_dashboard
      end
    end
  end

  context 'authenticated as normal user' do
    let(:user) { Fabricate :user, admin: false }

    before { sign_in user }

    describe 'PATCH #activate_email_notifications' do
      context 'with valid parameters' do
        before { patch :activate_email_notifications, xhr: true }

        it 'activates the email notifications and refresh the view' do
          expect(User.last.email_notifications?).to be true
          expect(response).to render_template 'users/reload_notifications.js.erb'
          expect(response).to render_template 'layouts/_header_menu'
        end
      end
    end

    describe 'PATCH #deactivate_email_notifications' do
      context 'with valid parameters' do
        before { patch :deactivate_email_notifications, xhr: true }

        it 'deactivates the email notifications and refresh the view' do
          expect(User.last.email_notifications?).to be false
          expect(response).to render_template 'users/reload_notifications.js.erb'
          expect(response).to render_template 'layouts/_header_menu'
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

    describe 'PATCH #toggle_admin' do
      before { patch :toggle_admin, params: { id: 'foo' } }

      it { expect(response).to redirect_to root_path }
    end

    describe 'PUT #update' do
      context 'with a valid user' do
        let(:user) { Fabricate :user }

        context 'and valid attributes' do
          let(:file) { Rack::Test::UploadedFile.new(Rails.root.join('spec', 'fixtures', 'default_image.png'), 'image/png') }

          it 'updates the user and redirects to the show' do
            put :update, params: { id: user, user: { first_name: 'Bla', last_name: 'Foo', avatar: file } }

            updated_user = User.last

            expect(updated_user.first_name).to eq 'Bla'
            expect(updated_user.last_name).to eq 'Foo'
            expect(updated_user.avatar.file.file).to match 'default_image.png'
            expect(response).to redirect_to user_path(user)
          end
        end

        context 'and invalid attributes' do
          it 'does not update the user and renders the show again with errors' do
            put :update, params: { id: user, user: { first_name: nil, last_name: nil, avatar: nil } }

            expect(assigns(:user).errors.full_messages).to eq ['Nome não pode ficar em branco', 'Sobrenome não pode ficar em branco']
            expect(response).to render_template :show
          end
        end

        context 'and invalid attributes' do
          before { put :update, params: { id: 'foo', user: { first_name: nil, last_name: nil, avatar: nil } } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #admin_dashboard' do
      before { get :admin_dashboard }

      it { expect(response).to redirect_to root_path }
    end
  end
end
