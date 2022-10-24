# frozen_string_literal: true

RSpec.describe UserCompanyRolesController do
  context 'unauthenticated' do
    describe 'GET #edit' do
      before { get :edit, params: { user_id: 'bla', company_id: 'xpto', id: 'foo' } }

      it { is_expected.to redirect_to new_user_session_path }
    end

    describe 'PUT #update' do
      before { put :update, params: { user_id: 'bla', company_id: 'xpto', id: 'foo' } }

      it { is_expected.to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    let(:company) { Fabricate :company }

    before { sign_in user }

    describe 'GET #edit' do
      let(:user_company_role) { Fabricate :user_company_role, user: user, company: company }

      context 'with valid parameters' do
        it 'assigns the instance variables and renders the template' do
          get :edit, params: { user_id: user, company_id: company, id: user_company_role }

          expect(response).to render_template :edit
          expect(assigns(:company)).to eq company
          expect(assigns(:user)).to eq user
          expect(assigns(:user_company_role)).to eq user_company_role
        end
      end

      context 'with invalid' do
        context 'company' do
          before { get :edit, params: { user_id: user, company_id: 'foo', id: user_company_role } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'user' do
          before { get :edit, params: { user_id: 'foo', company_id: company, id: user_company_role } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'user_company_role' do
          before { get :edit, params: { user_id: user, company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end
      end

      context 'with different company' do
        let!(:user_company_role) { Fabricate :user_company_role, user: user }

        before { get :edit, params: { user_id: user, company_id: company, id: user_company_role } }

        it { expect(response).to have_http_status :not_found }
      end

      context 'with different user' do
        let!(:user_company_role) { Fabricate :user_company_role, company: company }

        before { get :edit, params: { user_id: user, company_id: company, id: user_company_role } }

        it { expect(response).to have_http_status :not_found }
      end
    end

    describe 'PUT #update' do
      let(:user_company_role) { Fabricate :user_company_role, user: user, company: company }

      context 'with valid parameters' do
        it 'assigns the instance variables and renders the template' do
          put :update, params: { user_id: user, company_id: company, id: user_company_role, user_company_role: { start_date: 1.day.ago, end_date: Time.zone.today, user_role: :director, slack_user: '@user' } }

          expect(response).to redirect_to edit_company_path(company)
          expect(assigns(:company)).to eq company
          expect(assigns(:user)).to eq user
          expect(assigns(:user_company_role)).to eq user_company_role
          expect(assigns(:user_company_role).start_date).to eq 1.day.ago.to_date
          expect(assigns(:user_company_role).end_date).to eq Time.zone.today
          expect(assigns(:user_company_role).user_role).to eq 'director'
          expect(assigns(:user_company_role).slack_user).to eq '@user'
        end
      end

      context 'with invalid' do
        context 'company' do
          before { put :update, params: { user_id: user, company_id: 'foo', id: user_company_role } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'user' do
          before { put :update, params: { user_id: 'foo', company_id: company, id: user_company_role } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'user_company_role' do
          before { put :update, params: { user_id: user, company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end
      end

      context 'with different company' do
        let!(:user_company_role) { Fabricate :user_company_role, user: user }

        before { put :update, params: { user_id: user, company_id: company, id: user_company_role } }

        it { expect(response).to have_http_status :not_found }
      end

      context 'with different user' do
        let!(:user_company_role) { Fabricate :user_company_role, company: company }

        before { put :update, params: { user_id: user, company_id: company, id: user_company_role } }

        it { expect(response).to have_http_status :not_found }
      end
    end
  end
end
