# frozen_string_literal: true

RSpec.describe ExportsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #request_project_information' do
      before { get :request_project_information }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #process_requested_information' do
      before { post :process_requested_information }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #send_csv_data_by_email' do
      before { post :process_requested_information }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:options) { { username: 'foo', password: 'bar', site: 'https://foo.atlassian.net/', context_path: '/', auth_type: :basic, read_timeout: 120 } }
    let(:client) { JIRA::Client.new(options) }

    let(:jira_account) { Fabricate :jira_account, base_uri: 'https://foo.atlassian.net/', username: 'foo', password: 'bar' }

    let!(:admin_user) { Fabricate :user, admin: true }
    let(:user) { Fabricate :user }
    before { sign_in user }

    describe 'POST #process_requested_information' do
      context 'having a plan' do
        let(:plan) { Fabricate :plan }
        let!(:user_plan) { Fabricate :user_plan, plan: plan, user: user, active: true }

        context 'having all fields' do
          it 'returns the CSV to download' do
            expect(Jira::JiraDataToCsvJob).to receive(:perform_later).once
            post :process_requested_information, params: { project_name: 'foo', jira_project_key: 'key', fix_version_name: 'bar' }, format: :csv
            expect(response).to redirect_to request_project_information_path(project_name: 'foo', jira_project_key: 'key', fix_version_name: 'bar')
            expect(flash[:notice]).to eq I18n.t('exports.request_project_information.queued')
          end
        end
      end
    end

    describe 'POST #send_csv_data_by_email' do
      context 'having a gold plan' do
        let(:plan) { Fabricate :plan }
        let!(:user_plan) { Fabricate :user_plan, plan: plan, user: user, active: true, paid: true }
        let!(:demand_data_processment) { Fabricate :demand_data_processment, user_plan: user_plan, user: user }

        context 'having all fields' do
          it 'returns the CSV to download' do
            expect(UserNotifierMailer).to receive(:jira_requested_csv).once.and_call_original
            post :send_csv_data_by_email, params: { demand_data_processment_id: demand_data_processment }, format: :csv
            expect(response).to redirect_to user_path(user)
            expect(flash[:notice]).to eq I18n.t('exports.demand_data_processment.email_sent')

            expect(DemandDataProcessment.count).to eq 2
          end
        end
      end

      context 'having a lite plan' do
        let(:plan) { Fabricate :plan }
        let!(:user_plan) { Fabricate :user_plan, plan: plan, user: user, active: true, paid: true }
        let!(:demand_data_processment) { Fabricate :demand_data_processment, user_plan: user_plan, user: user }

        context 'having all fields' do
          it 'returns the CSV to download' do
            expect(UserNotifierMailer).to receive(:jira_requested_csv).once.and_call_original
            post :send_csv_data_by_email, params: { demand_data_processment_id: demand_data_processment }, format: :csv
            expect(response).to redirect_to user_path(user)
            expect(flash[:notice]).to eq I18n.t('exports.demand_data_processment.email_sent')

            expect(DemandDataProcessment.count).to eq 2
          end
        end
      end

      context 'having no active plan' do
        let(:plan) { Fabricate :plan, plan_type: :gold }
        let!(:user_plan) { Fabricate :user_plan, plan: plan, user: user, active: false, paid: true }
        let!(:demand_data_processment) { Fabricate :demand_data_processment, user_plan: user_plan, user: user }
        before { post :send_csv_data_by_email, params: { demand_data_processment_id: demand_data_processment }, format: :csv }
        it 'redirect to the user profile with an alert' do
          expect(response).to redirect_to user_path(user)
          expect(flash[:alert]).to eq I18n.t('plans.validations.no_lite_plan')
        end
      end

      context 'having no paid plan' do
        let(:plan) { Fabricate :plan, plan_type: :gold }
        let!(:user_plan) { Fabricate :user_plan, plan: plan, user: user, active: true, paid: false }
        let!(:demand_data_processment) { Fabricate :demand_data_processment, user_plan: user_plan, user: user }
        before { post :send_csv_data_by_email, params: { demand_data_processment_id: demand_data_processment }, format: :csv }
        it 'redirect to the user profile with an alert' do
          expect(response).to redirect_to user_path(user)
          expect(flash[:alert]).to eq I18n.t('plans.validations.no_lite_plan')
        end
      end

      context 'having a trial plan' do
        let(:plan) { Fabricate :plan, plan_type: :trial }
        let!(:user_plan) { Fabricate :user_plan, plan: plan, user: user, active: true, paid: false }
        let!(:demand_data_processment) { Fabricate :demand_data_processment, user_plan: user_plan, user: user }
        before { post :send_csv_data_by_email, params: { demand_data_processment_id: demand_data_processment }, format: :csv }
        it 'redirect to the user profile with an alert' do
          expect(response).to redirect_to user_path(user)
          expect(flash[:alert]).to eq I18n.t('plans.validations.no_lite_plan')
        end
      end
    end
  end
end
