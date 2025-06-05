# frozen_string_literal: true

require 'spec_helper'

RSpec.describe CompanyWorkingHoursConfigsController do
  let(:plan) { Fabricate :plan, plan_type: :gold }
  let(:user) { Fabricate :user }
  let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

  before do
    login_as user
  end

  let(:company) { Fabricate :company, users: [user] }

  describe 'GET #index' do
    let!(:config) { Fabricate :company_working_hours_config, company: company }

    it 'assigns @configs' do
      get :index, params: { company_id: company }

      expect(assigns(:configs)).to eq [config]
    end

    it 'renders the index template' do
      get :index, params: { company_id: company }

      expect(response).to render_template :index
    end

    context 'with invalid company' do
      context 'non-existent' do
        before { get :index, params: { company_id: 'foo' } }

        it { expect(response).to have_http_status :not_found }
      end

      context 'not permitted' do
        let(:company) { Fabricate :company, users: [] }

        before { get :index, params: { company_id: company } }

        it { expect(response).to have_http_status :not_found }
      end
    end
  end

  describe 'GET #new' do
    it 'assigns a new @config' do
      get :new, params: { company_id: company }

      expect(assigns(:config)).to be_a_new CompanyWorkingHoursConfig
    end

    it 'renders the new template' do
      get :new, params: { company_id: company }

      expect(response).to render_template :new
    end

    context 'with invalid company' do
      context 'non-existent' do
        before { get :new, params: { company_id: 'foo' } }

        it { expect(response).to have_http_status :not_found }
      end

      context 'not permitted' do
        let(:company) { Fabricate :company, users: [] }

        before { get :new, params: { company_id: company } }

        it { expect(response).to have_http_status :not_found }
      end
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_params) { { company_id: company, company_working_hours_config: { hours_per_day: 7, start_date: Time.zone.today } } }

      it 'creates a new config' do
        expect do
          post :create, params: valid_params
        end.to change(CompanyWorkingHoursConfig, :count).by(1)
      end

      it 'redirects to index with success message' do
        post :create, params: valid_params

        expect(response).to redirect_to company_company_working_hours_configs_path(company)
        expect(flash[:notice]).to eq I18n.t('company_working_hours_configs.create.success')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { company_id: company, company_working_hours_config: { hours_per_day: nil, start_date: nil } } }

      it 'does not create a new config' do
        expect do
          post :create, params: invalid_params
        end.not_to change(CompanyWorkingHoursConfig, :count)
      end

      it 'renders the new template' do
        post :create, params: invalid_params

        expect(response).to render_template :new
      end
    end

    context 'with invalid company' do
      context 'non-existent' do
        before { post :create, params: { company_id: 'foo' } }

        it { expect(response).to have_http_status :not_found }
      end

      context 'not permitted' do
        let(:company) { Fabricate :company, users: [] }

        before { post :create, params: { company_id: company, company_working_hours_config: { hours_per_day: 7 } } }

        it { expect(response).to have_http_status :not_found }
      end
    end
  end

  describe 'GET #edit' do
    let!(:config) { Fabricate :company_working_hours_config, company: company }

    it 'assigns the requested config to @config' do
      get :edit, params: { company_id: company, id: config }

      expect(assigns(:config)).to eq config
    end

    it 'renders the edit template' do
      get :edit, params: { company_id: company, id: config }

      expect(response).to render_template :edit
    end

    context 'with invalid company' do
      context 'non-existent' do
        before { get :edit, params: { company_id: 'foo', id: config } }

        it { expect(response).to have_http_status :not_found }
      end

      context 'not permitted' do
        let(:company) { Fabricate :company, users: [] }

        before { get :edit, params: { company_id: company, id: config } }

        it { expect(response).to have_http_status :not_found }
      end
    end

    context 'with invalid config' do
      context 'non-existent' do
        before { get :edit, params: { company_id: company, id: 'foo' } }

        it { expect(response).to have_http_status :not_found }
      end

      context 'from another company' do
        let(:other_company) { Fabricate :company }
        let!(:other_config) { Fabricate :company_working_hours_config, company: other_company }

        before { get :edit, params: { company_id: company, id: other_config } }

        it { expect(response).to have_http_status :not_found }
      end
    end
  end

  describe 'PUT #update' do
    let!(:config) { Fabricate :company_working_hours_config, company: company }

    context 'with valid params' do
      let(:valid_params) { { company_id: company, id: config, company_working_hours_config: { hours_per_day: 8 } } }

      it 'updates the config' do
        put :update, params: valid_params

        expect(config.reload.hours_per_day).to eq 8
      end

      it 'redirects to index with success message' do
        put :update, params: valid_params

        expect(response).to redirect_to company_company_working_hours_configs_path(company)
        expect(flash[:notice]).to eq I18n.t('company_working_hours_configs.update.success')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) { { company_id: company, id: config, company_working_hours_config: { hours_per_day: nil } } }

      it 'does not update the config' do
        expect do
          put :update, params: invalid_params
        end.not_to(change { config.reload.hours_per_day })
      end

      it 'renders the edit template' do
        put :update, params: invalid_params

        expect(response).to render_template :edit
      end
    end

    context 'with invalid company' do
      context 'non-existent' do
        before { put :update, params: { company_id: 'foo', id: config } }

        it { expect(response).to have_http_status :not_found }
      end

      context 'not permitted' do
        let(:company) { Fabricate :company, users: [] }

        before { put :update, params: { company_id: company, id: config, company_working_hours_config: { hours_per_day: 8 } } }

        it { expect(response).to have_http_status :not_found }
      end
    end

    context 'with invalid config' do
      context 'non-existent' do
        before { put :update, params: { company_id: company, id: 'foo' } }

        it { expect(response).to have_http_status :not_found }
      end

      context 'from another company' do
        let(:other_company) { Fabricate :company }
        let!(:other_config) { Fabricate :company_working_hours_config, company: other_company }

        before { put :update, params: { company_id: company, id: other_config } }

        it { expect(response).to have_http_status :not_found }
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:config) { Fabricate :company_working_hours_config, company: company }

    it 'deactivates the config by setting end_date to today' do
      delete :destroy, params: { company_id: company, id: config }
      expect(config.reload.end_date).to eq(Time.zone.today)
    end

    it 'redirects to index with success message' do
      delete :destroy, params: { company_id: company, id: config }

      expect(response).to redirect_to company_company_working_hours_configs_path(company)
      expect(flash[:notice]).to eq I18n.t('company_working_hours_configs.destroy.success')
    end

    context 'with invalid company' do
      context 'non-existent' do
        before { delete :destroy, params: { company_id: 'foo', id: config } }

        it { expect(response).to have_http_status :not_found }
      end

      context 'not permitted' do
        let(:company) { Fabricate :company, users: [] }

        before { delete :destroy, params: { company_id: company, id: config } }

        it { expect(response).to have_http_status :not_found }
      end
    end

    context 'with invalid config' do
      context 'non-existent' do
        before { delete :destroy, params: { company_id: company, id: 'foo' } }

        it { expect(response).to have_http_status :not_found }
      end

      context 'from another company' do
        let(:other_company) { Fabricate :company }
        let!(:other_config) { Fabricate :company_working_hours_config, company: other_company }

        before { delete :destroy, params: { company_id: company, id: other_config } }

        it { expect(response).to have_http_status :not_found }
      end
    end
  end
end
