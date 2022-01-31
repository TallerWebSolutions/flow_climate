# frozen_string_literal: true

RSpec.describe TeamMembersController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #show' do
      before { get :show, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'xpto', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PUT #update' do
      before { put :update, params: { company_id: 'xpto', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'xpto', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PATCH #associate_user' do
      before { patch :associate_user, params: { company_id: 'xpto', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PATCH #dissociate_user' do
      before { patch :dissociate_user, params: { company_id: 'xpto', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #search_team_members' do
      before { get :search_team_members, params: { company_id: 'xpto', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #pairings' do
      before { get :pairings, params: { company_id: 'xpto', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }

    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:team) { Fabricate :team, company: company }

    let!(:team_member) { Fabricate :team_member, company: company, name: 'ddd', start_date: 1.day.ago, end_date: nil }
    let!(:other_team_member) { Fabricate :team_member, company: company, name: 'aaa', start_date: 1.day.ago, end_date: nil }
    let!(:inactive_team_member) { Fabricate :team_member, company: company, name: 'eee', start_date: 1.day.ago, end_date: Time.zone.today }

    describe 'GET #show' do
      let(:team) { Fabricate :team, company: company }

      context 'valid parameters' do
        it 'assigns the instance variables and renders the template' do
          travel_to Time.zone.local(2021, 12, 1, 10, 0, 0) do
            first_membership = Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil
            Fabricate :membership, team: team, team_member: team_member, hours_per_month: 40, start_date: 2.months.ago, end_date: 1.month.ago
            first_demand = Fabricate :demand, team: team, commitment_date: 4.months.ago, end_date: 3.months.ago
            second_demand = Fabricate :demand, team: team, commitment_date: 3.months.ago, end_date: 3.weeks.ago
            third_demand = Fabricate :demand, team: team, commitment_date: 2.months.ago, end_date: 1.month.ago
            fourth_demand = Fabricate :demand, team: team, commitment_date: 1.month.ago, end_date: 3.days.ago
            fifth_demand = Fabricate :demand, team: team, commitment_date: 9.weeks.ago, end_date: 2.weeks.ago
            sixth_demand = Fabricate :demand, team: team, commitment_date: 9.days.ago, end_date: nil

            Fabricate :item_assignment, demand: first_demand, membership: first_membership
            Fabricate :item_assignment, demand: second_demand, membership: first_membership
            Fabricate :item_assignment, demand: third_demand, membership: first_membership
            Fabricate :item_assignment, demand: fourth_demand, membership: first_membership
            Fabricate :item_assignment, demand: fifth_demand
            Fabricate :item_assignment, demand: sixth_demand, membership: first_membership

            get :show, params: { company_id: company.id, id: team_member }

            expect(response).to have_http_status :ok
            expect(response).to render_template 'team_members/show'
            expect(assigns(:company)).to eq company
            expect(assigns(:team_member)).to eq team_member
            expect(assigns(:member_effort_chart)).to eq [{ data: [], name: team_member.name }]
            expect(assigns(:member_pull_interval_average_chart)).to eq [{ data: [], name: team_member.name }]
            expect(assigns(:member_finished_demands)).to match_array [
              first_demand,
              second_demand,
              third_demand,
              fourth_demand
            ]
            expect(assigns(:member_leadtime65)).to be_within(0.01).of(31.00)
            expect(assigns(:member_leadtime80)).to be_within(0.01).of(46.60)
            expect(assigns(:member_leadtime95)).to be_within(0.01).of(64.15)
            expect(assigns(:member_lead_time_histogram_data).keys.first.to_f).to be_within(0.01).of(3_261_600)
            expect(assigns(:member_lead_time_histogram_data).keys.last.to_f).to be_within(0.01).of(5_119_200)
            expect(assigns(:member_lead_time_histogram_data).values).to eq [3, 1]
          end
        end
      end

      context 'invalid' do
        context 'team_member' do
          before { get :show, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :show, params: { company_id: 'foo', id: team_member } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :show, params: { company_id: company, id: team_member } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'a different company' do
            let(:other_company) { Fabricate :company, users: [user] }
            let!(:team_member) { Fabricate :team_member, company: company }

            before { get :show, params: { company_id: other_company, id: team_member } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company }, xhr: true }

        it 'instantiates a new Team Member and renders the template' do
          expect(response).to render_template 'team_members/new'
          expect(assigns(:team_members)).to eq [other_team_member, team_member, inactive_team_member]
          expect(assigns(:team_member)).to be_a_new TeamMember
        end
      end

      context 'invalid parameters' do
        context 'non-existent company' do
          before { get :new, params: { company_id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :new, params: { company_id: company }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, team_member: { name: 'foo', jira_account_user_email: 'foo@bar.com', jira_account_id: 'jira_account_id', billable: false, active: false, hours_per_month: 10, monthly_payment: 100, hours_per_month: 10, billable_type: :outsourcing, start_date: 1.day.ago.to_date, end_date: Time.zone.today } }, xhr: true }

        it 'creates the new team member and redirects to team show' do
          expect(response).to render_template 'team_members/create'

          expect(TeamMember.all.count).to eq 4
          expect(TeamMember.last.name).to eq 'foo'
          expect(TeamMember.last.jira_account_user_email).to eq 'foo@bar.com'
          expect(TeamMember.last.jira_account_id).to eq 'jira_account_id'
          expect(TeamMember.last.billable).to be false
          expect(TeamMember.last.hours_per_month).to eq 10
          expect(TeamMember.last.monthly_payment).to eq 100
          expect(TeamMember.last.billable_type).to eq 'outsourcing'
          expect(TeamMember.last.start_date).to eq 1.day.ago.to_date
          expect(TeamMember.last.end_date).to eq Time.zone.today
          expect(assigns(:team_members)).to eq company.reload.team_members.order(:name)
        end
      end

      context 'passing invalid parameters' do
        before { post :create, params: { company_id: company, team_member: { name: '' } }, xhr: true }

        it 'does not create the team member and re-render the template with the errors' do
          expect(TeamMember.all.count).to eq 3
          expect(response).to render_template 'team_members/create'
          expect(assigns(:team_member).errors.full_messages).to eq ['Nome não pode ficar em branco']
        end
      end
    end

    describe 'GET #edit' do
      let(:team) { Fabricate :team, company: company }
      let(:team_member) { Fabricate :team_member, company: company }
      let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company.id, id: team_member }, xhr: true }

        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template 'team_members/edit'
          expect(assigns(:company)).to eq company
          expect(assigns(:team_member)).to eq team_member
          expect(assigns(:team_members)).to eq company.reload.team_members.order(:name)
        end
      end

      context 'invalid' do
        context 'team_member' do
          before { get :edit, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :edit, params: { company_id: 'foo', id: team_member }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :edit, params: { company_id: company, id: team_member }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let(:team) { Fabricate :team, company: company }
      let(:other_team) { Fabricate :team, company: company }
      let(:team_member) { Fabricate :team_member, company: company }
      let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }

      context 'passing valid parameters' do
        before { put :update, params: { company_id: company, id: team_member, team_member: { team: other_team, name: 'foo', jira_account_user_email: 'foo@bar.com', jira_account_id: 'jira_account_id', billable: false, active: false, monthly_payment: 100, hours_per_month: 10, billable_type: :outsourcing, start_date: 1.day.ago.to_date, end_date: Time.zone.today } }, xhr: true }

        it 'updates the member and redirects to team show' do
          team_member_updated = team_member.reload
          expect(team_member_updated.name).to eq 'foo'
          expect(team_member_updated.jira_account_user_email).to eq 'foo@bar.com'
          expect(team_member_updated.jira_account_id).to eq 'jira_account_id'
          expect(team_member_updated.billable).to be false
          expect(team_member_updated.hours_per_month.to_f).to be 10.0
          expect(team_member_updated.monthly_payment.to_f).to be 100.0
          expect(team_member_updated.billable_type).to eq 'outsourcing'
          expect(team_member_updated.start_date).to eq 1.day.ago.to_date
          expect(team_member_updated.end_date).to eq Time.zone.today
          expect(assigns(:team_members)).to eq company.reload.team_members.order(:name)
          expect(response).to render_template 'team_members/update'
        end
      end

      context 'passing invalid' do
        context 'team member parameters' do
          before { put :update, params: { company_id: company, id: team_member, team_member: { team: other_team, name: '', billable: nil, active: nil, monthly_payment: nil, hours_per_month: nil, billable_type: nil } }, xhr: true }

          it 'does not update the member and re-render the template with the errors' do
            expect(response).to render_template 'team_members/update'
            expect(assigns(:team_member).errors.full_messages).to eq ['Nome não pode ficar em branco']
          end
        end

        context 'non-existent team member' do
          before { put :update, params: { company_id: company, id: 'foo', team_member: { team: other_team, name: 'foo', billable: false, active: false, monthly_payment: 100, hours_per_month: 10, billable_type: :outsourcing } }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { put :update, params: { company_id: company, id: team_member, team_member: { team: other_team, name: 'foo', billable: false, active: false, monthly_payment: 100, hours_per_month: 10, billable_type: :outsourcing } }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:team) { Fabricate :team, company: company }
      let(:team_member) { Fabricate :team_member, company: company }
      let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 120, start_date: 1.month.ago, end_date: nil }

      context 'with valid data' do
        it 'deletes the member and renders the template' do
          delete :destroy, params: { company_id: company, id: team_member }, xhr: true

          expect(TeamMember.all.count).to eq 2
          expect(response).to render_template 'team_members/destroy'
        end
      end

      context 'with invalid' do
        context 'non-existent team member' do
          before { delete :destroy, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { delete :destroy, params: { company_id: company, id: team_member }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PATCH #associate_user' do
      let(:team) { Fabricate :team, company: company }
      let(:other_team) { Fabricate :team, company: company }
      let(:team_member) { Fabricate :team_member, company: company }

      context 'passing valid parameters' do
        before { patch :associate_user, params: { company_id: company, id: team_member }, xhr: true }

        it 'associates the user to the team member and renders the template' do
          team_member_updated = team_member.reload
          expect(team_member_updated.user).to eq user
          expect(response).to render_template 'team_members/associate_dissociate_user'
        end
      end

      context 'passing invalid' do
        context 'non-existent team member' do
          before { patch :associate_user, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { patch :associate_user, params: { company_id: company, id: team_member }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PATCH #dissociate_user' do
      let(:team) { Fabricate :team, company: company }
      let(:other_team) { Fabricate :team, company: company }
      let(:team_member) { Fabricate :team_member, company: company, name: 'team_member' }

      context 'passing valid parameters' do
        before { patch :dissociate_user, params: { company_id: company, id: team_member }, xhr: true }

        it 'associates the user to the team member and renders the template' do
          team_member_updated = team_member.reload
          expect(team_member_updated.user).to be_nil
          expect(response).to render_template 'team_members/associate_dissociate_user'
        end
      end

      context 'passing invalid' do
        context 'non-existent team member' do
          before { patch :dissociate_user, params: { company_id: company, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { patch :dissociate_user, params: { company_id: company, id: team_member }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #search_team_members' do
      context 'valid parameters' do
        context 'with no search parameters' do
          before { get :search_team_members, params: { company_id: company }, xhr: true }

          it 'searches for the team members and renders the template' do
            expect(response).to render_template 'team_members/search_team_members'
            expect(assigns(:team_members)).to eq [other_team_member, team_member, inactive_team_member]
          end
        end

        context 'with active status true' do
          before { get :search_team_members, params: { company_id: company, team_member_status: 'true' }, xhr: true }

          it 'searches for the team members and renders the template' do
            expect(response).to render_template 'team_members/search_team_members'
            expect(assigns(:team_members)).to eq [other_team_member, team_member]
          end
        end

        context 'with active status false' do
          before { get :search_team_members, params: { company_id: company, team_member_status: 'false' }, xhr: true }

          it 'searches for the team members and renders the template' do
            expect(response).to render_template 'team_members/search_team_members'
            expect(assigns(:team_members)).to eq [inactive_team_member]
          end
        end
      end

      context 'invalid' do
        context 'non-existent company' do
          before { get :search_team_members, params: { company_id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :search_team_members, params: { company_id: company }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #pairings' do
      context 'valid parameters' do
        context 'with no data' do
          before { get :pairings, params: { company_id: company, id: team_member } }

          it 'searches for the team members and renders the template' do
            expect(response).to render_template 'team_members/pairings'
            expect(assigns(:operations_dashboards)).to eq []
          end
        end

        context 'with data' do
          let(:second_team_member) { Fabricate :team_member, company: company, name: 'second_team_member' }
          let(:third_team_member) { Fabricate :team_member, company: company, name: 'third_team_member' }

          let!(:operations_dashboard) { Fabricate :operations_dashboard, team_member: team_member, last_data_in_month: true, dashboard_date: Time.zone.today }
          let!(:other_operations_dashboard) { Fabricate :operations_dashboard, team_member: team_member, last_data_in_month: true, dashboard_date: Time.zone.yesterday }
          let!(:operations_dashboard_pairing) { Fabricate :operations_dashboard_pairing, operations_dashboard: operations_dashboard, pair: second_team_member, pair_times: 2 }
          let!(:other_operations_dashboard_pairing) { Fabricate :operations_dashboard_pairing, operations_dashboard: operations_dashboard, pair: third_team_member, pair_times: 3 }

          let!(:out_operations_dashboard) { Fabricate :operations_dashboard, team_member: team_member, last_data_in_month: false, dashboard_date: 2.days.ago }

          it 'searches for the team members and renders the template' do
            get :pairings, params: { company_id: company, id: team_member }

            expect(response).to render_template 'team_members/pairings'
            expect(assigns(:operations_dashboards)).to eq [other_operations_dashboard, operations_dashboard]
            expect(assigns(:pairing_chart)).to eq [{ data: [nil, 3], name: third_team_member.name }, { data: [nil, 2], name: second_team_member.name }]
          end
        end
      end

      context 'invalid' do
        context 'non-existent company' do
          before { get :pairings, params: { company_id: 'foo', id: team_member } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent team member' do
          before { get :pairings, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :pairings, params: { company_id: company, id: team_member } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
