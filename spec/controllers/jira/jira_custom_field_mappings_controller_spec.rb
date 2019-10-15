# frozen_string_literal: true

RSpec.describe Jira::JiraCustomFieldMappingsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar', jira_account_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar', jira_account_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'xpto', jira_account_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PUT #update' do
      before { put :update, params: { company_id: 'xpto', jira_account_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'xpto', jira_account_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:jira_account) { Fabricate :jira_account, company: company }

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company, jira_account_id: jira_account }, xhr: true }

        it 'instantiates a new jira custom field mapping and renders the template' do
          expect(response).to render_template 'jira/jira_custom_field_mappings/new'
          expect(assigns(:jira_custom_field_mapping)).to be_a_new Jira::JiraCustomFieldMapping
        end
      end

      context 'invalid parameters' do
        context 'non-existent company' do
          before { get :new, params: { company_id: 'foo', jira_account_id: jira_account }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :new, params: { company_id: company, jira_account_id: jira_account }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      let!(:start_date) { 3.days.ago }
      let!(:end_date) { 1.day.ago }

      context 'passing valid parameters' do
        before { post :create, params: { company_id: company, jira_account_id: jira_account, jira_jira_custom_field_mapping: { demand_field: 'class_of_service', custom_field_machine_name: 'custom_10040' } }, xhr: true }

        it 'creates the new jira custom field mapping and renders the template' do
          expect(response).to render_template 'jira/jira_custom_field_mappings/create'
          expect(assigns(:jira_custom_field_mapping).errors.full_messages).to eq []
          expect(assigns(:jira_custom_field_mapping)).to be_persisted
          expect(assigns(:jira_custom_field_mapping).demand_field).to eq 'class_of_service'
          expect(assigns(:jira_custom_field_mapping).custom_field_machine_name).to eq 'custom_10040'
        end
      end

      context 'passing invalid parameters' do
        before { post :create, params: { company_id: company, jira_account_id: jira_account, jira_jira_custom_field_mapping: { demand_field: nil, custom_field_machine_name: nil } }, xhr: true }

        it 'does not create the jira custom field and re-render the template with the errors' do
          expect(Jira::JiraCustomFieldMapping.all.count).to eq 0
          expect(response).to render_template 'jira/jira_custom_field_mappings/create'
          expect(assigns(:jira_custom_field_mapping).errors.full_messages).to eq ['Machine Name do Jira não pode ficar em branco', 'Tipo do Campo não pode ficar em branco']
        end
      end
    end

    describe 'GET #edit' do
      let(:jira_account) { Fabricate :jira_account, company: company }
      let!(:jira_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company.id, jira_account_id: jira_account, id: jira_custom_field_mapping }, xhr: true }

        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template 'jira/jira_custom_field_mappings/edit'
          expect(assigns(:company)).to eq company
          expect(assigns(:jira_custom_field_mapping)).to eq jira_custom_field_mapping
        end
      end

      context 'invalid' do
        context 'jira custom field mapping' do
          before { get :edit, params: { company_id: company, jira_account_id: jira_account, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :edit, params: { company_id: 'foo', jira_account_id: jira_account, id: jira_custom_field_mapping }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :edit, params: { company_id: company, jira_account_id: jira_account, id: jira_custom_field_mapping }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let(:jira_account) { Fabricate :jira_account, company: company }
      let(:other_jira_account) { Fabricate :jira_account, company: company }

      let!(:jira_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account }

      context 'passing valid parameters' do
        before { put :update, params: { company_id: company, jira_account_id: jira_account, id: jira_custom_field_mapping, jira_jira_custom_field_mapping: { demand_field: 'class_of_service', custom_field_machine_name: 'custom_10040' } }, xhr: true }

        it 'updates the jira custom field mapping and renders the template' do
          expect(response).to render_template 'jira/jira_custom_field_mappings/update'
          expect(assigns(:jira_custom_field_mapping).demand_field).to eq 'class_of_service'
          expect(assigns(:jira_custom_field_mapping).custom_field_machine_name).to eq 'custom_10040'
        end
      end

      context 'passing invalid' do
        context 'jira custom field mapping parameters' do
          before { put :update, params: { company_id: company, jira_account_id: jira_account, id: jira_custom_field_mapping, jira_jira_custom_field_mapping: { demand_field: nil, custom_field_machine_name: nil } }, xhr: true }

          it 'does not update the jira custom field mapping and re-render the template with the errors' do
            expect(response).to render_template 'jira/jira_custom_field_mappings/update'
            expect(assigns(:jira_custom_field_mapping).errors.full_messages).to eq ['Machine Name do Jira não pode ficar em branco', 'Tipo do Campo não pode ficar em branco']
          end
        end

        context 'non-existent jira custom field mapping' do
          before { put :update, params: { company_id: company, jira_account_id: jira_account, id: 'foo', jira_custom_field_mapping: { demand_field: 'class_of_service', custom_field_machine_name: 'custom_10040' } }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { put :update, params: { company_id: company, jira_account_id: jira_account, id: jira_custom_field_mapping, jira_jira_custom_field_mapping: { demand_field: 'class_of_service', custom_field_machine_name: 'custom_10040' } }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:jira_account) { Fabricate :jira_account, company: company }
      let(:jira_custom_field_mapping) { Fabricate :jira_custom_field_mapping, jira_account: jira_account }

      context 'with valid data' do
        it 'deletes the jira custom field mapping and renders the template' do
          delete :destroy, params: { company_id: company, jira_account_id: jira_account, id: jira_custom_field_mapping }, xhr: true

          expect(Jira::JiraCustomFieldMapping.all.count).to eq 0
          expect(response).to render_template 'jira/jira_custom_field_mappings/destroy'
        end
      end

      context 'with invalid' do
        context 'non-existent jira custom field mapping' do
          before { delete :destroy, params: { company_id: company, jira_account_id: jira_account, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { delete :destroy, params: { company_id: company, jira_account_id: jira_account, id: jira_custom_field_mapping }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
