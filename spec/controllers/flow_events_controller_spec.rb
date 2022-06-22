# frozen_string_literal: true

RSpec.describe FlowEventsController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'bar', project_id: 'foo' } }

      it { is_expected.to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'bar', project_id: 'foo' } }

      it { is_expected.to redirect_to new_user_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'bar', project_id: 'bla', id: 'xpto' } }

      it { is_expected.to redirect_to new_user_session_path }
    end

    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'bar', project_id: 'bla', id: 'xpto' } }

      it { is_expected.to redirect_to new_user_session_path }
    end

    describe 'PUT #update' do
      before { put :update, params: { company_id: 'bar', project_id: 'bla', id: 'xpto' } }

      it { is_expected.to redirect_to new_user_session_path }
    end

    describe 'GET #show' do
      before { get :show, params: { company_id: 'foo', project_id: 'bla', id: 'bar' } }

      it { is_expected.to redirect_to new_user_session_path }
    end

    describe 'GET #index' do
      before { get :index, params: { company_id: 'foo', project_id: 'bla' } }

      it { is_expected.to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:other_company) { Fabricate :company, users: [user] }

    let(:team) { Fabricate :team, company: company }

    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, company: company, team: team, customers: [customer], status: :executing }

    let(:other_customer) { Fabricate :customer, company: other_company }
    let(:other_project) { Fabricate :project, customers: [other_customer] }

    let!(:demand) { Fabricate :demand, project: project, commitment_date: 1.day.ago, end_date: nil, external_id: 'bbb' }
    let!(:other_demand) { Fabricate :demand, project: project, commitment_date: 1.day.ago, end_date: nil, external_id: 'aaa' }

    let!(:out_demand) { Fabricate :demand, project: other_project, commitment_date: 1.day.ago, end_date: nil, external_id: 'ccc' }

    let!(:not_committed_demand) { Fabricate :demand, project: project, commitment_date: nil, end_date: nil, external_id: 'ddd' }
    let!(:finished_demand) { Fabricate :demand, project: project, commitment_date: 1.day.ago, end_date: Time.zone.today, external_id: 'eee' }

    let!(:first_demand_transition) { Fabricate :demand_transition, demand: demand }
    let!(:second_demand_transition) { Fabricate :demand_transition, demand: demand }
    let!(:third_demand_transition) { Fabricate :demand_transition, demand: other_demand }
    let!(:fourth_demand_transition) { Fabricate :demand_transition, demand: other_demand }

    describe 'GET #new' do
      context 'passing valid parameters' do
        it 'assign the instance variable and renders the template' do
          get :new, params: { company_id: company, project_id: project }
          expect(response).to render_template :new
          expect(assigns(:flow_event)).to be_a_new FlowEvent
        end
      end

      context 'passing invalid' do
        context 'company' do
          context 'not found' do
            before { get :new, params: { company_id: 'foo', project_id: project } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:not_permitted_company) { Fabricate :company }

            before { get :new, params: { company_id: not_permitted_company, project_id: project } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'POST #create' do
      let(:team) { Fabricate :team, company: company }
      let(:team_project) { Fabricate :project, team: team }

      context 'valid parameters' do
        it 'creates the event and renders the JS template' do
          event_end_date = 3.days.from_now

          post :create, params: { company_id: company, flow_event: { team_id: team, project_id: team_project, event_type: :api_not_ready, event_size: :medium, event_description: 'foo bar', event_date: Time.zone.now.beginning_of_day, event_end_date: event_end_date } }
          expect(response).to redirect_to company_flow_events_path(company)
          created_event = assigns(:flow_event)

          expect(created_event).to be_persisted
          expect(created_event.user).to eq user
          expect(created_event.team).to eq team
          expect(created_event.project).to eq team_project
          expect(created_event.event_type).to eq 'api_not_ready'
          expect(created_event.event_size).to eq 'medium'
          expect(created_event.event_description).to eq 'foo bar'
          expect(created_event.event_date).to eq Time.zone.today
          expect(created_event.event_end_date).to eq event_end_date.to_date
        end
      end

      context 'passing invalid' do
        context 'parameters' do
          before { post :create, params: { company_id: company, project_id: project, flow_event: { demand_id: '' } }, xhr: true }

          it 're-assigns the form with the errors' do
            expect(response).to render_template :new
            expect(assigns(:flow_event).errors.full_messages).to eq ['Data do Evento não pode ficar em branco', 'Tipo do Evento não pode ficar em branco', 'Descrição do Evento não pode ficar em branco']
          end
        end

        context 'company' do
          context 'not found' do
            before { post :create, params: { company_id: 'foo', project_id: project } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:not_permitted_company) { Fabricate :company }

            before { post :create, params: { company_id: not_permitted_company, project_id: project } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:demand) { Fabricate :demand, project: project }

      context 'passing valid parameters' do
        let(:other_project) { Fabricate :project, customers: [customer] }

        let(:demand) { Fabricate :demand, project: project }

        let!(:first_event) { Fabricate :flow_event, project: project, event_date: 1.day.ago }
        let!(:second_event) { Fabricate :flow_event, project: project, event_date: 2.days.ago }

        it 'assign the instance variable and renders the template' do
          delete :destroy, params: { company_id: company, project_id: project, id: first_event }, xhr: true

          expect(response).to render_template 'flow_events/destroy'
          expect(project.reload.flow_events).to eq [second_event]
        end
      end

      context 'passing invalid' do
        let!(:first_event) { Fabricate :flow_event, project: project, event_date: 1.day.ago }

        context 'company' do
          context 'not found' do
            before { delete :destroy, params: { company_id: 'foo', project_id: project, id: first_event }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:not_permitted_company) { Fabricate :company }

            before { delete :destroy, params: { company_id: not_permitted_company, project_id: project, id: first_event }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #edit' do
      let(:flow_event) { Fabricate :flow_event, project: project, team: team }

      context 'passing valid parameters' do
        it 'assign the instance variable and renders the template' do
          get :edit, params: { company_id: company, project_id: project, id: flow_event }
          expect(response).to render_template :edit
          expect(assigns(:flow_event)).to eq flow_event
          expect(assigns(:projects_by_team)).to eq [project]
        end
      end

      context 'passing invalid' do
        context 'company' do
          context 'not found' do
            before { get :edit, params: { company_id: 'foo', project_id: project, id: flow_event } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:not_permitted_company) { Fabricate :company }

            before { get :edit, params: { company_id: not_permitted_company, project_id: project, id: flow_event } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let(:team) { Fabricate :team, company: company }
      let(:flow_event) { Fabricate :flow_event, project: project, user: user }

      context 'valid parameters' do
        let(:demand) { Fabricate :demand, project: project }

        before { put :update, params: { company_id: company, id: flow_event, flow_event: { team_id: team, project_id: project, event_type: :api_not_ready, event_description: 'foo bar', event_date: Time.zone.local(2019, 4, 2, 12, 38, 0), end_date: Time.zone.local(2019, 4, 2, 15, 38, 0) } } }

        it 'creates the event and renders the JS template' do
          expect(response).to redirect_to company_flow_events_path(company)

          expect(assigns(:flow_event)).to be_persisted
          expect(assigns(:flow_event).user).to eq user
          expect(assigns(:flow_event).team).to eq team
          expect(assigns(:flow_event).project).to eq project
          expect(assigns(:flow_event).event_type).to eq 'api_not_ready'
          expect(assigns(:flow_event).event_description).to eq 'foo bar'
          expect(assigns(:flow_event).event_date).to eq Date.new(2019, 4, 2)
        end
      end

      context 'passing invalid' do
        context 'parameters' do
          before { put :update, params: { company_id: company, project_id: project, id: flow_event, flow_event: { demand_id: '', event_date: nil, event_type: nil, event_description: nil } } }

          it { expect(assigns(:flow_event).errors.full_messages).to eq ['Data do Evento não pode ficar em branco', 'Tipo do Evento não pode ficar em branco', 'Descrição do Evento não pode ficar em branco'] }
        end

        context 'flow_event' do
          before { put :update, params: { company_id: company, project_id: project, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'not found' do
            before { put :update, params: { company_id: 'foo', project_id: project, id: flow_event } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:not_permitted_company) { Fabricate :company }

            before { put :update, params: { company_id: not_permitted_company, project_id: project, id: flow_event } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #show' do
      let(:flow_event) { Fabricate :flow_event, project: project }
      let(:other_flow_event) { Fabricate :flow_event }

      context 'valid parameters' do
        before { get :show, params: { company_id: company, project_id: project, id: flow_event } }

        it 'instantiates a new Team Member and renders the template' do
          expect(response).to render_template :show
          expect(assigns(:flow_event)).to eq flow_event
        end
      end

      context 'invalid parameters' do
        context 'invalid flow event' do
          before { get :show, params: { company_id: company, project_id: project, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent company' do
          before { get :show, params: { company_id: 'foo', project_id: project, id: flow_event } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :show, params: { company_id: company, project_id: project, id: flow_event } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #index' do
      context 'with valid parameters' do
        it 'instantiates a new Team Member and renders the template' do
          flow_event = Fabricate :flow_event, company: company, event_date: 1.day.ago
          other_flow_event = Fabricate :flow_event, company: company, event_date: Time.zone.now

          get :index, params: { company_id: company }

          expect(response).to render_template :index
          expect(assigns(:flow_events)).to eq [other_flow_event, flow_event]
        end
      end

      context 'with invalid' do
        context 'non-existent company' do
          before { get :index, params: { company_id: 'foo', project_id: project } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not-permitted company' do
          let(:company) { Fabricate :company, users: [] }

          before { get :index, params: { company_id: company, project_id: project } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
