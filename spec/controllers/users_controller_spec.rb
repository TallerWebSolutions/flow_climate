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

    describe 'GET #user_dashboard_company_tab' do
      before { get :user_dashboard_company_tab, params: { id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #home' do
      before { get :home }

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

    shared_context 'user demands data', shared_context: :metadata do
      let!(:user_plan) { Fabricate :user_plan, user: user, finish_at: Time.zone.today }
      let!(:other_user_plan) { Fabricate :user_plan, user: user, finish_at: Time.zone.tomorrow }

      let!(:company) { Fabricate :company, users: [user], name: 'zzz' }
      let!(:other_company) { Fabricate :company, users: [user], name: 'aaa' }
      let(:customer) { Fabricate :customer, company: company }
      let(:product) { Fabricate :product, customer: customer }

      let!(:project) { Fabricate :project, products: [product], status: :executing, company: company, start_date: 1.month.ago, end_date: 2.days.from_now, value: 1000 }
      let!(:other_project) { Fabricate :project, products: [product], status: :executing, company: company, start_date: 2.months.ago, end_date: 1.day.from_now, value: 3500 }
      let!(:finished_project) { Fabricate :project, products: [product], status: :finished, company: company, start_date: 4.days.ago, end_date: 2.days.ago, value: 500 }
      let!(:waiting_project) { Fabricate :project, products: [product], status: :waiting, company: company, start_date: 4.days.ago, end_date: 2.days.ago, value: 500 }

      let(:team) { Fabricate :team, company: company }
      let(:first_demand) { Fabricate :demand, team: team, product: product, project: other_project, commitment_date: 3.months.ago, end_date: 85.days.ago }
      let(:second_demand) { Fabricate :demand, team: team, product: product, project: other_project, commitment_date: 1.month.ago, end_date: 25.days.ago }
      let(:third_demand) { Fabricate :demand, team: team, product: product, project: project, commitment_date: 1.month.ago, end_date: 5.days.ago }

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

      let!(:first_item_assignment) { Fabricate :item_assignment, demand: first_demand, team_member: first_team_member, start_time: 3.days.ago, finish_time: 52.hours.ago }
      let!(:second_item_assignment) { Fabricate :item_assignment, demand: first_demand, team_member: second_team_member, start_time: 2.days.ago, finish_time: nil }
      let!(:third_item_assignment) { Fabricate :item_assignment, demand: first_demand, team_member: first_team_member, start_time: 2.days.ago, finish_time: nil }
      let!(:fourth_item_assignment) { Fabricate :item_assignment, demand: second_demand, team_member: third_team_member, start_time: 2.days.ago, finish_time: nil }
      let!(:fifth_item_assignment) { Fabricate :item_assignment, demand: second_demand, team_member: fourth_team_member, start_time: 2.days.ago, finish_time: nil }
      let!(:sixth_item_assignment) { Fabricate :item_assignment, demand: second_demand, team_member: first_team_member, start_time: 2.days.ago, finish_time: nil }
      let!(:seventh_item_assignment) { Fabricate :item_assignment, demand: third_demand, team_member: first_team_member, start_time: 2.days.ago, finish_time: nil }
      let!(:eigth_item_assignment) { Fabricate :item_assignment, demand: third_demand, team_member: second_team_member, start_time: 2.days.ago, finish_time: nil }
      let!(:nineth_item_assignment) { Fabricate :item_assignment, demand: third_demand, team_member: fifth_team_member, start_time: 4.days.ago, finish_time: 3.days.ago }
    end

    describe 'GET #show' do
      before { travel_to Time.zone.local(2020, 1, 16, 14, 0, 0) }

      after { travel_back }

      context 'with valid parameters' do
        context 'with data' do
          include_context 'user demands data'

          before do
            user.update(last_company_id: company.id)
            get :show, params: { id: user }
          end

          it 'assigns the instance variable, compute the charts, and renders the template' do
            expect(assigns(:user)).to eq user
            expect(assigns(:user_plans)).to eq [other_user_plan, user_plan]
            expect(assigns(:companies_list)).to eq [other_company, company]

            expect(assigns(:pairing_chart)).to eq(second_team_member.name => 2, third_team_member.name => 1, fourth_team_member.name => 1)
            expect(assigns(:member_teams)).to eq [team]
            expect(assigns(:member_projects)).to eq [project, other_project]
            expect(assigns(:array_of_dates)).to eq [Date.new(2019, 10, 31), Date.new(2019, 11, 30), Date.new(2019, 12, 31), Date.new(2020, 1, 31)]

            expect(assigns(:statistics_information).lead_time_accumulated[0]).to be_within(1).of(7.0)
            expect(assigns(:statistics_information).lead_time_accumulated[1]).to be_within(1).of(7.0)
            expect(assigns(:statistics_information).lead_time_accumulated[2]).to be_within(1).of(7.0)
            expect(assigns(:statistics_information).lead_time_accumulated[3]).to be_within(1).of(26.0)

            expect(assigns(:projects_quality)).to eq(project => 100, other_project => 100)
            expect(assigns(:projects_leadtime)[project]).to be_within(0.5).of(26)
            expect(assigns(:projects_leadtime)[other_project]).to be_within(0.5).of(6.8)
            expect(assigns(:projects_risk)).to eq({ project => 100, other_project => 100 })
            expect(assigns(:projects_scope)).to eq({ project => 30, other_project => 30 })
            expect(assigns(:projects_value_per_demand)).to eq({ project => 1000, other_project => 1750 })
            expect(assigns(:projects_flow_pressure)).to eq({ project => 8.780487804878078, other_project => 12.413793103448336 })

            expect(response).to render_template :show
          end
        end

        context 'with no data' do
          before { get :show, params: { id: user } }

          it 'assigns the instance variable and renders the template' do
            expect(assigns(:user)).to eq user
            expect(assigns(:user_plans)).to eq []
            expect(response).to render_template :show
          end
        end

        context 'with no last company id' do
          let!(:company) { Fabricate :company, users: [user], name: 'zzz' }
          let!(:other_company) { Fabricate :company, users: [user], name: 'aaa' }

          before { get :show, params: { id: user } }

          it 'assigns the instance variable and renders the template' do
            expect(assigns(:user)).to eq user
            expect(assigns(:company)).to eq other_company
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

        context 'with no data' do
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
            expect(response).to redirect_to user_path
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

    describe 'GET #user_dashboard_company_tab' do
      before { travel_to Time.zone.local(2020, 1, 16, 14, 0, 0) }

      after { travel_back }

      context 'with valid parameters' do
        context 'with data' do
          include_context 'user demands data'

          before do
            user.update(last_company_id: company.id)
            get :user_dashboard_company_tab, params: { id: user, company_id: company }, xhr: true
          end

          it 'assigns the instance variable and renders the template' do
            expect(assigns(:pairing_chart)).to eq(second_team_member.name => 2, third_team_member.name => 1, fourth_team_member.name => 1)
            expect(assigns(:member_teams)).to eq [team]
            expect(assigns(:member_projects)).to eq [project, other_project]
            expect(assigns(:array_of_dates)).to eq [Date.new(2019, 10, 31), Date.new(2019, 11, 30), Date.new(2019, 12, 31), Date.new(2020, 1, 31)]

            expect(assigns(:statistics_information).lead_time_accumulated[0]).to be_within(1).of(7.0)
            expect(assigns(:statistics_information).lead_time_accumulated[1]).to be_within(1).of(7.0)
            expect(assigns(:statistics_information).lead_time_accumulated[2]).to be_within(1).of(7.0)
            expect(assigns(:statistics_information).lead_time_accumulated[3]).to be_within(1).of(26.0)

            expect(assigns(:projects_quality)).to eq(project => 100, other_project => 100)
            expect(assigns(:projects_leadtime)[project]).to be_within(0.5).of(26)
            expect(assigns(:projects_leadtime)[other_project]).to be_within(0.5).of(6.8)
            expect(assigns(:projects_risk)).to eq({ project => 100, other_project => 100 })
            expect(assigns(:projects_scope)).to eq({ project => 30, other_project => 30 })
            expect(assigns(:projects_value_per_demand)).to eq({ project => 1000, other_project => 1750 })
            expect(assigns(:projects_flow_pressure)).to eq({ project => 8.780487804878078, other_project => 12.413793103448336 })

            expect(response).to render_template 'users/user_dashboard_company_tab.js.erb'
          end
        end

        context 'with invalid' do
          context 'company' do
            before { get :user_dashboard_company_tab, params: { id: user, company_id: 'foo' } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #home' do
      before { travel_to Time.zone.local(2020, 1, 16, 14, 0, 0) }

      after { travel_back }

      context 'with valid parameters' do
        context 'with data' do
          include_context 'user demands data'

          before do
            user.update(last_company_id: company.id)
            get :home
          end

          it 'assigns the instance variable, compute the charts, and renders the template' do
            expect(assigns(:user)).to eq user
            expect(assigns(:user_plans)).to eq [other_user_plan, user_plan]
            expect(assigns(:companies_list)).to eq [other_company, company]

            expect(assigns(:pairing_chart)).to eq(second_team_member.name => 2, third_team_member.name => 1, fourth_team_member.name => 1)
            expect(assigns(:member_teams)).to eq [team]
            expect(assigns(:member_projects)).to eq [project, other_project]
            expect(assigns(:array_of_dates)).to eq [Date.new(2019, 10, 31), Date.new(2019, 11, 30), Date.new(2019, 12, 31), Date.new(2020, 1, 31)]

            expect(assigns(:statistics_information).lead_time_accumulated[0]).to be_within(1).of(7.0)
            expect(assigns(:statistics_information).lead_time_accumulated[1]).to be_within(1).of(7.0)
            expect(assigns(:statistics_information).lead_time_accumulated[2]).to be_within(1).of(7.0)
            expect(assigns(:statistics_information).lead_time_accumulated[3]).to be_within(1).of(26.0)

            expect(assigns(:projects_quality)).to eq(project => 100, other_project => 100)
            expect(assigns(:projects_leadtime)[project]).to be_within(0.5).of(26)
            expect(assigns(:projects_leadtime)[other_project]).to be_within(0.5).of(6.8)
            expect(assigns(:projects_risk)).to eq({ project => 100, other_project => 100 })
            expect(assigns(:projects_scope)).to eq({ project => 30, other_project => 30 })
            expect(assigns(:projects_value_per_demand)).to eq({ project => 1000, other_project => 1750 })
            expect(assigns(:projects_flow_pressure)).to eq({ project => 8.780487804878078, other_project => 12.413793103448336 })

            expect(response).to render_template 'users/show'
          end
        end

        context 'with no data' do
          before { get :home }

          it 'assigns the instance variable and renders the template' do
            expect(assigns(:user)).to eq user
            expect(assigns(:user_plans)).to eq []
            expect(response).to render_template 'users/show'
          end
        end

        context 'with no last company id' do
          let!(:company) { Fabricate :company, users: [user], name: 'zzz' }
          let!(:other_company) { Fabricate :company, users: [user], name: 'aaa' }

          before { get :home }

          it 'assigns the instance variable and renders the template' do
            expect(assigns(:user)).to eq user
            expect(assigns(:company)).to eq other_company
            expect(response).to render_template 'users/show'
          end
        end
      end
    end
  end
end
