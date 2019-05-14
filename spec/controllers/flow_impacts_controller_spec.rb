# frozen_string_literal: true

RSpec.describe FlowImpactsController, type: :controller do
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
      before { delete :destroy, params: { company_id: 'bar', project_id: 'foo', id: 'xpto' } }

      it { is_expected.to redirect_to new_user_session_path }
    end

    describe 'GET #flow_impacts_tab' do
      before { get :flow_impacts_tab, params: { company_id: 'bar', project_id: 'foo' } }

      it { is_expected.to redirect_to new_user_session_path }
    end

    describe 'GET #new_direct_link' do
      before { get :new_direct_link, params: { company_id: 'bar' } }

      it { is_expected.to redirect_to new_user_session_path }
    end

    describe 'POST #create_direct_link' do
      before { post :create_direct_link, params: { company_id: 'bar' } }

      it { is_expected.to redirect_to new_user_session_path }
    end

    describe 'GET #demands_to_project' do
      before { get :demands_to_project, params: { company_id: 'bar', project_id: 'foo' } }

      it { is_expected.to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    before { sign_in user }

    let(:company) { Fabricate :company, users: [user] }
    let(:other_company) { Fabricate :company, users: [user] }

    let(:customer) { Fabricate :customer, company: company }
    let(:project) { Fabricate :project, customer: customer, status: :executing }

    let(:other_customer) { Fabricate :customer, company: other_company }
    let(:other_project) { Fabricate :project, customer: other_customer }

    let!(:demand) { Fabricate :demand, project: project, commitment_date: 1.day.ago, end_date: nil, demand_id: 'bbb' }
    let!(:other_demand) { Fabricate :demand, project: project, commitment_date: 1.day.ago, end_date: nil, demand_id: 'aaa' }

    let!(:out_demand) { Fabricate :demand, project: other_project, commitment_date: 1.day.ago, end_date: nil, demand_id: 'ccc' }

    let!(:not_started_demand) { Fabricate :demand, project: project, commitment_date: nil, end_date: nil, demand_id: 'ddd' }
    let!(:finished_demand) { Fabricate :demand, project: project, commitment_date: 1.day.ago, end_date: Time.zone.today, demand_id: 'eee' }

    describe 'GET #new' do
      context 'passing valid parameters' do
        it 'assign the instance variable and renders the template' do
          get :new, params: { company_id: company, project_id: project }, xhr: true
          expect(response).to render_template 'flow_impacts/_new'
          expect(assigns(:demands_for_impact_form)).to eq [other_demand, demand]
          expect(assigns(:flow_impact)).to be_a_new FlowImpact
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

    describe 'GET #new_direct_link' do
      context 'passing valid parameters' do
        it 'assign the instance variable and renders the template' do
          get :new_direct_link, params: { company_id: company }
          expect(response).to render_template 'flow_impacts/new_direct_link'
          expect(assigns(:demands_to_direct_link)).to eq []
          expect(assigns(:projects_to_direct_link)).to eq [project]
          expect(assigns(:flow_impact)).to be_a_new FlowImpact
        end
      end

      context 'passing invalid' do
        context 'company' do
          context 'not found' do
            before { get :new_direct_link, params: { company_id: 'foo', project_id: project } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:not_permitted_company) { Fabricate :company }

            before { get :new_direct_link, params: { company_id: not_permitted_company, project_id: project } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'POST #create' do
      context 'valid parameters' do
        let(:demand) { Fabricate :demand, project: project }

        before { post :create, params: { company_id: company, project_id: project, flow_impact: { demand_id: demand.id, impact_type: :api_not_ready, impact_description: 'foo bar', start_date: Time.zone.local(2019, 4, 2, 12, 38, 0), end_date: Time.zone.local(2019, 4, 2, 15, 38, 0) } }, xhr: true }

        it 'creates the impact and renders the JS template' do
          expect(response).to render_template 'flow_impacts/create.js.erb'
          expect(assigns(:flow_impact)).to be_persisted
          expect(assigns(:flow_impact).project).to eq project
          expect(assigns(:flow_impact).demand).to eq demand
          expect(assigns(:flow_impact).impact_type).to eq 'api_not_ready'
          expect(assigns(:flow_impact).impact_description).to eq 'foo bar'
          expect(assigns(:flow_impact).start_date).to eq Time.zone.local(2019, 4, 2, 12, 38, 0)
          expect(assigns(:flow_impact).end_date).to eq Time.zone.local(2019, 4, 2, 15, 38, 0)
        end
      end

      context 'passing invalid' do
        context 'parameters' do
          before { post :create, params: { company_id: company, project_id: project, flow_impact: { demand_id: '' } } }

          it { expect(assigns(:flow_impact).errors.full_messages).to eq ['Iniciou em não pode ficar em branco', 'Tipo do Impacto não pode ficar em branco', 'Descrição do Impacto não pode ficar em branco'] }
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

    describe 'POST #create_direct_link' do
      context 'valid parameters' do
        let(:demand) { Fabricate :demand, project: project }

        before { post :create_direct_link, params: { company_id: company, flow_impact: { project_id: project.id, demand_id: demand.id, impact_type: :api_not_ready, impact_description: 'foo bar', start_date: Time.zone.local(2019, 4, 2, 12, 38, 0), end_date: Time.zone.local(2019, 4, 2, 15, 38, 0) } }, xhr: true }

        it 'creates the impact and renders the JS template' do
          expect(response).to redirect_to new_direct_link_company_flow_impacts_path(company)
          expect(assigns(:flow_impact)).to be_persisted
          expect(assigns(:flow_impact).project).to eq project
          expect(assigns(:flow_impact).demand).to eq demand
          expect(assigns(:flow_impact).impact_type).to eq 'api_not_ready'
          expect(assigns(:flow_impact).impact_description).to eq 'foo bar'
          expect(assigns(:flow_impact).start_date).to eq Time.zone.local(2019, 4, 2, 12, 38, 0)
          expect(assigns(:flow_impact).end_date).to eq Time.zone.local(2019, 4, 2, 15, 38, 0)
        end
      end

      context 'passing invalid' do
        context 'parameters' do
          before { post :create_direct_link, params: { company_id: company, flow_impact: { project_id: '', demand_id: '' } } }

          it { expect(assigns(:flow_impact).errors.full_messages).to eq ['Projeto não pode ficar em branco', 'Iniciou em não pode ficar em branco', 'Tipo do Impacto não pode ficar em branco', 'Descrição do Impacto não pode ficar em branco'] }
        end

        context 'company' do
          context 'not found' do
            before { post :create_direct_link, params: { company_id: 'foo', project_id: project } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:not_permitted_company) { Fabricate :company }

            before { post :create_direct_link, params: { company_id: not_permitted_company, project_id: project } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:demand) { Fabricate :demand, project: project }

      context 'passing valid parameters' do
        let(:other_project) { Fabricate :project, customer: customer }

        let(:demand) { Fabricate :demand, project: project }

        let!(:first_impact) { Fabricate :flow_impact, project: project, demand: demand, start_date: 1.day.ago }
        let!(:second_impact) { Fabricate :flow_impact, project: project, demand: demand, start_date: 2.days.ago }

        it 'assign the instance variable and renders the template' do
          delete :destroy, params: { company_id: company, project_id: project, id: first_impact }
          expect(response).to render_template 'flow_impacts/destroy.js.erb'
          expect(project.reload.flow_impacts).to eq [second_impact]
        end
      end

      context 'passing invalid' do
        let!(:first_impact) { Fabricate :flow_impact, project: project, demand: demand, start_date: 1.day.ago }

        context 'company' do
          context 'not found' do
            before { delete :destroy, params: { company_id: 'foo', project_id: project, id: first_impact } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:not_permitted_company) { Fabricate :company }

            before { delete :destroy, params: { company_id: not_permitted_company, project_id: project, id: first_impact } }

            it { expect(response).to have_http_status :not_found }
          end
        end

        context 'project' do
          context 'not found' do
            before { delete :destroy, params: { company_id: company, project_id: 'foo', id: first_impact } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #flow_impacts_tab' do
      context 'passing valid parameters' do
        let(:demand) { Fabricate :demand, project: project }

        let!(:first_impact) { Fabricate :flow_impact, project: project, demand: demand, start_date: 1.day.ago }
        let!(:second_impact) { Fabricate :flow_impact, project: project, demand: demand, start_date: 2.days.ago }

        it 'assign the instance variable and renders the template' do
          get :flow_impacts_tab, params: { company_id: company, projects_ids: [project.id].join(',') }, xhr: true
          expect(response).to render_template 'flow_impacts/flow_impacts_tab'
          expect(assigns(:flow_impacts)).to eq [second_impact, first_impact]
        end
      end

      context 'passing invalid' do
        context 'company' do
          context 'not found' do
            before { get :flow_impacts_tab, params: { company_id: 'foo', projects_ids: [project.id].join(',') } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:not_permitted_company) { Fabricate :company }

            before { get :flow_impacts_tab, params: { company_id: not_permitted_company, projects_ids: [project.id].join(',') } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #demands_to_project' do
      context 'passing valid parameters' do
        it 'assign the instance variable and renders the template' do
          get :demands_to_project, params: { company_id: company, project_id: project }, xhr: true
          expect(response).to render_template 'flow_impacts/demands_to_project.js.erb'
          expect(assigns(:demands_to_project)).to eq [other_demand, demand]
        end
      end

      context 'passing invalid' do
        context 'company' do
          context 'not found' do
            before { get :demands_to_project, params: { company_id: 'foo', project_id: project } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:not_permitted_company) { Fabricate :company }

            before { get :demands_to_project, params: { company_id: not_permitted_company, project_id: project } }

            it { expect(response).to have_http_status :not_found }
          end
        end

        context 'project' do
          context 'not found' do
            before { get :demands_to_project, params: { company_id: company, project_id: 'foo' } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end
  end
end
