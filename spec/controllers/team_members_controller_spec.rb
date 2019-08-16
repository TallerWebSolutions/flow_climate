# frozen_string_literal: true

RSpec.describe TeamMembersController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar', team_id: 'foo' } }

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
  end

  context 'authenticated' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:team) { Fabricate :team, company: company }

    let!(:team_member) { Fabricate :team_member, company: company, name: 'ddd' }
    let!(:other_team_member) { Fabricate :team_member, company: company, name: 'aaas' }

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company }, xhr: true }

        it 'instantiates a new Team Member and renders the template' do
          expect(response).to render_template 'team_members/new.js.erb'
          expect(assigns(:team_members)).to eq company.reload.team_members.order(:name)
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
        before { post :create, params: { company_id: company, team_member: { name: 'foo', jira_account_user_email: 'foo@bar.com', jira_account_id: 'jira_account_id', billable: false, active: false, monthly_payment: 100, hours_per_month: 10, billable_type: :outsourcing, start_date: 1.day.ago.to_date, end_date: Time.zone.today } }, xhr: true }

        it 'creates the new team member and redirects to team show' do
          expect(response).to render_template 'team_members/create.js.erb'
          expect(TeamMember.last.name).to eq 'foo'
          expect(TeamMember.last.jira_account_user_email).to eq 'foo@bar.com'
          expect(TeamMember.last.jira_account_id).to eq 'jira_account_id'
          expect(TeamMember.last.billable).to be false
          expect(TeamMember.last.monthly_payment).to eq 100
          expect(TeamMember.last.hours_per_month).to eq 10
          expect(TeamMember.last.billable_type).to eq 'outsourcing'
          expect(TeamMember.last.start_date).to eq 1.day.ago.to_date
          expect(TeamMember.last.end_date).to eq Time.zone.today
          expect(assigns(:team_members)).to eq company.reload.team_members.order(:name)
        end
      end

      context 'passing invalid parameters' do
        before { post :create, params: { company_id: company, team_member: { name: '' } }, xhr: true }

        it 'does not create the team member and re-render the template with the errors' do
          expect(TeamMember.all.count).to eq 2
          expect(response).to render_template 'team_members/create.js.erb'
          expect(assigns(:team_member).errors.full_messages).to eq ['Nome não pode ficar em branco']
        end
      end
    end

    describe 'GET #edit' do
      let(:team) { Fabricate :team, company: company }
      let(:team_member) { Fabricate :team_member, teams: [team] }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company.id, id: team_member }, xhr: true }

        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template 'team_members/edit.js.erb'
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
      let(:team_member) { Fabricate :team_member, teams: [team] }

      context 'passing valid parameters' do
        before { put :update, params: { company_id: company, id: team_member, team_member: { team: other_team, name: 'foo', jira_account_user_email: 'foo@bar.com', jira_account_id: 'jira_account_id', billable: false, active: false, monthly_payment: 100, hours_per_month: 10, billable_type: :outsourcing, start_date: 1.day.ago.to_date, end_date: Time.zone.today } }, xhr: true }

        it 'updates the member and redirects to team show' do
          team_member_updated = team_member.reload
          expect(team_member_updated.name).to eq 'foo'
          expect(team_member_updated.jira_account_user_email).to eq 'foo@bar.com'
          expect(team_member_updated.jira_account_id).to eq 'jira_account_id'
          expect(team_member_updated.billable).to be false
          expect(team_member_updated.monthly_payment.to_f).to be 100.0
          expect(team_member_updated.hours_per_month).to be 10
          expect(team_member_updated.billable_type).to eq 'outsourcing'
          expect(team_member_updated.start_date).to eq 1.day.ago.to_date
          expect(team_member_updated.end_date).to eq Time.zone.today
          expect(assigns(:team_members)).to eq company.reload.team_members.order(:name)
          expect(response).to render_template 'team_members/update.js.erb'
        end
      end

      context 'passing invalid' do
        context 'team member parameters' do
          before { put :update, params: { company_id: company, id: team_member, team_member: { team: other_team, name: '', billable: nil, active: nil, monthly_payment: nil, hours_per_month: nil, billable_type: nil } }, xhr: true }

          it 'does not update the member and re-render the template with the errors' do
            expect(response).to render_template 'team_members/update.js.erb'
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
      let(:team_member) { Fabricate :team_member, teams: [team] }

      context 'with valid data' do
        it 'deletes the member and renders the template' do
          delete :destroy, params: { company_id: company, id: team_member }, xhr: true

          expect(TeamMember.all.count).to eq 1
          expect(response).to render_template 'team_members/destroy.js.erb'
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
  end
end
