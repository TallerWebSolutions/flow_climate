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

    describe 'GET #edit' do
      before { get :edit, params: { id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #companies' do
      before { get :companies, params: { id: 'foo' } }

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

          let!(:company) { Fabricate :company, users: [user], name: 'zzz' }
          let!(:other_company) { Fabricate :company, users: [user], name: 'aaa' }
          let!(:project) { Fabricate :project, company: company, end_date: 2.days.ago }
          let!(:other_project) { Fabricate :project, company: company, end_date: 1.day.ago }

          let(:team) { Fabricate :team, company: company }
          let(:first_demand) { Fabricate :demand, team: team, project: other_project }
          let(:second_demand) { Fabricate :demand, team: team, project: other_project }
          let(:third_demand) { Fabricate :demand, team: team, project: project }

          let(:first_team_member) { Fabricate :team_member, company: company, user: user }
          let(:second_team_member) { Fabricate :team_member, company: company, user: user }
          let(:third_team_member) { Fabricate :team_member, company: company, user: user }
          let(:fourth_team_member) { Fabricate :team_member, company: company, user: user }
          let(:fifth_team_member) { Fabricate :team_member, company: company, user: user }

          let!(:first_membership) { Fabricate :membership, team: team, team_member: first_team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }
          let!(:second_membership) { Fabricate :membership, team: team, team_member: second_team_member, hours_per_month: 40, start_date: 2.months.ago, end_date: 1.month.ago }
          let!(:third_membership) { Fabricate :membership, team: team, team_member: third_team_member, hours_per_month: 40, start_date: 2.months.ago, end_date: 1.month.ago }
          let!(:fourth_membership) { Fabricate :membership, team: team, team_member: fourth_team_member, hours_per_month: 40, start_date: 2.months.ago, end_date: 1.month.ago }
          let!(:fifth_membership) { Fabricate :membership, team: team, team_member: fifth_team_member, hours_per_month: 40, start_date: 2.months.ago, end_date: 1.month.ago }

          let!(:first_item_assignment) { Fabricate :item_assignment, demand: first_demand, team_member: first_team_member, start_time: 1.day.ago, finish_time: 2.days.ago }
          let!(:second_item_assignment) { Fabricate :item_assignment, demand: first_demand, team_member: second_team_member, start_time: 2.days.ago, finish_time: nil }
          let!(:third_item_assignment) { Fabricate :item_assignment, demand: first_demand, team_member: first_team_member, start_time: 2.days.ago, finish_time: nil }
          let!(:fourth_item_assignment) { Fabricate :item_assignment, demand: second_demand, team_member: third_team_member, start_time: 2.days.ago, finish_time: nil }
          let!(:fifth_item_assignment) { Fabricate :item_assignment, demand: second_demand, team_member: fourth_team_member, start_time: 2.days.ago, finish_time: nil }
          let!(:sixth_item_assignment) { Fabricate :item_assignment, demand: second_demand, team_member: first_team_member, start_time: 2.days.ago, finish_time: nil }
          let!(:seventh_item_assignment) { Fabricate :item_assignment, demand: third_demand, team_member: first_team_member, start_time: 2.days.ago, finish_time: nil }
          let!(:eigth_item_assignment) { Fabricate :item_assignment, demand: third_demand, team_member: second_team_member, start_time: 2.days.ago, finish_time: nil }
          let!(:nineth_item_assignment) { Fabricate :item_assignment, demand: third_demand, team_member: fifth_team_member, start_time: 4.days.ago, finish_time: 3.days.ago }

          before { get :show, params: { id: user } }

          it 'assigns the instance variable and renders the template' do
            expect(assigns(:user)).to eq user
            expect(assigns(:user_plans)).to eq [other_user_plan, user_plan]
            expect(assigns(:companies_list)).to eq [other_company, company]
            expect(assigns(:pairing_chart)).to eq(second_team_member.name => 2, third_team_member.name => 1, fourth_team_member.name => 1)
            expect(assigns(:member_teams)).to eq [team]
            expect(assigns(:member_projects)).to eq [other_project, project]
            expect(response).to render_template :show
          end
        end

        context 'with no user plans' do
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

    describe 'GET #edit' do
      context 'with valid parameters' do
        context 'with user plans' do
          let!(:user_plan) { Fabricate :user_plan, user: user, finish_at: Time.zone.today }
          let!(:other_user_plan) { Fabricate :user_plan, user: user, finish_at: Time.zone.tomorrow }

          let!(:company) { Fabricate :company, users: [user], name: 'zzz' }
          let!(:other_company) { Fabricate :company, users: [user], name: 'aaa' }

          before { get :edit, params: { id: user } }

          it 'assigns the instance variable and renders the template' do
            expect(assigns(:user)).to eq user
            expect(assigns(:companies_list)).to eq [other_company, company]
            expect(response).to render_template :edit
          end
        end

        context 'with no user plans' do
          before { get :edit, params: { id: user } }

          it 'assigns the instance variable and renders the template' do
            expect(assigns(:user)).to eq user
            expect(response).to render_template :edit
          end
        end
      end
    end

    describe 'PUT #update' do
      context 'with a valid user' do
        let(:user) { Fabricate :user }

        context 'with valid attributes' do
          let(:file) { Rack::Test::UploadedFile.new(Rails.root.join('spec/fixtures/default_image.png'), 'image/png') }

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

        context 'with invalid' do
          context 'attributes' do
            before { put :update, params: { id: 'foo', user: { first_name: nil, last_name: nil, avatar: nil } } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #admin_dashboard' do
      before { get :admin_dashboard }

      it { expect(response).to redirect_to root_path }
    end

    describe 'GET #companies' do
      context 'with valid params' do
        let(:company) { Fabricate :company, users: [user], name: 'zzz' }
        let(:other_company) { Fabricate :company, users: [user], name: 'aaa' }
        let(:out_company) { Fabricate :company }

        it 'assigns the instance variable and renders the template' do
          get :companies, params: { id: user }

          expect(response).to render_template :index
          expect(assigns(:companies)).to eq [other_company, company]
        end
      end
    end
  end
end
