# frozen-string-literal: true

RSpec.describe InitiativesController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #index' do
      before { get :index, params: { company_id: 'foo' } }

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
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    let(:company) { Fabricate :company, users: [user] }

    before { sign_in user }

    describe 'GET #index' do
      context 'with valid params' do
        context 'with data' do
          it 'assigns the instance variables and renders the template' do
            initiative = Fabricate :initiative, company: company, name: 'foo', start_date: 3.days.ago, end_date: 1.day.from_now
            other_initiative = Fabricate :initiative, company: company, name: 'bar', start_date: 2.days.ago, end_date: 2.days.from_now
            Fabricate :initiative

            get :index, params: { company_id: company }

            expect(assigns(:initiatives)).to eq [other_initiative, initiative]
            expect(response).to render_template 'initiatives/index'
          end
        end
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

    describe 'GET #show' do
      let(:initiative) { Fabricate :initiative, company: company, name: 'foo', start_date: 3.days.ago, end_date: 1.day.from_now }

      context 'with valid params' do
        context 'with data' do
          it 'assigns the instance variables and renders the template' do
            initiative_consolidation = Fabricate :initiative_consolidation, initiative: initiative, consolidation_date: 1.day.ago, last_data_in_week: true
            other_initiative_consolidation = Fabricate :initiative_consolidation, initiative: initiative, consolidation_date: 2.days.ago, last_data_in_week: true

            project = Fabricate :project, initiative: initiative
            demand = Fabricate :demand, project: project

            task = Fabricate :task, demand: demand, created_date: 2.days.ago, end_date: Time.zone.now
            other_task = Fabricate :task, demand: demand, created_date: 3.days.ago, end_date: Time.zone.now
            unfinished_task = Fabricate :task, demand: demand, created_date: 4.days.ago, end_date: nil

            Fabricate :task, created_date: 3.days.ago, end_date: nil

            Fabricate :initiative_consolidation

            get :show, params: { company_id: company, id: initiative }

            expect(assigns(:initiative)).to eq initiative
            expect(assigns(:initiative_consolidations)).to eq [other_initiative_consolidation, initiative_consolidation]
            expect(assigns(:burnup_adapter)).to be_a Highchart::BurnupAdapter
            expect(assigns(:tasks_completed)).to eq 2
            expect(assigns(:tasks_to_do)).to eq 1
            expect(assigns(:tasks_charts_adapter).tasks_in_chart).to eq [unfinished_task, other_task, task]

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
  end
end
