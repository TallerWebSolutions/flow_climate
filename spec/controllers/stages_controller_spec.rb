# frozen_string_literal: true

RSpec.describe StagesController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #new' do
      before { get :new, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #create' do
      before { post :create, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'foo', id: 'sbbrubles', xhr: true } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PUT #update' do
      before { put :update, params: { company_id: 'foo', id: 'sbbrubles', xhr: true } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'foo', id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #show' do
      before { get :show, params: { company_id: 'foo', id: 'sbbrubles' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PATCH #associate_project' do
      before { patch :associate_project, params: { company_id: 'foo', id: 'sbbrubles', project_id: 'bla' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PATCH #dissociate_project' do
      before { patch :dissociate_project, params: { company_id: 'foo', id: 'sbbrubles', project_id: 'bla' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PATCH #associate_team' do
      before { patch :associate_team, params: { company_id: 'foo', id: 'sbbrubles', team_id: 'bla' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PATCH #dissociate_team' do
      before { patch :dissociate_team, params: { company_id: 'foo', id: 'sbbrubles', team_id: 'bla' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PATCH #copy_projects_from' do
      before { patch :copy_projects_from, params: { company_id: 'foo', id: 'sbbrubles', provider_stage_id: 'bla' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #import_from_jira' do
      before { post :import_from_jira, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated as gold' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, finish_at: 1.week.from_now }

    let(:company) { Fabricate :company, users: [user] }

    let(:team) { Fabricate :team, company: company }

    before { sign_in user }

    describe 'GET #new' do
      context 'valid parameters' do
        it 'instantiates a new Stage and renders the template' do
          parent = Fabricate :stage, company: company, name: 'zzz'
          other_parent = Fabricate :stage, company: company, name: 'aaa'
          Fabricate :stage, name: 'ccc'

          get :new, params: { company_id: company }

          expect(response).to render_template :new
          expect(assigns(:stage)).to be_a_new Stage
          expect(assigns(:parent_stages)).to eq [other_parent, parent]
        end
      end

      context 'invalid parameters' do
        context 'inexistent company' do
          before { get :new, params: { company_id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'and not permitted' do
          let(:company) { Fabricate :company }

          before { get :new, params: { company_id: company } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'POST #create' do
      context 'passing valid parameters' do
        it 'creates the new financial information to the company and redirects to its show' do
          parent_stage = Fabricate :stage, company: company, name: 'zzz'

          expect(StagesRepository.instance).to receive(:save_stage).once.and_call_original

          post :create, params: { company_id: company, stage: { order: 2, team_id: team.id, name: 'foo', integration_pipe_id: '100', integration_id: '332231', stage_type: :analysis, stage_stream: :downstream, commitment_point: true, end_point: true, queue: true, stage_level: :coordination, parent_id: parent_stage } }

          created_stage = Stage.last
          expect(created_stage.company).to eq company
          expect(created_stage.order).to eq 2
          expect(created_stage.teams).to eq [team]
          expect(created_stage.integration_pipe_id).to eq '100'
          expect(created_stage.integration_id).to eq '332231'
          expect(created_stage.name).to eq 'foo'
          expect(created_stage.stage_type).to eq 'analysis'
          expect(created_stage.stage_stream).to eq 'downstream'
          expect(created_stage.commitment_point?).to be true
          expect(created_stage.end_point?).to be true
          expect(created_stage.queue?).to be true
          expect(created_stage.coordination?).to be true
          expect(created_stage.parent).to eq parent_stage

          expect(response).to redirect_to company_path(company)
        end
      end

      context 'passing invalid parameters' do
        context 'invalid attributes' do
          it 'does not create the company and re-render the template with the errors' do
            parent_stage = Fabricate :stage, company: company, name: 'zzz'
            other_parent = Fabricate :stage, company: company, name: 'aaa'
            Fabricate :stage, name: 'ccc'

            post :create, params: { company_id: company, stage: { name: nil, integration_id: nil, stage_type: nil, stage_stream: nil, commitment_point: nil, end_point: nil, queue: nil } }

            expect(company.reload.stages.count).to eq 2
            expect(response).to render_template :new
            expect(assigns(:stage).errors.full_messages).to eq ['Nome não pode ficar em branco', 'Tipo da Etapa não pode ficar em branco', 'Tipo do Stream não pode ficar em branco']
            expect(assigns(:parent_stages)).to eq [other_parent, parent_stage]
          end
        end

        context 'inexistent company' do
          before { post :create, params: { company_id: 'foo', stage: { name: 'foo', integration_id: '332231', stage_type: :analysis, stage_stream: :downstream, commitment_point: true, end_point: true, queue: true } } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'and not permitted company' do
          let(:company) { Fabricate :company }

          before { post :create, params: { company_id: company, stage: { name: 'foo', integration_id: '332231', stage_type: :analysis, stage_stream: :downstream, commitment_point: true, end_point: true, queue: true } } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #edit' do
      let(:company) { Fabricate :company, users: [user] }
      let(:stage) { Fabricate :stage, company: company }

      context 'valid parameters' do
        it 'assigns the instance variables and renders the template' do
          parent = Fabricate :stage, company: company, name: 'zzz'
          other_parent = Fabricate :stage, company: company, name: 'aaa'
          Fabricate :stage, name: 'ccc'

          get :edit, params: { company_id: company, id: stage }, xhr: true

          expect(response).to render_template 'stages/edit'
          expect(assigns(:company)).to eq company
          expect(assigns(:stage)).to eq stage
          expect(assigns(:parent_stages)).to eq [other_parent, parent]
        end
      end

      context 'invalid' do
        context 'company' do
          context 'non-existent' do
            before { get :edit, params: { company_id: 'foo', id: stage }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :edit, params: { company_id: company, id: stage }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let(:company) { Fabricate :company, users: [user] }
      let(:stage) { Fabricate :stage, company: company }
      let(:team) { Fabricate :team, company: company }

      context 'passing valid parameters' do
        it 'updates the demand and redirects to projects index' do
          parent_stage = Fabricate :stage, company: company, name: 'zzz'
          other_parent = Fabricate :stage, company: company, name: 'aaa'
          Fabricate :stage, name: 'ccc'

          expect(StagesRepository.instance).to receive(:save_stage).once.and_call_original

          put :update, params: { company_id: company, id: stage, stage: { order: 2, team_id: team.id, name: 'foo', integration_pipe_id: '100', integration_id: '332231', stage_type: :analysis, stage_stream: :downstream, commitment_point: true, end_point: true, queue: true, stage_level: :coordination, parent_id: parent_stage } }, xhr: true
          updated_stage = stage.reload
          expect(updated_stage.company).to eq company
          expect(updated_stage.order).to eq 2
          expect(updated_stage.integration_pipe_id).to eq '100'
          expect(updated_stage.integration_id).to eq '332231'
          expect(updated_stage.name).to eq 'foo'
          expect(updated_stage.stage_type).to eq 'analysis'
          expect(updated_stage.stage_stream).to eq 'downstream'
          expect(updated_stage.commitment_point?).to be true
          expect(updated_stage.end_point?).to be true
          expect(updated_stage.queue?).to be true
          expect(updated_stage.coordination?).to be true
          expect(updated_stage.parent).to eq parent_stage
          expect(assigns(:parent_stages)).to eq [other_parent, parent_stage]
          expect(response).to render_template 'stages/update'
        end
      end

      context 'passing invalid' do
        context 'parameters' do
          before { put :update, params: { company_id: company, id: stage, stage: { name: nil, integration_id: nil, stage_type: nil, stage_stream: nil, commitment_point: nil, end_point: nil, queue: nil } }, xhr: true }

          it { expect(assigns(:stage).errors.full_messages).to match_array ['Nome não pode ficar em branco', 'Tipo da Etapa não pode ficar em branco', 'Tipo do Stream não pode ficar em branco'] }
        end

        context 'non-stage' do
          before { put :update, params: { company_id: company, id: 'foo', stage: { name: 'foo' } }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { put :update, params: { company_id: 'foo', id: stage, stage: { name: 'foo' } }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { put :update, params: { company_id: company, id: stage, stage: { name: 'foo' } }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'DELETE #destroy' do
      let(:company) { Fabricate :company, users: [user] }
      let(:stage) { Fabricate :stage, company: company }

      context 'passing valid ID' do
        context 'having no dependencies' do
          before { delete :destroy, params: { company_id: company, id: stage } }

          it 'deletes the stage and redirects' do
            expect(response).to redirect_to company_path(company)
            expect(Stage.last).to be_nil
          end
        end

        context 'with dependencies' do
          let(:project) { Fabricate :project }
          let!(:stage) { Fabricate :stage, company: company, projects: [project] }
          let(:demand) { Fabricate :demand, project: project }
          let!(:demand_transition) { Fabricate :demand_transition, stage: stage, demand: demand }

          before { delete :destroy, params: { company_id: company, id: stage } }

          it 'does not delete the stage and show the errors' do
            expect(response).to redirect_to company_path(company)
            expect(Stage.last).to eq stage
            expect(flash[:error]).to eq assigns(:stage).errors.full_messages.join(',')
          end
        end
      end

      context 'passing an invalid' do
        context 'non-existent stage' do
          before { delete :destroy, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { delete :destroy, params: { company_id: 'foo', id: stage } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { delete :destroy, params: { company_id: company, id: stage } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #show' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company, name: 'aaa' }
      let(:product) { Fabricate :product, company: company, customer: customer, name: 'aaa' }
      let(:other_product) { Fabricate :product, company: company, customer: customer, name: 'zzz' }
      let(:stage) { Fabricate :stage, company: company }

      let!(:first_project) { Fabricate :project, company: company, customers: [customer], products: [product], stages: [stage], name: 'zzz' }
      let!(:second_project) { Fabricate :project, company: company, customers: [customer], products: [product], stages: [stage], name: 'aaa' }
      let!(:third_project) { Fabricate :project, company: company, customers: [customer], products: [other_product], name: 'yyy' }
      let!(:fourth_project) { Fabricate :project, company: company, customers: [customer], products: [other_product], name: 'bbb' }

      context 'passing valid parameters' do
        it 'assigns the instance variables and renders the template' do
          get :show, params: { company_id: company, id: stage }
          expect(response).to render_template :show
          expect(assigns(:stage)).to eq stage
          expect(assigns(:stage_analytic_data)).to be_a StageAnalyticData
          expect(assigns(:stage_projects)).to eq [second_project, first_project]
          expect(assigns(:not_associated_projects)).to match_array [fourth_project, third_project]
        end
      end

      context 'passing an invalid' do
        context 'non-existent stage' do
          before { get :show, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { get :show, params: { company_id: 'foo', id: stage } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :show, params: { company_id: company, id: stage } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PATCH #associate_project' do
      let(:company) { Fabricate :company, users: [user] }
      let!(:stage) { Fabricate :stage, company: company }

      let!(:project) { Fabricate :project, stages: [stage] }

      context 'passing valid parameters' do
        it 'associate the project from stage and renders the template' do
          patch :associate_project, params: { company_id: company, id: stage, project_id: project }
          expect(response).to redirect_to company_stage_path(company, stage)
          expect(stage.reload.projects).to eq [project]
        end
      end

      context 'passing an invalid' do
        context 'non-existent stage' do
          before { patch :associate_project, params: { company_id: company, id: 'foo', project_id: project } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent project' do
          before { patch :associate_project, params: { company_id: company, id: 'foo', project_id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { patch :associate_project, params: { company_id: 'foo', id: stage, project_id: project } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { patch :associate_project, params: { company_id: company, id: stage, project_id: project } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PATCH #dissociate_project' do
      let(:company) { Fabricate :company, users: [user] }
      let!(:stage) { Fabricate :stage, company: company }

      let!(:project) { Fabricate :project, stages: [stage] }

      context 'passing valid parameters' do
        it 'dissociate the project from stage and renders the template' do
          patch :dissociate_project, params: { company_id: company, id: stage, project_id: project }
          expect(response).to redirect_to company_stage_path(company, stage)
          expect(stage.reload.projects).to eq []
        end
      end

      context 'passing an invalid' do
        context 'non-existent stage' do
          before { patch :dissociate_project, params: { company_id: company, id: 'foo', project_id: project } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent project' do
          before { patch :dissociate_project, params: { company_id: company, id: 'foo', project_id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { patch :dissociate_project, params: { company_id: 'foo', id: stage, project_id: project } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { patch :dissociate_project, params: { company_id: company, id: stage, project_id: project } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PATCH #associate_team' do
      let(:company) { Fabricate :company, users: [user] }
      let!(:stage) { Fabricate :stage, company: company }

      let!(:team) { Fabricate :team, company: company, stages: [stage] }
      let!(:other_team) { Fabricate :team, company: company, stages: [stage] }

      context 'passing valid parameters' do
        it 'associates the team and renders the template' do
          patch :associate_team, params: { company_id: company, id: stage, team_id: team }, xhr: true
          expect(response).to render_template 'stages/associate_dissociate_team'
          expect(stage.reload.teams).to match_array [team, other_team]
        end
      end

      context 'passing an invalid' do
        context 'non-existent stage' do
          before { patch :associate_team, params: { company_id: company, id: 'foo', team_id: team }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent team' do
          before { patch :associate_team, params: { company_id: company, id: 'foo', team_id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { patch :associate_team, params: { company_id: 'foo', id: stage, team_id: team }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { patch :associate_team, params: { company_id: company, id: stage, team_id: team }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PATCH #dissociate_team' do
      let(:company) { Fabricate :company, users: [user] }
      let!(:stage) { Fabricate :stage, company: company }

      let!(:team) { Fabricate :team, company: company, stages: [stage] }
      let!(:other_team) { Fabricate :team, company: company, stages: [stage] }

      context 'passing valid parameters' do
        it 'assigns the instance variables and renders the template' do
          patch :dissociate_team, params: { company_id: company, id: stage, team_id: team }, xhr: true
          expect(response).to render_template 'stages/associate_dissociate_team'
          expect(stage.reload.teams).to eq [other_team]
        end
      end

      context 'passing an invalid' do
        context 'non-existent stage' do
          before { patch :dissociate_team, params: { company_id: company, id: 'foo', team_id: team }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent team' do
          before { patch :dissociate_team, params: { company_id: company, id: 'foo', team_id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { patch :dissociate_team, params: { company_id: 'foo', id: stage, team_id: team }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { patch :dissociate_team, params: { company_id: company, id: stage, team_id: team }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PATCH #copy_projects_from' do
      let(:company) { Fabricate :company, users: [user] }
      let!(:provider_stage) { Fabricate :stage, company: company }

      let!(:first_project) { Fabricate :project, stages: [provider_stage] }
      let!(:second_project) { Fabricate :project, stages: [provider_stage] }
      let!(:third_project) { Fabricate :project, stages: [provider_stage] }

      let!(:fourth_project) { Fabricate :project }

      let!(:receiver_stage) { Fabricate :stage, company: company }
      let!(:fifth_project) { Fabricate :project, stages: [receiver_stage] }

      context 'passing valid parameters' do
        it 'assigns the instance variables and renders the template' do
          patch :copy_projects_from, params: { company_id: company, id: receiver_stage, provider_stage_id: provider_stage }
          expect(response).to redirect_to company_stage_path(company, receiver_stage)
          expect(receiver_stage.reload.projects).to match_array [first_project, second_project, third_project]
        end
      end

      context 'passing an invalid' do
        context 'non-existent stage' do
          before { patch :copy_projects_from, params: { company_id: company, id: 'foo', provider_stage_id: provider_stage } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'non-existent provider_stage' do
          before { patch :copy_projects_from, params: { company_id: company, id: receiver_stage, provider_stage_id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'company' do
          context 'non-existent' do
            before { patch :copy_projects_from, params: { company_id: 'foo', id: receiver_stage, provider_stage_id: provider_stage } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { patch :copy_projects_from, params: { company_id: company, id: receiver_stage, provider_stage_id: provider_stage } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'POST #import_from_jira' do
      let(:company) { Fabricate :company, users: [user] }
      let!(:first_stage) { Fabricate :stage, company: company, integration_id: 'sbbrubles', name: 'foobar' }
      let!(:second_stage) { Fabricate :stage, company: company, name: 'xpto' }

      context 'passing valid parameters' do
        context 'with JiraAccount' do
          let!(:jira_account) { Fabricate :jira_account, company: company }
          let(:options) { { username: 'foo', password: 'bar', site: 'https://foo.atlassian.net/', context_path: '/', auth_type: :basic } }
          let(:client) { JIRA::Client.new(options) }

          context 'and the stage does not exist' do
            it 'creates the stage with minimum fields' do
              returned_status = client.Status.build('id' => 'foo', 'name' => 'bar')

              expect_any_instance_of(Jira::JiraApiService).to(receive(:request_status).once { [returned_status] })
              post :import_from_jira, params: { company_id: company }
              expect(response).to redirect_to company_stages_path(company)
              expect(assigns(:stages_list).count).to eq 3
              expect(assigns(:stages_list).where(integration_id: 'foo').count).to eq 1
            end
          end

          context 'and the stage exists' do
            it 'updates the stage' do
              returned_status = client.Status.build('id' => 'sbbrubles', 'name' => 'bar')

              expect_any_instance_of(Jira::JiraApiService).to(receive(:request_status).once { [returned_status] })
              post :import_from_jira, params: { company_id: company }
              expect(response).to redirect_to company_stages_path(company)
              expect(assigns(:stages_list).count).to eq 2
              expect(assigns(:stages_list).map(&:name)).to match_array(%w[bar xpto])
            end
          end
        end

        context 'without JiraAccount' do
          it 'assigns the instance variables and renders the template' do
            post :import_from_jira, params: { company_id: company }
            expect(response).to redirect_to company_stages_path(company)
            expect(assigns(:stages_list).count).to eq 2
          end
        end
      end

      context 'passing an invalid' do
        context 'company' do
          context 'non-existent' do
            before { post :import_from_jira, params: { company_id: 'foo' } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { post :import_from_jira, params: { company_id: company } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end
  end
end
