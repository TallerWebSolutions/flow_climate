# frozen_string_literal: true

RSpec.describe InitiativesController do
  context 'unauthenticated' do
    describe 'GET #index' do
      before { get :index, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #show' do
      before { get :show, params: { company_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #generate_cache' do
      before { post :generate_cache, params: { company_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #new' do
      before { get :new, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    let(:company) { Fabricate :company, users: [user] }

    before { sign_in user }

    describe 'GET #index' do
      context 'with valid params' do
        before { get :index, params: { company_id: company.id } }

        it { expect(response).to render_template 'spa-build/index' }
      end

      context 'with invalid params' do
        context 'invalid company' do
          before { get :index, params: { company_id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not authorized company' do
          let(:company) { Fabricate :company }

          before { get :index, params: { company_id: company } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #edit' do
      it 'renders the SPA template' do
        get :edit, params: { company_id: company.id, id: 'foo' }

        expect(response).to render_template 'spa-build/index'
      end
    end

    describe 'GET #show' do
      let(:initiative) { Fabricate :initiative, company: company, name: 'foo', start_date: 3.days.ago, end_date: 1.day.from_now }

      context 'with valid params' do
        context 'with data' do
          it 'assigns the instance variables and renders the template' do
            initiative_consolidation = Fabricate :initiative_consolidation, initiative: initiative, consolidation_date: 1.day.ago, last_data_in_week: true
            other_initiative_consolidation = Fabricate :initiative_consolidation, initiative: initiative, consolidation_date: 2.days.ago, last_data_in_week: true

            project = Fabricate :project, initiative: initiative
            demand = Fabricate :demand, project: project

            Fabricate :task, demand: demand, created_date: 2.days.ago, end_date: Time.zone.now
            Fabricate :task, demand: demand, created_date: 3.days.ago, end_date: Time.zone.now
            Fabricate :task, demand: demand, created_date: 4.days.ago, end_date: nil

            Fabricate :task, created_date: 3.days.ago, end_date: nil

            Fabricate :initiative_consolidation

            get :show, params: { company_id: company, id: initiative }

            expect(assigns(:initiative)).to eq initiative
            expect(assigns(:initiative_consolidations)).to eq [other_initiative_consolidation, initiative_consolidation]
            expect(assigns(:burnup_adapter)).to be_a Highchart::BurnupAdapter
            expect(assigns(:tasks_completed)).to eq 2
            expect(assigns(:tasks_to_do)).to eq 1

            expect(response).to render_template 'initiatives/show'
          end
        end
      end

      context 'with invalid params' do
        context 'initiative' do
          before { get :show, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'invalid company' do
          before { get :show, params: { company_id: 'foo', id: initiative } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not authorized company' do
          let(:company) { Fabricate :company }

          before { get :show, params: { company_id: company, id: initiative } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #generate_cache' do
      it 'iterates over the dates and calls the job to generate the cache' do
        initiative = Fabricate :initiative, company: company, start_date: 3.days.ago, end_date: 1.day.from_now

        expect(Consolidations::InitiativeConsolidationJob).to(receive(:perform_later).exactly(4).times).and_call_original

        post :generate_cache, params: { company_id: company, id: initiative }

        expect(flash[:notice]).to eq I18n.t('general.enqueued')
      end
    end

    describe 'GET #new' do
      context 'valid parameters' do
        before { get :new, params: { company_id: company } }

        it 'instantiates a new initiative and renders the template' do
          expect(response).to render_template :new
          expect(assigns(:company)).to eq company
          expect(assigns(:initiative)).to be_a_new Initiative
        end
      end

      context 'invalid' do
        context 'company' do
          before { get :new, params: { company_id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'and not permitted company' do
          let(:company) { Fabricate :company }

          before { get :new, params: { company_id: company } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      context 'passing valid parameters' do
        it 'creates the new initiative and redirects' do
          start_date = 2.days.ago
          end_date = 3.days.from_now

          post :create, params: { company_id: company, initiative: { name: 'foo', start_date: start_date, end_date: end_date, target_quarter: :q4, target_year: 2022 } }

          expect(assigns(:company)).to eq company

          created_initiative = Initiative.last
          expect(created_initiative.name).to eq 'foo'
          expect(created_initiative.start_date).to eq start_date.to_date
          expect(created_initiative.end_date).to eq end_date.to_date
          expect(created_initiative).to be_an_q4
          expect(created_initiative.target_year).to eq 2022

          expect(response).to redirect_to company_initiatives_path(company)
        end
      end

      context 'invalid' do
        context 'parameters' do
          before { post :create, params: { company_id: company, initiative: { name: nil, start_date: nil, end_date: nil, target_quarter: nil, target_year: nil } } }

          it 'does not create the initiative and re-render the template with the errors' do
            expect(Initiative.last).to be_nil
            expect(response).to render_template :new
            expect(assigns(:initiative).errors.full_messages).to eq ['Nome não pode ficar em branco', 'Dt Início não pode ficar em branco', 'Dt Fim não pode ficar em branco', 'Trimestre não pode ficar em branco', 'Ano não pode ficar em branco']
          end
        end

        context 'company' do
          before { post :create, params: { company_id: 'foo', initiative: { name: 'foo', start_date: 2.days.ago, end_date: 2.days.from_now } } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'and not permitted company' do
          let(:company) { Fabricate :company }

          before { post :create, params: { company_id: company, initiative: { name: 'foo', start_date: 2.days.ago, end_date: 2.days.from_now } } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
