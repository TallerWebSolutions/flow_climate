# frozen_string_literal: true

RSpec.describe MembershipsController do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar', team_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar', team_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'xpto', team_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PUT #update' do
      before { put :update, params: { company_id: 'xpto', team_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'xpto', team_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #index' do
      before { get :index, params: { company_id: 'bar', team_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #search_memberships' do
      before { get :search_memberships, params: { company_id: 'xpto', team_id: 'bla', id: 'foo' } }

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

    let!(:team_member) { Fabricate :team_member, name: 'ddd', company: company }
    let!(:other_team_member) { Fabricate :team_member, name: 'aaa', company: company }

    let!(:membership) { Fabricate :membership, team: team, team_member: team_member, start_date: 2.days.ago, end_date: nil }
    let!(:other_membership) { Fabricate :membership, team: team, team_member: other_team_member, start_date: 3.days.ago, end_date: nil }

    let!(:inactive_membership) { Fabricate :membership, team: team, team_member: other_team_member, start_date: 1.day.ago, end_date: Time.zone.today }

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company, team_id: team }, xhr: true }

        it 'instantiates a new membership and renders the template' do
          expect(response).to render_template 'memberships/new'
          expect(assigns(:team_members)).to match_array [team_member, other_team_member]
          expect(assigns(:membership)).to be_a_new Membership
        end
      end

      context 'invalid parameters' do
        context 'non-existent company' do
          before { get :new, params: { company_id: 'foo', team_id: team }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :new, params: { company_id: company, team_id: team }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      let!(:new_team_member) { Fabricate :team_member, company: company }

      let!(:start_date) { 3.days.ago }
      let!(:end_date) { 1.day.ago }

      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, team_id: team, membership: { start_date: start_date, end_date: end_date, member_role: 'client', team_member_id: new_team_member.id, hours_per_month: 10 } }, xhr: true }

        it 'creates the new membership and renders the template' do
          expect(response).to render_template 'memberships/create'
          expect(assigns(:membership).errors.full_messages).to eq []
          expect(assigns(:membership)).to be_persisted
          expect(assigns(:membership).start_date).to eq start_date.to_date
          expect(assigns(:membership).end_date).to eq end_date.to_date
          expect(assigns(:membership).hours_per_month).to eq 10
          expect(assigns(:membership).team).to eq team
          expect(assigns(:membership).team_member).to eq new_team_member
          expect(assigns(:membership).member_role).to eq 'client'
          expect(assigns(:memberships).size).to eq 4
        end
      end

      context 'passing invalid parameters' do
        before { post :create, params: { company_id: company, team_id: team, membership: { team_member_id: '', member_role: nil } }, xhr: true }

        it 'does not create the membership and re-render the template with the errors' do
          expect(Membership.all.count).to eq 3
          expect(response).to render_template 'memberships/create'
          expect(assigns(:membership).errors.full_messages).to eq ['Membro de Time deve existir', 'Início não pode ficar em branco', 'Função não pode ficar em branco']
        end
      end
    end

    describe 'GET #edit' do
      let(:team) { Fabricate :team, company: company }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company.id, team_id: team, id: membership }, xhr: true }

        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template 'memberships/edit'
          expect(assigns(:company)).to eq company
          expect(assigns(:membership)).to eq membership
          expect(assigns(:team_members)).to match_array [team_member, other_team_member]
          expect(assigns(:memberships)).to eq team.reload.memberships.sort_by(&:team_member_name)
        end
      end

      context 'invalid' do
        context 'membership' do
          before { get :edit, params: { company_id: company, team_id: team, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :edit, params: { company_id: 'foo', team_id: team, id: membership }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :edit, params: { company_id: company, team_id: team, id: membership }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let!(:no_memberships_team_member) { Fabricate :team_member, name: 'ttt', company: company }

      context 'passing valid parameters' do
        before { put :update, params: { company_id: company, team_id: team, id: membership, membership: { member_role: :manager, team_member_id: no_memberships_team_member.id } }, xhr: true }

        it 'updates the membership and renders the template' do
          membership_updated = membership.reload
          expect(membership_updated.member_role).to eq 'manager'
          expect(membership_updated.team_member).to eq no_memberships_team_member
          expect(assigns(:memberships)).to eq [other_membership, inactive_membership, membership]
          expect(response).to render_template 'memberships/update'
        end
      end

      context 'passing invalid' do
        context 'membeership parameters' do
          before { put :update, params: { company_id: company, team_id: team, id: membership, membership: { member_role: '', start_date: nil } }, xhr: true }

          it 'does not update the membership and re-render the template with the errors' do
            expect(response).to render_template 'memberships/update'
            expect(assigns(:membership).errors.full_messages).to eq ['Início não pode ficar em branco', 'Função não pode ficar em branco']
          end
        end

        context 'non-existent membership' do
          before { put :update, params: { company_id: company, team_id: team, id: 'foo', membership: { member_role: :manager, team_member_id: other_team_member.id } }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { put :update, params: { company_id: company, team_id: team, id: membership, membership: { member_role: :manager, team_member_id: other_team_member.id } }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:team) { Fabricate :team, company: company }

      context 'with valid data' do
        it 'deletes the membership and renders the template' do
          delete :destroy, params: { company_id: company, team_id: team, id: membership }, xhr: true

          expect(Membership.all.count).to eq 2
          expect(response).to render_template 'memberships/destroy'
        end
      end

      context 'with invalid' do
        context 'non-existent membership' do
          before { delete :destroy, params: { company_id: company, team_id: team, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { delete :destroy, params: { company_id: company, team_id: team, id: membership }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #index' do
      context 'valid parameters' do
        before { get :index, params: { company_id: company, team_id: team } }

        it 'assigns the memberships variable and renders the template' do
          expect(response).to render_template 'memberships/index'
          expect(response).to render_template 'memberships/_memberships_table'
          expect(assigns(:memberships)).to eq [other_membership, membership]
        end
      end

      context 'invalid parameters' do
        context 'non-existent company' do
          before { get :index, params: { company_id: 'foo', team_id: team }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :index, params: { company_id: company, team_id: team }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #search_memberships' do
      context 'valid parameters' do
        context 'with no search parameters' do
          before { get :search_memberships, params: { company_id: company, team_id: team }, xhr: true }

          it 'searches for the team members and renders the template' do
            expect(response).to render_template 'memberships/search_memberships'
            expect(assigns(:memberships)).to eq [other_membership, inactive_membership, membership]
          end
        end

        context 'with active status true' do
          before { get :search_memberships, params: { company_id: company, team_id: team, membership_status: 'true' }, xhr: true }

          it 'searches for the team members and renders the template' do
            expect(response).to render_template 'memberships/search_memberships'
            expect(assigns(:memberships)).to eq [other_membership, membership]
          end
        end

        context 'with active status false' do
          before { get :search_memberships, params: { company_id: company, team_id: team, membership_status: 'false' }, xhr: true }

          it 'searches for the team members and renders the template' do
            expect(response).to render_template 'memberships/search_memberships'
            expect(assigns(:memberships)).to eq [inactive_membership]
          end
        end
      end

      context 'invalid' do
        context 'non-existent company' do
          before { get :search_memberships, params: { company_id: 'foo', team_id: 'bar' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent team' do
          before { get :search_memberships, params: { company_id: company, team_id: 'bar' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :search_memberships, params: { company_id: company, team_id: team }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
