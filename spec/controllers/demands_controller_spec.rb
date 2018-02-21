# frozen_string_literal: true

RSpec.describe DemandsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'foo', project_id: 'bar', project_result_id: 'xpto' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'POST #create' do
      before { post :create, params: { company_id: 'foo', project_id: 'bar', project_result_id: 'xpto' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'foo', project_id: 'bar', project_result_id: 'xpto', id: 'sbbrubles' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #import_csv_form' do
      before { get :import_csv_form, params: { company_id: 'foo', project_id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'POST #import_csv' do
      before { get :import_csv, params: { company_id: 'foo', project_id: 'bar' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'foo', project_id: 'bar', project_result_id: 'xpto', id: 'sbbrubles' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
    describe 'PUT #update' do
      before { put :update, params: { company_id: 'foo', project_id: 'bar', project_result_id: 'xpto', id: 'sbbrubles' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    let(:company) { Fabricate :company, users: [user] }
    let(:customer) { Fabricate :customer, company: company }
    let(:product) { Fabricate :product, customer: customer }
    let(:project) { Fabricate :project, customer: customer, product: product }

    before { sign_in user }

    describe 'GET #new' do
      let(:project_result) { Fabricate :project_result, project: project }

      context 'valid parameters' do
        before { get :new, params: { company_id: company, project_id: project, project_result_id: project_result } }
        it 'instantiates a new Company and renders the template' do
          expect(response).to render_template :new
          expect(assigns(:company)).to eq company
          expect(assigns(:project)).to eq project
          expect(assigns(:project_result)).to eq project_result
          expect(assigns(:demand)).to be_a_new Demand
        end
      end

      context 'invalid parameters' do
        context 'inexistent company' do
          before { get :new, params: { company_id: 'foo', project_id: project, project_result_id: project_result } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'inexistent project' do
          before { get :new, params: { company_id: company, project_id: 'foo', project_result_id: project_result } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'inexistent project_result' do
          before { get :new, params: { company_id: company, project_id: project, project_result_id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'and not permitted' do
          let(:company) { Fabricate :company }
          before { get :new, params: { company_id: company, project_id: project, project_result_id: project_result } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      let(:project_result) { Fabricate :project_result, project: project }

      context 'passing valid parameters' do
        let(:date_to_demand) { 1.day.ago.change(usec: 0) }
        it 'creates the new financial information to the company and redirects to its show' do
          expect(ProjectResultsRepository.instance).to receive(:update_result_for_date).with(project, date_to_demand, 1, 0).once
          post :create, params: { company_id: company, project_id: project, project_result_id: project_result, demand: { demand_id: 'xpto', demand_type: 'bug', class_of_service: 'expedite', effort: 5, created_date: date_to_demand, commitment_date: date_to_demand, end_date: date_to_demand } }

          expect(assigns(:company)).to eq company
          expect(assigns(:project)).to eq project
          expect(assigns(:project_result)).to eq project_result

          expect(Demand.last.project_result).to eq project_result
          expect(Demand.last.demand_id).to eq 'xpto'
          expect(Demand.last.demand_type).to eq 'bug'
          expect(Demand.last.class_of_service).to eq 'expedite'
          expect(Demand.last.effort).to eq 5
          expect(Demand.last.created_date).to eq date_to_demand
          expect(Demand.last.commitment_date).to eq date_to_demand
          expect(Demand.last.end_date).to eq date_to_demand
          expect(response).to redirect_to company_project_project_result_path(company, project, project_result)
        end
      end
      context 'passing invalid parameters' do
        context 'invalid attributes' do
          before { post :create, params: { company_id: company, project_id: project, project_result_id: project_result, demand: { finances: nil, income_total: nil, expenses_total: nil } } }
          it 'does not create the company and re-render the template with the errors' do
            expect(Demand.last).to be_nil
            expect(response).to render_template :new
            expect(assigns(:demand).errors.full_messages).to eq ['Data de Criação não pode ficar em branco', 'Id da Demanda não pode ficar em branco', 'Esforço não pode ficar em branco', 'Tipo da Demanda não pode ficar em branco']
          end
        end
        context 'inexistent company' do
          before { post :create, params: { company_id: 'foo', project_id: project, project_result_id: project_result, demand: { finances_date: Time.zone.today, income_total: 10, expenses_total: 5 } } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'inexistent project' do
          before { post :create, params: { company_id: company, project_id: 'foo', project_result_id: project_result } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'inexistent project_result' do
          before { post :create, params: { company_id: company, project_id: project, project_result_id: 'foo' } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'and not permitted company' do
          let(:company) { Fabricate :company }
          before { post :create, params: { company_id: company, project_id: project, project_result_id: project_result, demand: { finances_date: Time.zone.today, income_total: 10, expenses_total: 5 } } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:project) { Fabricate :project, customer: customer, product: product }
      let(:project_result) { Fabricate :project_result, project: project }
      let(:demand) { Fabricate :demand, project_result: project_result }

      context 'passing valid IDs' do
        before { delete :destroy, params: { company_id: company, project_id: project, project_result_id: project_result, id: demand } }
        it 'assigns the instance variable and renders the template' do
          expect(response).to redirect_to company_project_project_result_path(company, project, project_result)
          expect(Demand.last).to be_nil
        end
      end

      context 'passing an invalid ID' do
        context 'non-existent operation result' do
          before { delete :destroy, params: { company_id: company, project_id: project, project_result_id: 'foo', id: demand } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', project_id: project, project_result_id: project_result, id: demand } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'non-existent project' do
          before { delete :destroy, params: { company_id: company, project_id: 'foo', project_result_id: project_result, id: demand } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }
          let(:project_result) { Fabricate :project_result, project: project }

          before { delete :destroy, params: { company_id: company, project_id: project, project_result_id: project_result, id: demand } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #import_csv_form' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, customer: customer }
      let!(:project_result) { Fabricate :project_result, project: project }

      context 'and the company having teams' do
        let!(:team) { Fabricate :team, company: company, name: 'zzz' }
        let!(:other_team) { Fabricate :team, company: company, name: 'aaa' }
        before { get :import_csv_form, params: { company_id: company, project_id: project } }
        it 'assigns the instance variable for teams list and renders the template' do
          expect(response).to render_template :import_csv_form
          expect(assigns(:teams)).to eq [other_team, team]
        end
      end
      context 'and the company having no teams' do
        before { get :import_csv_form, params: { company_id: company, project_id: project } }
        it 'assigns the instance variable for teams list and renders the template' do
          expect(response).to render_template :import_csv_form
          expect(assigns(:teams)).to eq []
        end
      end
    end

    describe 'POST #import_csv' do
      context 'passing valid parameters' do
        let!(:team) { Fabricate :team, company: company }
        let(:project) { Fabricate :project, customer: customer }

        context 'filled commitment and end date' do
          context 'when the demand and the result do not exist' do
            it 'imports creating the demand and the project results in the date' do
              end_date = Time.iso8601('2018-01-20T22:44:57-02:00')
              expect(ProjectResultsRepository.instance).to receive(:update_result_for_date).with(project, end_date.to_date, 1, 0).once
              post :import_csv, params: { company_id: company, project_id: project, team: team.id, csv_text: '345;bug;2018-01-10T22:44:57-02:00;2018-01-16T22:44:57-02:00;2018-01-20T22:44:57-02:00' }

              expect(response).to redirect_to company_project_path(company, project)
              expect(Demand.last.demand_id).to eq '345'
              expect(Demand.last.demand_type).to eq 'bug'
              expect(Demand.last.created_date).to eq Time.iso8601('2018-01-10T22:44:57-02:00')
              expect(Demand.last.commitment_date).to eq Time.iso8601('2018-01-16T22:44:57-02:00')
              expect(Demand.last.end_date).to eq Time.iso8601('2018-01-20T22:44:57-02:00')
            end
          end

          context 'when the demand and result exists' do
            let(:project_result) { Fabricate :project_result, project: project }
            let!(:demand) { Fabricate :demand, project_result: project_result, demand_id: '345' }
            let(:csv_text) { "345;bug;2018-01-10T22:44:57-02:00;2018-01-16T22:44:57-02:00;2018-01-20T22:44:57-02:00\n346;feature;2018-01-01T22:44:57-02:00;2018-01-03T22:44:57-02:00;2018-01-05T22:44:57-02:00" }

            it 'imports updating the demand and the project results in the date' do
              expect(ProjectResultsRepository.instance).to receive(:update_result_for_date).with(project, Time.iso8601('2018-01-20T22:44:57-02:00').to_date, 1, 0).once
              expect(ProjectResultsRepository.instance).to receive(:update_result_for_date).with(project, Time.iso8601('2018-01-05T22:44:57-02:00').to_date, 1, 0).once
              expect(ProjectResultsRepository.instance).to receive(:update_result_for_date).with(project, project_result.result_date, 1, 0).once
              post :import_csv, params: { company_id: company, project_id: project, team: team.id, csv_text: csv_text }

              expect(response).to redirect_to company_project_path(company, project)
              expect(Demand.count).to eq 2
              expect(Demand.pluck(:demand_id)).to match_array %w[345 346]
              expect(Demand.pluck(:demand_type)).to match_array %w[bug feature]
              expect(Demand.pluck(:created_date)).to match_array [Time.iso8601('2018-01-10T22:44:57-02:00'), Time.iso8601('2018-01-01T22:44:57-02:00')]
              expect(Demand.pluck(:commitment_date)).to match_array [Time.iso8601('2018-01-16T22:44:57-02:00'), Time.iso8601('2018-01-03T22:44:57-02:00')]
              expect(Demand.pluck(:end_date)).to eq [Time.iso8601('2018-01-20T22:44:57-02:00'), Time.iso8601('2018-01-05T22:44:57-02:00')]
            end
          end
        end

        context 'having no commitment nor end dates' do
          let(:prior_created_date) { Time.iso8601('2018-01-09T22:44:57-02:00') }
          let(:project_result) { Fabricate :project_result, project: project, result_date: prior_created_date }
          let!(:demand) { Fabricate :demand, project_result: project_result, demand_id: '345', created_date: prior_created_date }

          it 'imports updating the demand and updates the project results in the created date' do
            created_date = Time.iso8601('2018-01-10T22:44:57-02:00')
            expect(ProjectResultsRepository.instance).to receive(:update_result_for_date).with(project, created_date.to_date, 1, 0).once
            expect(ProjectResultsRepository.instance).to receive(:update_result_for_date).with(project, prior_created_date.to_date, 0, 0).once

            post :import_csv, params: { company_id: company, project_id: project, team: team.id, csv_text: '345;bug;2018-01-10T22:44:57-02:00' }

            expect(response).to redirect_to company_project_path(company, project)
            expect(Demand.count).to eq 1
            expect(Demand.last.demand_id).to eq '345'
            expect(Demand.last.demand_type).to eq 'bug'
            expect(Demand.last.created_date).to eq Time.iso8601('2018-01-10T22:44:57-02:00')
            expect(Demand.last.commitment_date).to eq nil
            expect(Demand.last.end_date).to eq nil
          end
        end
        context 'not having some mandatory fields' do
          let(:project_result) { Fabricate :project_result, project: project }
          let!(:demand) { Fabricate :demand, project_result: project_result, demand_id: '345' }

          it 'does not import the demands and render the template again with the errors' do
            expect(ProjectResultsRepository.instance).to receive(:update_result_for_date).never
            post :import_csv, params: { company_id: company, project_id: project, team: team.id, csv_text: '345;bug' }

            expect(response).to render_template :import_csv_form
            expect(flash[:error]).to eq I18n.t('demands.import_csv.bad_string')
          end
        end
        context 'having no fields' do
          let(:project_result) { Fabricate :project_result, project: project }
          let!(:demand) { Fabricate :demand, project_result: project_result, demand_id: '345' }

          it 'does nothing and redirects to the project path' do
            expect(ProjectResultsRepository.instance).to receive(:update_result_for_date).never
            post :import_csv, params: { company_id: company, project_id: project, team: team.id, csv_text: '' }

            expect(response).to redirect_to company_project_path(company, project)
          end
        end
      end
    end

    describe 'GET #edit' do
      let(:company) { Fabricate :company, users: [user] }

      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, customer: customer }
      let(:project_result) { Fabricate :project_result, project: project }
      let!(:demand) { Fabricate :demand, project_result: project_result }

      context 'valid parameters' do
        before { get :edit, params: { company_id: company, project_id: project, project_result_id: project_result, id: demand } }
        it 'assigns the instance variables and renders the template' do
          expect(response).to render_template :edit
          expect(assigns(:company)).to eq company
          expect(assigns(:project)).to eq project
          expect(assigns(:project_result)).to eq project_result
          expect(assigns(:demand)).to eq demand
        end
      end

      context 'invalid' do
        context 'project' do
          before { get :edit, params: { company_id: company, project_id: 'foo', project_result_id: project_result, id: demand } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'project_result' do
          before { get :edit, params: { company_id: company, project_id: project, project_result_id: 'foo', id: demand } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'demand' do
          before { get :edit, params: { company_id: company, project_id: project, project_result_id: project_result, id: 'bar' } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :edit, params: { company_id: 'foo', project_id: project, project_result_id: project_result, id: demand } }
            it { expect(response).to have_http_status :not_found }
          end
          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }
            before { get :edit, params: { company_id: company, project_id: project, project_result_id: project_result, id: demand } }
            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let(:created_date) { 1.day.ago.change(usec: 0) }
      let(:end_date) { Time.zone.now.change(usec: 0) }

      let(:company) { Fabricate :company, users: [user] }

      let(:team) { Fabricate :team, company: company }
      let!(:team_member) { Fabricate(:team_member, monthly_payment: 100, team: team) }

      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, customer: customer }
      let!(:project_result) { Fabricate :project_result, project: project, result_date: created_date }
      let!(:demand) { Fabricate :demand, project_result: project_result, created_date: created_date }

      context 'passing valid parameters' do
        it 'updates the demand and redirects to projects index' do
          expect(ProjectResultsRepository.instance).to receive(:update_result_for_date).with(project, created_date, 1, 0).once
          expect(ProjectResultsRepository.instance).to receive(:update_result_for_date).with(project, end_date, 1, 0).once
          put :update, params: { company_id: company, project_id: project, project_result_id: project_result, id: demand, demand: { demand_id: 'xpto', demand_type: 'bug', class_of_service: 'expedite', effort: 5, created_date: created_date, commitment_date: created_date, end_date: end_date } }
          created_demand = Demand.last
          expect(created_demand.demand_id).to eq 'xpto'
          expect(created_demand.demand_type).to eq 'bug'
          expect(Demand.last.class_of_service).to eq 'expedite'
          expect(created_demand.effort.to_f).to eq 5
          expect(created_demand.created_date).to eq created_date
          expect(created_demand.commitment_date).to eq created_date
          expect(created_demand.end_date).to eq end_date
          expect(response).to redirect_to company_project_project_result_path(company, project, project_result)
        end
      end

      context 'passing invalid' do
        context 'project' do
          before { get :edit, params: { company_id: company, project_id: 'foo', project_result_id: project_result, id: demand } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'demand parameters' do
          before { put :update, params: { company_id: company, project_id: project, project_result_id: project_result, id: demand, demand: { demand_id: '', demand_type: '', effort: nil, created_date: nil, commitment_date: nil, end_date: nil } } }
          it 'does not update the demand and re-render the template with the errors' do
            expect(response).to render_template :edit
            expect(assigns(:demand).errors.full_messages).to match_array ['Data de Criação não pode ficar em branco', 'Id da Demanda não pode ficar em branco', 'Esforço não pode ficar em branco', 'Tipo da Demanda não pode ficar em branco']
          end
        end
        context 'non-existent project_result' do
          let(:customer) { Fabricate :customer, company: company }

          before { put :update, params: { company_id: company, project_id: project, project_result_id: 'foo', id: demand, project_result: { customer_id: customer, name: 'foo' } } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'demand' do
          before { get :edit, params: { company_id: company, project_id: project, project_result_id: project_result, id: 'bar' } }
          it { expect(response).to have_http_status :not_found }
        end

        context 'unpermitted company' do
          let(:company) { Fabricate :company, users: [] }
          let(:customer) { Fabricate :customer, company: company }

          before { put :update, params: { company_id: company, project_id: project, project_result_id: project_result, id: demand, project_result: { customer_id: customer, name: 'foo' } } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
