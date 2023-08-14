# frozen_string_literal: true

RSpec.describe UsersController do
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

    describe 'GET #home' do
      before { get :home }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated as admin' do
    let(:user) { Fabricate :user, admin: true, first_name: 'rrr', last_name: 'vvv' }

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
      let!(:other_user) { Fabricate :user, admin: false, first_name: 'aaa', last_name: 'zzz' }
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
          expect(response).to render_template 'users/reload_notifications'
          expect(response).to render_template 'layouts/_header_menu'
        end
      end
    end

    describe 'PATCH #deactivate_email_notifications' do
      context 'with valid parameters' do
        before { patch :deactivate_email_notifications, xhr: true }

        it 'deactivates the email notifications and refresh the view' do
          expect(User.last.email_notifications?).to be false
          expect(response).to render_template 'users/reload_notifications'
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
      let(:product) { Fabricate :product, company: company, customer: customer }

      let!(:project) { Fabricate :project, products: [product], name: 'project', status: :executing, company: company, start_date: Time.zone.local(2019, 12, 16, 14, 0, 0), end_date: Time.zone.local(2020, 1, 18, 14, 0, 0), value: 1000 }
      let!(:other_project) { Fabricate :project, products: [product], name: 'other_project', status: :executing, company: company, start_date: Time.zone.local(2019, 11, 16, 14, 0, 0), end_date: Time.zone.local(2020, 1, 17, 14, 0, 0), value: 3500 }
      let!(:finished_project) { Fabricate :project, products: [product], name: 'finished_project', status: :finished, company: company, start_date: Time.zone.local(2020, 1, 12, 14, 0, 0), end_date: Time.zone.local(2020, 1, 14, 14, 0, 0), value: 500 }
      let!(:waiting_project) { Fabricate :project, products: [product], name: 'waiting_project', status: :waiting, company: company, start_date: Time.zone.local(2020, 1, 12, 14, 0, 0), end_date: Time.zone.local(2020, 1, 14, 14, 0, 0), value: 500 }

      let(:team) { Fabricate :team, company: company }
      let(:first_demand) { Fabricate :demand, team: team, product: product, project: other_project, commitment_date: Time.zone.local(2019, 10, 16, 14, 0, 0), end_date: Time.zone.local(2020, 10, 23, 14, 0, 0) }
      let(:second_demand) { Fabricate :demand, team: team, product: product, project: other_project, commitment_date: Time.zone.local(2019, 12, 16, 14, 0, 0), end_date: Time.zone.local(2019, 12, 22, 14, 0, 0) }
      let(:third_demand) { Fabricate :demand, team: team, product: product, project: project, commitment_date: Time.zone.local(2019, 12, 16, 14, 0, 0), end_date: Time.zone.local(2020, 1, 11, 14, 0, 0) }

      let(:first_team_member) { Fabricate :team_member, company: company, user: user, name: 'first_team_member', start_date: Date.new(2019, 10, 16), end_date: nil }
      let(:second_team_member) { Fabricate :team_member, company: company, user: user, name: 'second_team_member', start_date: Date.new(2019, 10, 16), end_date: nil }
      let(:third_team_member) { Fabricate :team_member, company: company, user: user, name: 'third_team_member', start_date: Date.new(2019, 10, 16), end_date: nil }
      let(:fourth_team_member) { Fabricate :team_member, company: company, user: user, name: 'fourth_team_member', start_date: Date.new(2019, 10, 16), end_date: nil }
      let(:fifth_team_member) { Fabricate :team_member, company: company, user: user, name: 'fifth_team_member', start_date: Date.new(2019, 10, 16), end_date: nil }

      let!(:first_membership) { Fabricate :membership, team: team, team_member: first_team_member, hours_per_month: 120, start_date: Time.zone.local(2019, 12, 16, 14, 0, 0), end_date: nil }
      let!(:second_membership) { Fabricate :membership, team: team, team_member: second_team_member, hours_per_month: 40, start_date: Time.zone.local(2019, 11, 16, 14, 0, 0), end_date: Time.zone.local(2019, 12, 16, 14, 0, 0) }
      let!(:third_membership) { Fabricate :membership, team: team, team_member: third_team_member, hours_per_month: 40, start_date: Time.zone.local(2019, 11, 16, 14, 0, 0), end_date: Time.zone.local(2019, 12, 16, 14, 0, 0) }
      let!(:fourth_membership) { Fabricate :membership, team: team, team_member: fourth_team_member, hours_per_month: 40, start_date: Time.zone.local(2019, 11, 16, 14, 0, 0), end_date: Time.zone.local(2019, 12, 16, 14, 0, 0) }
      let!(:fifth_membership) { Fabricate :membership, team: team, team_member: fifth_team_member, hours_per_month: 40, start_date: Time.zone.local(2019, 11, 16, 14, 0, 0), end_date: Time.zone.local(2019, 12, 16, 14, 0, 0) }

      let!(:first_item_assignment) { Fabricate :item_assignment, demand: first_demand, membership: first_membership, start_time: Time.zone.local(2020, 1, 13, 14, 0, 0), finish_time: Time.zone.local(2020, 1, 14, 10, 0, 0) }
      let!(:second_item_assignment) { Fabricate :item_assignment, demand: first_demand, membership: second_membership, start_time: Time.zone.local(2020, 1, 14, 14, 0, 0), finish_time: nil }
      let!(:third_item_assignment) { Fabricate :item_assignment, demand: first_demand, membership: first_membership, start_time: Time.zone.local(2020, 1, 14, 14, 0, 0), finish_time: nil }
      let!(:fourth_item_assignment) { Fabricate :item_assignment, demand: second_demand, membership: third_membership, start_time: Time.zone.local(2020, 1, 14, 14, 0, 0), finish_time: nil }
      let!(:fifth_item_assignment) { Fabricate :item_assignment, demand: second_demand, membership: fourth_membership, start_time: Time.zone.local(2020, 1, 14, 14, 0, 0), finish_time: nil }
      let!(:sixth_item_assignment) { Fabricate :item_assignment, demand: second_demand, membership: first_membership, start_time: Time.zone.local(2020, 1, 14, 14, 0, 0), finish_time: nil }
      let!(:seventh_item_assignment) { Fabricate :item_assignment, demand: third_demand, membership: first_membership, start_time: Time.zone.local(2020, 1, 14, 14, 0, 0), finish_time: nil }
      let!(:eigth_item_assignment) { Fabricate :item_assignment, demand: third_demand, membership: second_membership, start_time: Time.zone.local(2020, 1, 14, 14, 0, 0), finish_time: nil }
      let!(:nineth_item_assignment) { Fabricate :item_assignment, demand: third_demand, membership: fifth_membership, start_time: Time.zone.local(2020, 1, 12, 14, 0, 0), finish_time: Time.zone.local(2020, 1, 13, 14, 0, 0) }
    end

    describe 'GET #show' do
      context 'with valid parameters' do
        context 'with data' do
          include_context 'user demands data'

          it 'assigns the instance variable, compute the charts, and renders the template' do
            user.update(last_company_id: company.id)

            travel_to Time.zone.local(2020, 1, 16, 14, 0, 0) do
              Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, lead_time_min: 5, lead_time_max: 10, project_quality: 0.85, last_data_in_week: true, lead_time_p80: 2.3, operational_risk: 0.4, project_scope: 20, value_per_demand: 123, flow_pressure: 0.4
              Fabricate :project_consolidation, project: other_project, consolidation_date: 2.days.ago, lead_time_min: 5, lead_time_max: 10, project_quality: 0.6, last_data_in_week: true, lead_time_p80: 4.1, operational_risk: 0.7, project_scope: 10, value_per_demand: 32, flow_pressure: 0.7

              # first_demand = Fabricate :demand, team: team, commitment_date: 4.months.ago, end_date: 3.months.ago
              # second_demand = Fabricate :demand, team: team, commitment_date: 3.months.ago, end_date: 3.weeks.ago
              # third_demand = Fabricate :demand, team: team, commitment_date: 2.months.ago, end_date: 1.month.ago
              # fourth_demand = Fabricate :demand, team: team, commitment_date: 1.month.ago, end_date: 3.days.ago
              # fifth_demand = Fabricate :demand, team: team, commitment_date: 9.weeks.ago, end_date: 2.weeks.ago
              # sixth_demand = Fabricate :demand, team: team, commitment_date: 9.days.ago, end_date: nil

              # Fabricate :item_assignment, demand: first_demand, membership: first_membership
              # Fabricate :item_assignment, demand: second_demand, membership: first_membership
              # Fabricate :item_assignment, demand: third_demand, membership: first_membership
              # Fabricate :item_assignment, demand: fourth_demand, membership: first_membership
              # Fabricate :item_assignment, demand: fifth_demand
              # Fabricate :item_assignment, demand: sixth_demand, membership: first_membership

              allow_any_instance_of(Membership).to(receive(:demands_ids).and_return(Demand.all.map(&:id)))

              get :show, params: { id: user }

              expect(assigns(:user)).to eq user
              expect(assigns(:user_plans)).to eq [other_user_plan, user_plan]
              expect(assigns(:companies_list)).to eq [other_company, company]

              expect(assigns(:member_teams)).to eq [team]
              expect(assigns(:member_projects)).to eq [project, other_project]

              expect(assigns(:projects_quality)).to eq(other_project => [0.6], project => [0.85])
              expect(assigns(:projects_leadtime)[project]).to eq [2.3]
              expect(assigns(:projects_leadtime)[other_project]).to eq [4.1]
              expect(assigns(:projects_risk)[project]).to eq [0.4]
              expect(assigns(:projects_risk)[other_project]).to eq [0.7]
              expect(assigns(:projects_scope)).to eq({ project => [20], other_project => [10] })
              expect(assigns(:projects_value_per_demand)).to eq({ other_project => [32], project => [123] })
              expect(assigns(:projects_flow_pressure)).to eq({ other_project => [0.7], project => [0.4] })

              expect(assigns(:member_effort_chart)).to eq [{ data: [], name: first_team_member.name }]
              expect(assigns(:member_pull_interval_average_chart)).to eq [{ data: [], name: first_team_member.name }]

              expect(assigns(:member_finished_demands)).to match_array [
                first_demand,
                second_demand,
                third_demand
              ]
              expect(assigns(:member_leadtime65)).to be_within(0.01).of(130.10)
              expect(assigns(:member_leadtime80)).to be_within(0.01).of(234.20)
              expect(assigns(:member_leadtime95)).to be_within(0.01).of(338.29)
              expect(assigns(:member_lead_time_histogram_data).keys.first.to_f).to be_within(0.01).of(8_445_600)
              expect(assigns(:member_lead_time_histogram_data).keys.last.to_f).to be_within(0.01).of(24_300_000)
              expect(assigns(:member_lead_time_histogram_data).values).to eq [2, 1]

              expect(response).to render_template :show
            end
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
            put :update, params: { id: user, user: { first_name: 'Bla', last_name: 'Foo', avatar: file, language: 'en' } }

            updated_user = User.last

            expect(updated_user.first_name).to eq 'Bla'
            expect(updated_user.last_name).to eq 'Foo'
            expect(updated_user.avatar.file.file).to include 'default_image'
            expect(updated_user.language).to eq 'en'
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

    describe 'GET #home' do
      context 'with valid parameters' do
        context 'with data' do
          include_context 'user demands data'

          it 'assigns the instance variable, compute the charts, and renders the template' do
            user.update(last_company_id: company.id)

            travel_to Time.zone.local(2020, 1, 16, 14, 0, 0) do
              Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, lead_time_min: 5, lead_time_max: 10, project_quality: 0.85, last_data_in_week: true, lead_time_p80: 2.3, operational_risk: 0.4, project_scope: 20, value_per_demand: 123, flow_pressure: 0.4
              Fabricate :project_consolidation, project: other_project, consolidation_date: 2.days.ago, lead_time_min: 5, lead_time_max: 10, project_quality: 0.6, last_data_in_week: true, lead_time_p80: 4.1, operational_risk: 0.7, project_scope: 10, value_per_demand: 32, flow_pressure: 0.7

              allow_any_instance_of(Membership).to(receive(:demands_ids).and_return(Demand.all.map(&:id)))

              get :home

              expect(assigns(:user)).to eq user
              expect(assigns(:user_plans)).to eq [other_user_plan, user_plan]
              expect(assigns(:companies_list)).to eq [other_company, company]

              expect(assigns(:member_teams)).to eq [team]
              expect(assigns(:member_projects)).to match_array [project, other_project]

              expect(assigns(:projects_quality)).to eq(other_project => [0.6], project => [0.85])
              expect(assigns(:projects_leadtime)[project]).to eq [2.3]
              expect(assigns(:projects_leadtime)[other_project]).to eq [4.1]
              expect(assigns(:projects_risk)[project]).to eq [0.4]
              expect(assigns(:projects_risk)[other_project]).to eq [0.7]
              expect(assigns(:projects_scope)).to eq({ project => [20], other_project => [10] })
              expect(assigns(:projects_value_per_demand)).to eq({ other_project => [32], project => [123] })
              expect(assigns(:projects_flow_pressure)).to eq({ other_project => [0.7], project => [0.4] })

              expect(response).to render_template 'users/show'
            end
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
