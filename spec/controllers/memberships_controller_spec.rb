# frozen_string_literal: true

RSpec.describe MembershipsController do
  context 'unauthenticated' do
    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'xpto', team_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #index' do
      before { get :index, params: { company_id: 'bar', team_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #efficiency_table' do
      before { get :efficiency_table, params: { company_id: 'bar', team_id: 'foo' } }

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

    describe 'GET #edit' do
      let!(:product) { Fabricate :product, company: company }
      let!(:team) { Fabricate :team, company: company }

      it 'renders project spa page' do
        get :edit, params: { company_id: company, team_id: team, id: 'foo' }

        expect(response).to render_template 'spa-build/index'
      end
    end

    describe 'GET #index' do
      let!(:product) { Fabricate :product, company: company }
      let!(:team) { Fabricate :team, company: company }

      it 'renders project spa page' do
        get :index, params: { company_id: company, team_id: team }

        expect(response).to render_template 'spa-build/index'
      end
    end

    describe 'GET #efficiency_table' do
      let!(:product) { Fabricate :product, company: company }
      let!(:team) { Fabricate :team, company: company }

      it 'renders project spa page' do
        get :efficiency_table, params: { company_id: company, team_id: team }

        expect(response).to render_template 'spa-build/index'
      end
    end
  end
end
