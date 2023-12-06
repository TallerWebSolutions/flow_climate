# frozen_string_literal: true

RSpec.describe DemandBlocksController do
  context 'unauthenticated' do
    describe 'PATCH #activate' do
      before { patch :activate, params: { company_id: 'xpto', project_id: 'bar', demand_id: 'foo', id: 'sbbrubles' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PATCH #deactivate' do
      before { patch :deactivate, params: { company_id: 'xpto', project_id: 'bar', demand_id: 'foo', id: 'sbbrubles' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #edit' do
      before { get :edit, params: { company_id: 'xpto', project_id: 'bar', demand_id: 'foo', id: 'sbbrubles' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'PUT #update' do
      before { put :update, params: { company_id: 'xpto', project_id: 'bar', demand_id: 'foo', id: 'sbbrubles' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #index' do
      before { put :index, params: { company_id: 'xpto', project_id: 'bar' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #demand_blocks_csv' do
      before { get :demand_blocks_csv, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'POST #search' do
      before { post :search, params: { company_id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated as gold' do
    let(:plan) { Fabricate :plan, plan_type: :gold }
    let(:user) { Fabricate :user, first_name: 'zzz' }
    let!(:user_plan) { Fabricate :user_plan, user: user, plan: plan, active: true, paid: true, start_at: 1.week.ago, finish_at: 1.week.from_now }

    before { sign_in user }

    describe 'PATCH #activate' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, customers: [customer] }
      let(:demand) { Fabricate :demand, company: company, project: project }
      let(:demand_block) { Fabricate :demand_block, demand: demand, active: false }

      context 'passing valid parameters' do
        before { patch :activate, params: { company_id: company, project_id: project, demand_id: demand, id: demand_block }, xhr: true }

        it 'assigns the instance variable and renders the template' do
          expect(response).to render_template 'demand_blocks/activate_deactivate_block'
          expect(demand_block.reload.active).to be true
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { patch :activate, params: { company_id: 'foo', project_id: project, demand_id: demand, id: demand_block }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'project' do
          before { patch :activate, params: { company_id: company, project_id: 'foo', demand_id: demand, id: demand_block }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'demand' do
          before { patch :activate, params: { company_id: company, project_id: project, demand_id: 'foo', id: demand_block }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'demand_block' do
          before { patch :activate, params: { company_id: company, project_id: project, demand_id: demand, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'PATCH #deactivate' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, customers: [customer] }
      let(:demand) { Fabricate :demand, company: company, project: project }
      let(:demand_block) { Fabricate :demand_block, demand: demand, active: true }

      context 'passing valid parameters' do
        before { patch :deactivate, params: { company_id: company, project_id: project, demand_id: demand, id: demand_block }, xhr: true }

        it 'assigns the instance variable and renders the template' do
          expect(response).to render_template 'demand_blocks/activate_deactivate_block'
          expect(demand_block.reload.active).to be false
        end
      end

      context 'passing invalid' do
        context 'company' do
          before { patch :deactivate, params: { company_id: 'foo', project_id: project, demand_id: demand, id: demand_block } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'project' do
          before { patch :deactivate, params: { company_id: company, project_id: 'foo', demand_id: demand, id: demand_block } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'demand' do
          before { patch :deactivate, params: { company_id: company, project_id: project, demand_id: 'foo', id: demand_block } }

          it { expect(response).to have_http_status :not_found }
        end

        context 'demand_block' do
          before { patch :deactivate, params: { company_id: company, project_id: project, demand_id: demand, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #edit' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }
      let!(:project) { Fabricate :project, customers: [customer] }
      let(:demand) { Fabricate :demand, company: company, project: project }
      let(:demand_block) { Fabricate :demand_block, demand: demand, active: true }

      context 'with valid parameters' do
        context 'with JS call' do
          before { get :edit, params: { company_id: company, project_id: project, demand_id: demand, id: demand_block }, xhr: true }

          it 'assigns the instance variable and renders the JS template' do
            expect(response).to render_template 'demand_blocks/edit'
            expect(response).to render_template 'demand_blocks/_edit'
            expect(response).to render_template 'demand_blocks/_form'
          end
        end

        context 'with HTML call' do
          before { get :edit, params: { company_id: company, project_id: project, demand_id: demand, id: demand_block } }

          it 'assigns the instance variable and renders the HTML template' do
            expect(response).to render_template 'demand_blocks/edit'
            expect(response).to render_template 'demand_blocks/_form'
          end
        end
      end

      context 'with JS call' do
        context 'passing invalid' do
          context 'company' do
            before { get :edit, params: { company_id: 'foo', project_id: project, demand_id: demand, id: demand_block }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'project' do
            before { get :edit, params: { company_id: company, project_id: 'foo', demand_id: demand, id: demand_block }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'demand' do
            before { get :edit, params: { company_id: company, project_id: project, demand_id: 'foo', id: demand_block }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'demand_block' do
            before { get :edit, params: { company_id: company, project_id: project, demand_id: demand, id: 'foo' }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end

      context 'with HTML call' do
        context 'passing invalid' do
          context 'company' do
            before { get :edit, params: { company_id: 'foo', project_id: project, demand_id: demand, id: demand_block } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'project' do
            before { get :edit, params: { company_id: company, project_id: 'foo', demand_id: demand, id: demand_block } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'demand' do
            before { get :edit, params: { company_id: company, project_id: project, demand_id: 'foo', id: demand_block } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'demand_block' do
            before { get :edit, params: { company_id: company, project_id: project, demand_id: demand, id: 'foo' } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'PUT #update' do
      let(:company) { Fabricate :company, users: [user] }

      let(:team) { Fabricate :team, company: company }
      let(:team_member) { Fabricate :team_member }
      let(:other_team_member) { Fabricate :team_member }

      let!(:membership) { Fabricate :membership, team: team, team_member: team_member, hours_per_month: 20, start_date: 1.month.ago, end_date: nil }
      let!(:other_membership) { Fabricate :membership, team: team, team_member: other_team_member, hours_per_month: 160, start_date: 2.months.ago, end_date: 1.month.ago }

      let(:customer) { Fabricate :customer, company: company }
      let(:project) { Fabricate :project, customers: [customer], team: team }
      let(:demand) { Fabricate :demand, company: company, project: project, team: team }
      let(:demand_block) { Fabricate :demand_block, demand: demand, active: true }

      context 'passing valid parameters' do
        context 'with JS call' do
          it 'assigns the instance variable and renders the template' do
            put :update, params: { company_id: company, project_id: project, demand_id: demand, id: demand_block, demand_block: { block_type: :specification_needed, block_reason: 'bla', unblock_reason: 'foo', blocker_id: team_member.id, unblocker_id: other_team_member.id } }, xhr: true

            updated_demand_block = assigns(:demand_block)
            expect(updated_demand_block.block_type).to eq 'specification_needed'
            expect(updated_demand_block.block_reason).to eq 'bla'
            expect(updated_demand_block.blocker).to eq team_member
            expect(updated_demand_block.unblocker).to eq other_team_member
            expect(response).to render_template 'demand_blocks/update'
          end
        end

        context 'with HTML call' do
          it 'assigns the instance variable and redirects to the demand show' do
            put :update, params: { company_id: company, project_id: project, demand_id: demand, id: demand_block, demand_block: { block_type: :specification_needed, block_reason: 'bla', unblock_reason: 'foo', blocker_id: team_member.id, unblocker_id: other_team_member.id } }

            updated_demand_block = assigns(:demand_block)
            expect(updated_demand_block.block_type).to eq 'specification_needed'
            expect(updated_demand_block.block_reason).to eq 'bla'
            expect(updated_demand_block.blocker).to eq team_member
            expect(updated_demand_block.unblocker).to eq other_team_member
            expect(response).to redirect_to company_demand_path(company, demand)
          end
        end
      end

      context 'passing invalid' do
        context 'with JS call' do
          context 'company' do
            before { put :update, params: { company_id: 'foo', project_id: project, demand_id: demand, id: demand_block }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'project' do
            before { put :update, params: { company_id: company, project_id: 'foo', demand_id: demand, id: demand_block }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'demand' do
            before { put :update, params: { company_id: company, project_id: project, demand_id: 'foo', id: demand_block }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end

          context 'demand_block' do
            before { put :update, params: { company_id: company, project_id: project, demand_id: demand, id: 'foo' }, xhr: true }

            it { expect(response).to have_http_status :not_found }
          end
        end

        context 'with HTML call' do
          context 'company' do
            before { put :update, params: { company_id: 'foo', project_id: project, demand_id: demand, id: demand_block } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'project' do
            before { put :update, params: { company_id: company, project_id: 'foo', demand_id: demand, id: demand_block } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'demand' do
            before { put :update, params: { company_id: company, project_id: project, demand_id: 'foo', id: demand_block } }

            it { expect(response).to have_http_status :not_found }
          end

          context 'demand_block' do
            before { put :update, params: { company_id: company, project_id: project, demand_id: demand, id: 'foo' } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #index' do
      let(:company) { Fabricate :company, users: [user] }
      let(:customer) { Fabricate :customer, company: company }

      context 'passing valid parameters' do
        it 'assigns the instance variable and renders the template' do
          project = Fabricate :project, customers: [customer], status: :executing
          other_project = Fabricate :project, customers: [customer], status: :finished
          demand = Fabricate :demand, company: company, project: project
          other_demand = Fabricate :demand, company: company, project: other_project

          first_demand_block = Fabricate :demand_block, demand: demand, active: true, block_time: 1.day.ago
          second_demand_block = Fabricate :demand_block, demand: demand, active: true, block_time: Time.zone.now
          third_demand_block = Fabricate :demand_block, demand: other_demand, active: true, block_time: Time.zone.now
          fourth_demand_block = Fabricate :demand_block, demand: demand, active: false, block_time: Time.zone.now

          get :index, params: { company_id: company }

          expect(project).to eq project
          expect(company).to eq company
          expect(assigns(:demand_blocks)).to eq [second_demand_block, first_demand_block]
          expect(assigns(:demands_count)).to eq 1
          expect(assigns(:demand_blocks_ids)).to match_array [first_demand_block.id, second_demand_block.id, third_demand_block.id, fourth_demand_block.id]
          expect(assigns(:paged_demand_blocks)).to eq [second_demand_block, first_demand_block]
          expect(response).to render_template 'demand_blocks/index'
        end
      end

      context 'passing invalid' do
        let(:project) { Fabricate :project, customers: [customer], status: :executing }

        context 'company' do
          before { get :index, params: { company_id: 'foo', project_id: project } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #demand_blocks_csv' do
      let(:company) { Fabricate :company, users: [user] }

      let(:project) { Fabricate :project, company: company, start_date: 2.days.ago, end_date: Time.zone.today }
      let!(:demand) { Fabricate :demand, project: project, company: company, end_date: Time.zone.now }

      context 'valid parameters' do
        it 'calls the to_csv and responds success' do
          travel_to Time.zone.local(2021, 5, 26, 10, 0) do
            allow(UserPlan).to(receive(:valid_plans)).and_return([user_plan])
            demand_block = Fabricate :demand_block, demand: demand, block_time: 1.day.ago, unblock_time: nil
            get :demand_blocks_csv, params: { company_id: company, demand_blocks_ids: [demand_block.id].join(',') }, format: :csv
            expect(response).to have_http_status :ok

            csv = CSV.parse(response.body, headers: true)
            expect(csv.count).to eq 1
            expect(csv.first[0].to_i).to eq demand_block.id
            expect(csv.first[1]).to eq demand_block.block_time&.iso8601
            expect(csv.first[2]).to eq demand_block.unblock_time&.iso8601
            expect(csv.first[3].to_i).to eq 7
            expect(csv.first[4]).to eq demand.external_id
          end
        end
      end

      context 'invalid' do
        context 'company' do
          context 'non-existent' do
            before { get :demand_blocks_csv, params: { company_id: 'foo', projects_ids: [project.id].join(',') }, format: :csv }

            it { expect(response).to have_http_status :not_found }
          end

          context 'not-permitted' do
            let(:company) { Fabricate :company, users: [] }

            before { get :demand_blocks_csv, params: { company_id: company, projects_ids: [project.id].join(',') }, format: :csv }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'POST #search' do
      let(:company) { Fabricate :company, users: [user] }
      let(:other_company) { Fabricate :company }

      let(:customer) { Fabricate :customer, company: company }

      let(:stage) { Fabricate :stage, company: company, name: 'zzz' }
      let(:other_stage) { Fabricate :stage, company: company, name: 'aaa' }

      let!(:first_project) { Fabricate :project, customers: [customer], stages: [stage, other_stage], status: :executing, start_date: 6.days.ago, end_date: Time.zone.today }
      let!(:second_project) { Fabricate :project, customers: [customer], stages: [stage, other_stage], status: :executing, start_date: 6.days.ago, end_date: Time.zone.today }
      let!(:third_project) { Fabricate :project, customers: [customer], stages: [stage, other_stage], status: :finished, start_date: 6.days.ago, end_date: Time.zone.today }
      let!(:other_company_project) { Fabricate :project, company: other_company, status: :executing, start_date: 6.days.ago, end_date: Time.zone.today }

      context 'with data' do
        context 'and valid parameters' do
          context 'no filters are provided' do
            it 'builds the statistic adapter and renders the view using the dates in project to a monthly period' do
              travel_to Time.zone.local(2020, 12, 2, 10, 0, 0) do
                first_demand = Fabricate :demand, project: first_project, company: company
                second_demand = Fabricate :demand, project: second_project, company: company
                third_demand = Fabricate :demand, project: third_project, company: company
                other_company_demand = Fabricate :demand, project: other_company_project, company: other_company

                Fabricate :demand_transition, demand: first_demand, stage: stage, last_time_in: 7.days.ago, last_time_out: 3.days.ago
                Fabricate :demand_transition, demand: first_demand, stage: other_stage, last_time_in: 2.days.ago, last_time_out: Time.zone.now

                team_member = Fabricate :team_member, company: company, name: 'zzz'
                other_team_member = Fabricate :team_member, company: company, name: 'aaa'

                first_block = Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'first_block', block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true
                second_block = Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: other_team_member, block_reason: 'second_block', block_time: 3.days.ago, unblock_time: 2.days.ago, active: true
                third_block = Fabricate :demand_block, demand: second_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'third_block', block_time: 5.days.ago, unblock_time: 4.days.ago, active: true
                fourth_block = Fabricate :demand_block, demand: first_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'fourth_block', block_time: 4.days.ago, unblock_time: Time.zone.yesterday, active: true
                fifth_block = Fabricate :demand_block, demand: first_demand, block_type: :waiting_external_supplier, blocker: other_team_member, unblocker: team_member, block_reason: 'fifth_block', block_time: 5.days.ago, unblock_time: 3.days.ago, active: true
                sixth_block = Fabricate :demand_block, demand: second_demand, block_type: :waiting_external_supplier, blocker: team_member, unblocker: team_member, block_reason: 'sixth_block', block_time: 6.days.ago, unblock_time: 5.days.ago, active: true
                seventh_block = Fabricate :demand_block, demand: second_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'seventh_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: Time.zone.today
                Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'eigth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
                Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'ninth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
                Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'tenth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: false, discarded_at: nil

                Fabricate :demand_block, demand: other_company_demand, block_type: :coding_needed, block_reason: 'first_block', block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true

                post :search, params: { company_id: company, demand_blocks_ids: DemandBlock.all.map(&:id).join(',') }
                expect(response).to render_template 'demand_blocks/index'
                expect(assigns(:demand_blocks)).to eq [first_block, second_block, fourth_block, third_block, fifth_block, sixth_block, seventh_block]
                expect(assigns(:demands_count)).to eq 2
              end
            end
          end

          context 'and a filter by start and end dates are provided' do
            it 'builds the block list and renders the template' do
              first_demand = Fabricate :demand, project: first_project, company: company
              second_demand = Fabricate :demand, project: second_project, company: company
              third_demand = Fabricate :demand, project: third_project, company: company
              other_company_demand = Fabricate :demand, project: other_company_project, company: other_company

              Fabricate :demand_transition, demand: first_demand, stage: stage, last_time_in: 7.days.ago, last_time_out: 3.days.ago
              Fabricate :demand_transition, demand: first_demand, stage: other_stage, last_time_in: 2.days.ago, last_time_out: Time.zone.now

              team_member = Fabricate :team_member, company: company, name: 'zzz'
              other_team_member = Fabricate :team_member, company: company, name: 'aaa'

              first_block = Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'first_block', block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true
              second_block = Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: other_team_member, block_reason: 'second_block', block_time: 3.days.ago, unblock_time: 2.days.ago, active: true
              third_block = Fabricate :demand_block, demand: first_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'fourth_block', block_time: 4.days.ago, unblock_time: Time.zone.yesterday, active: true
              Fabricate :demand_block, demand: second_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'third_block', block_time: 5.days.ago, unblock_time: 4.days.ago, active: true
              Fabricate :demand_block, demand: first_demand, block_type: :waiting_external_supplier, blocker: other_team_member, unblocker: team_member, block_reason: 'fifth_block', block_time: 5.days.ago, unblock_time: 3.days.ago, active: true
              Fabricate :demand_block, demand: second_demand, block_type: :waiting_external_supplier, blocker: team_member, unblocker: team_member, block_reason: 'sixth_block', block_time: 6.days.ago, unblock_time: 5.days.ago, active: true
              Fabricate :demand_block, demand: second_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'seventh_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: Time.zone.today
              Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'eigth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
              Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'ninth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
              Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'tenth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: false, discarded_at: nil

              Fabricate :demand_block, demand: other_company_demand, block_type: :coding_needed, block_reason: 'first_block', block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true

              post :search, params: { company_id: company, demand_blocks_ids: DemandBlock.all.map(&:id).join(','), blocks_start_date: 2.days.ago.to_date, blocks_end_date: Time.zone.today }
              expect(response).to render_template 'demand_blocks/index'
              expect(assigns(:demand_blocks)).to eq [first_block, second_block, third_block]
              expect(assigns(:demands_count)).to eq 1
            end
          end

          context 'and a filter by type was provided' do
            it 'builds the block list and renders the template' do
              first_demand = Fabricate :demand, project: first_project, company: company
              second_demand = Fabricate :demand, project: second_project, company: company
              third_demand = Fabricate :demand, project: third_project, company: company
              other_company_demand = Fabricate :demand, project: other_company_project, company: other_company

              Fabricate :demand_transition, demand: first_demand, stage: stage, last_time_in: 7.days.ago, last_time_out: 3.days.ago
              Fabricate :demand_transition, demand: first_demand, stage: other_stage, last_time_in: 2.days.ago, last_time_out: Time.zone.now

              team_member = Fabricate :team_member, company: company, name: 'zzz'
              other_team_member = Fabricate :team_member, company: company, name: 'aaa'

              first_block = Fabricate :demand_block, demand: second_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'first_block', block_time: 5.days.ago, unblock_time: 4.days.ago, active: true
              second_block = Fabricate :demand_block, demand: first_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'second_block', block_time: 4.days.ago, unblock_time: Time.zone.yesterday, active: true
              Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true
              Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: other_team_member, block_time: 3.days.ago, unblock_time: 2.days.ago, active: true
              Fabricate :demand_block, demand: first_demand, block_type: :waiting_external_supplier, blocker: other_team_member, unblocker: team_member, block_time: 5.days.ago, unblock_time: 3.days.ago, active: true
              Fabricate :demand_block, demand: second_demand, block_type: :waiting_external_supplier, blocker: team_member, unblocker: team_member, block_time: 6.days.ago, unblock_time: 5.days.ago, active: true
              Fabricate :demand_block, demand: second_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: Time.zone.today
              Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
              Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
              Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_time: 7.days.ago, unblock_time: 6.days.ago, active: false, discarded_at: nil

              Fabricate :demand_block, demand: other_company_demand, block_type: :coding_needed, block_reason: 'first_block', block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true

              post :search, params: { company_id: company, demand_blocks_ids: DemandBlock.all.map(&:id).join(','), blocks_type: 1 }
              expect(response).to render_template 'demand_blocks/index'
              expect(assigns(:demand_blocks)).to eq [second_block, first_block]
              expect(assigns(:demands_count)).to eq 2
            end
          end

          context 'and a filter by team member was provided' do
            it 'builds the block list and render the template' do
              travel_to Time.zone.local(2020, 12, 2, 10, 0, 0) do
                first_demand = Fabricate :demand, project: first_project, company: company
                second_demand = Fabricate :demand, project: second_project, company: company
                third_demand = Fabricate :demand, project: third_project, company: company
                other_company_demand = Fabricate :demand, project: other_company_project, company: other_company

                Fabricate :demand_transition, demand: first_demand, stage: stage, last_time_in: 7.days.ago, last_time_out: 3.days.ago
                Fabricate :demand_transition, demand: first_demand, stage: other_stage, last_time_in: 2.days.ago, last_time_out: Time.zone.now

                team_member = Fabricate :team_member, company: company, name: 'zzz'
                other_team_member = Fabricate :team_member, company: company, name: 'aaa'

                Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'first_block', block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true
                second_block = Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: other_team_member, block_reason: 'second_block', block_time: 3.days.ago, unblock_time: 2.days.ago, active: true
                third_block = Fabricate :demand_block, demand: second_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'third_block', block_time: 5.days.ago, unblock_time: 4.days.ago, active: true
                fourth_block = Fabricate :demand_block, demand: first_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'fourth_block', block_time: 4.days.ago, unblock_time: Time.zone.yesterday, active: true
                Fabricate :demand_block, demand: first_demand, block_type: :waiting_external_supplier, blocker: other_team_member, unblocker: team_member, block_reason: 'fifth_block', block_time: 5.days.ago, unblock_time: 3.days.ago, active: true
                Fabricate :demand_block, demand: second_demand, block_type: :waiting_external_supplier, blocker: team_member, unblocker: team_member, block_reason: 'sixth_block', block_time: 6.days.ago, unblock_time: 5.days.ago, active: true
                Fabricate :demand_block, demand: second_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'seventh_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: Time.zone.today
                Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'eigth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
                Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'ninth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
                Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'tenth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: false, discarded_at: nil

                Fabricate :demand_block, demand: other_company_demand, block_type: :coding_needed, block_reason: 'first_block', block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true

                post :search, params: { company_id: company, demand_blocks_ids: DemandBlock.all.map(&:id).join(','), blocks_team_member: other_team_member.id }
                expect(response).to render_template 'demand_blocks/index'
                expect(assigns(:demand_blocks)).to eq [second_block, fourth_block, third_block]
                expect(assigns(:demands_count)).to eq 2
              end
            end
          end

          context 'and a filter by stage was provided' do
            it 'builds the block list and renders the template' do
              first_demand = Fabricate :demand, project: first_project, company: company
              second_demand = Fabricate :demand, project: second_project, company: company
              third_demand = Fabricate :demand, project: third_project, company: company
              other_company_demand = Fabricate :demand, project: other_company_project, company: other_company

              Fabricate :demand_transition, demand: first_demand, stage: stage, last_time_in: 7.days.ago, last_time_out: 3.days.ago
              Fabricate :demand_transition, demand: first_demand, stage: other_stage, last_time_in: 2.days.ago, last_time_out: Time.zone.now

              team_member = Fabricate :team_member, company: company, name: 'zzz'
              other_team_member = Fabricate :team_member, company: company, name: 'aaa'

              Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'first_block', block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true
              Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: other_team_member, block_reason: 'second_block', block_time: 3.days.ago, unblock_time: 2.days.ago, active: true
              Fabricate :demand_block, demand: second_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'third_block', block_time: 5.days.ago, unblock_time: 4.days.ago, active: true
              fourth_block = Fabricate :demand_block, demand: first_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'fourth_block', block_time: 4.days.ago, unblock_time: Time.zone.yesterday, active: true
              fifth_block = Fabricate :demand_block, demand: first_demand, block_type: :waiting_external_supplier, blocker: other_team_member, unblocker: team_member, block_reason: 'fifth_block', block_time: 5.days.ago, unblock_time: 3.days.ago, active: true
              Fabricate :demand_block, demand: second_demand, block_type: :waiting_external_supplier, blocker: team_member, unblocker: team_member, block_reason: 'sixth_block', block_time: 6.days.ago, unblock_time: 5.days.ago, active: true
              Fabricate :demand_block, demand: second_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'seventh_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: Time.zone.today
              Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'eigth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
              Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'ninth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
              Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'tenth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: false, discarded_at: nil

              Fabricate :demand_block, demand: other_company_demand, block_type: :coding_needed, block_reason: 'first_block', block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true

              post :search, params: { company_id: company, demand_blocks_ids: DemandBlock.all.map(&:id).join(','), blocks_stage: stage.id }
              expect(response).to render_template 'demand_blocks/index'
              expect(assigns(:demand_blocks)).to eq [fourth_block, fifth_block]
              expect(assigns(:demands_count)).to eq 1
            end
          end

          context 'and a filter by project was provided' do
            it 'builds the block list and renders the template' do
              first_demand = Fabricate :demand, project: first_project, company: company
              second_demand = Fabricate :demand, project: second_project, company: company
              third_demand = Fabricate :demand, project: third_project, company: company
              other_company_demand = Fabricate :demand, project: other_company_project, company: other_company

              Fabricate :demand_transition, demand: first_demand, stage: stage, last_time_in: 7.days.ago, last_time_out: 3.days.ago
              Fabricate :demand_transition, demand: first_demand, stage: other_stage, last_time_in: 2.days.ago, last_time_out: Time.zone.now

              team_member = Fabricate :team_member, company: company, name: 'zzz'
              other_team_member = Fabricate :team_member, company: company, name: 'aaa'

              first_block = Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'first_block', block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true
              second_block = Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: other_team_member, block_reason: 'second_block', block_time: 3.days.ago, unblock_time: 2.days.ago, active: true
              Fabricate :demand_block, demand: second_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'third_block', block_time: 5.days.ago, unblock_time: 4.days.ago, active: true
              fourth_block = Fabricate :demand_block, demand: first_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'fourth_block', block_time: 4.days.ago, unblock_time: Time.zone.yesterday, active: true
              fifth_block = Fabricate :demand_block, demand: first_demand, block_type: :waiting_external_supplier, blocker: other_team_member, unblocker: team_member, block_reason: 'fifth_block', block_time: 5.days.ago, unblock_time: 3.days.ago, active: true
              Fabricate :demand_block, demand: second_demand, block_type: :waiting_external_supplier, blocker: team_member, unblocker: team_member, block_reason: 'sixth_block', block_time: 6.days.ago, unblock_time: 5.days.ago, active: true
              Fabricate :demand_block, demand: second_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'seventh_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: Time.zone.today
              Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'eigth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
              Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'ninth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
              Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'tenth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: false, discarded_at: nil

              Fabricate :demand_block, demand: other_company_demand, block_type: :coding_needed, block_reason: 'first_block', block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true

              post :search, params: { company_id: company, demand_blocks_ids: DemandBlock.all.map(&:id).join(','), blocks_project: first_project.id }
              expect(response).to render_template 'demand_blocks/index'
              expect(assigns(:demand_blocks)).to eq [first_block, second_block, fourth_block, fifth_block]
              expect(assigns(:demands_count)).to eq 1
            end
          end

          context 'and a filter by finished projects was provided' do
            it 'builds the block list and renders the template' do
              first_demand = Fabricate :demand, project: first_project, company: company
              second_demand = Fabricate :demand, project: second_project, company: company
              third_demand = Fabricate :demand, project: third_project, company: company
              other_company_demand = Fabricate :demand, project: other_company_project, company: other_company

              Fabricate :demand_transition, demand: first_demand, stage: stage, last_time_in: 7.days.ago, last_time_out: 3.days.ago
              Fabricate :demand_transition, demand: first_demand, stage: other_stage, last_time_in: 2.days.ago, last_time_out: Time.zone.now

              team_member = Fabricate :team_member, company: company, name: 'zzz'
              other_team_member = Fabricate :team_member, company: company, name: 'aaa'

              Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'first_block', block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true
              Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: other_team_member, block_reason: 'second_block', block_time: 3.days.ago, unblock_time: 2.days.ago, active: true
              Fabricate :demand_block, demand: second_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'third_block', block_time: 5.days.ago, unblock_time: 4.days.ago, active: true
              Fabricate :demand_block, demand: first_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'fourth_block', block_time: 4.days.ago, unblock_time: Time.zone.yesterday, active: true
              Fabricate :demand_block, demand: first_demand, block_type: :waiting_external_supplier, blocker: other_team_member, unblocker: team_member, block_reason: 'fifth_block', block_time: 5.days.ago, unblock_time: 3.days.ago, active: true
              Fabricate :demand_block, demand: second_demand, block_type: :waiting_external_supplier, blocker: team_member, unblocker: team_member, block_reason: 'sixth_block', block_time: 6.days.ago, unblock_time: 5.days.ago, active: true
              Fabricate :demand_block, demand: second_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'seventh_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: Time.zone.today
              eigth_block = Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'eigth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
              ninth_block = Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'ninth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
              Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'tenth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: false, discarded_at: nil

              Fabricate :demand_block, demand: other_company_demand, block_type: :coding_needed, block_reason: 'first_block', block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true

              post :search, params: { company_id: company, demand_blocks_ids: DemandBlock.all.map(&:id).join(','), finished_projects: true }
              expect(response).to render_template 'demand_blocks/index'
              expect(assigns(:demand_blocks)).to match_array [eigth_block, ninth_block]
              expect(assigns(:demands_count)).to eq 1
            end
          end

          context 'and a filter by inactive blocks was provided' do
            it 'builds the block list and renders the template' do
              first_demand = Fabricate :demand, project: first_project, company: company
              second_demand = Fabricate :demand, project: second_project, company: company
              third_demand = Fabricate :demand, project: third_project, company: company
              other_company_demand = Fabricate :demand, project: other_company_project, company: other_company

              Fabricate :demand_transition, demand: first_demand, stage: stage, last_time_in: 7.days.ago, last_time_out: 3.days.ago
              Fabricate :demand_transition, demand: first_demand, stage: other_stage, last_time_in: 2.days.ago, last_time_out: Time.zone.now

              team_member = Fabricate :team_member, company: company, name: 'zzz'
              other_team_member = Fabricate :team_member, company: company, name: 'aaa'

              Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'first_block', block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true
              Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: other_team_member, block_reason: 'second_block', block_time: 3.days.ago, unblock_time: 2.days.ago, active: true
              Fabricate :demand_block, demand: second_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'third_block', block_time: 5.days.ago, unblock_time: 4.days.ago, active: true
              Fabricate :demand_block, demand: first_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'fourth_block', block_time: 4.days.ago, unblock_time: Time.zone.yesterday, active: true
              Fabricate :demand_block, demand: first_demand, block_type: :waiting_external_supplier, blocker: other_team_member, unblocker: team_member, block_reason: 'fifth_block', block_time: 5.days.ago, unblock_time: 3.days.ago, active: true
              Fabricate :demand_block, demand: second_demand, block_type: :waiting_external_supplier, blocker: team_member, unblocker: team_member, block_reason: 'sixth_block', block_time: 6.days.ago, unblock_time: 5.days.ago, active: true
              Fabricate :demand_block, demand: second_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'seventh_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: Time.zone.today
              Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'eigth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
              Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'ninth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
              tenth_block = Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'tenth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: false, discarded_at: nil

              Fabricate :demand_block, demand: other_company_demand, block_type: :coding_needed, block_reason: 'first_block', block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true

              post :search, params: { company_id: company, demand_blocks_ids: DemandBlock.all.map(&:id).join(','), inactive_blocks: 'yes' }
              expect(assigns(:demand_blocks)).to eq [tenth_block]
              expect(response).to render_template 'demand_blocks/index'
              expect(assigns(:demands_count)).to eq 1
            end
          end

          context 'and all filters are provided' do
            it 'builds the block list and renders the template' do
              first_demand = Fabricate :demand, project: first_project, company: company
              second_demand = Fabricate :demand, project: second_project, company: company
              third_demand = Fabricate :demand, project: third_project, company: company
              other_company_demand = Fabricate :demand, project: other_company_project, company: other_company

              Fabricate :demand_transition, demand: first_demand, stage: stage, last_time_in: 7.days.ago, last_time_out: 3.days.ago
              Fabricate :demand_transition, demand: first_demand, stage: other_stage, last_time_in: 2.days.ago, last_time_out: Time.zone.now

              team_member = Fabricate :team_member, company: company, name: 'zzz'
              other_team_member = Fabricate :team_member, company: company, name: 'aaa'

              Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'first_block', block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true
              Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: other_team_member, block_reason: 'second_block', block_time: 3.days.ago, unblock_time: 2.days.ago, active: true
              Fabricate :demand_block, demand: second_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'third_block', block_time: 5.days.ago, unblock_time: 4.days.ago, active: true
              fourth_block = Fabricate :demand_block, demand: first_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'fourth_block', block_time: 4.days.ago, unblock_time: Time.zone.yesterday, active: true
              Fabricate :demand_block, demand: first_demand, block_type: :waiting_external_supplier, blocker: other_team_member, unblocker: team_member, block_reason: 'fifth_block', block_time: 5.days.ago, unblock_time: 3.days.ago, active: true
              Fabricate :demand_block, demand: second_demand, block_type: :waiting_external_supplier, blocker: team_member, unblocker: team_member, block_reason: 'sixth_block', block_time: 6.days.ago, unblock_time: 5.days.ago, active: true
              Fabricate :demand_block, demand: second_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'seventh_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: Time.zone.today
              Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'eigth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
              Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'ninth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
              Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'tenth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: false, discarded_at: nil

              Fabricate :demand_block, demand: other_company_demand, block_type: :coding_needed, block_reason: 'first_block', block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true

              post :search, params: { company_id: company, demand_blocks_ids: DemandBlock.all.map(&:id).join(','), blocks_stage: stage.id, blocks_team_member: other_team_member.id, blocks_start_date: 2.days.ago, blocks_end_date: Time.zone.today }
              expect(response).to render_template 'demand_blocks/index'
              expect(assigns(:demand_blocks)).to eq [fourth_block]
              expect(assigns(:demands_count)).to eq 1
            end
          end

          context 'and an ordering by blocker is requested' do
            it 'builds the block list and renders the template' do
              travel_to Time.zone.local(2020, 12, 2, 10, 0, 0) do
                first_demand = Fabricate :demand, project: first_project, company: company
                second_demand = Fabricate :demand, project: second_project, company: company
                third_demand = Fabricate :demand, project: third_project, company: company
                other_company_demand = Fabricate :demand, project: other_company_project, company: other_company

                Fabricate :demand_transition, demand: first_demand, stage: stage, last_time_in: 7.days.ago, last_time_out: 3.days.ago
                Fabricate :demand_transition, demand: first_demand, stage: other_stage, last_time_in: 2.days.ago, last_time_out: Time.zone.now

                team_member = Fabricate :team_member, company: company, name: 'zzz'
                other_team_member = Fabricate :team_member, company: company, name: 'aaa'

                Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'first_block', block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true
                second_block = Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: other_team_member, block_reason: 'second_block', block_time: 3.days.ago, unblock_time: 2.days.ago, active: true
                third_block = Fabricate :demand_block, demand: second_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'third_block', block_time: 5.days.ago, unblock_time: 4.days.ago, active: true
                fourth_block = Fabricate :demand_block, demand: first_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'fourth_block', block_time: 4.days.ago, unblock_time: Time.zone.yesterday, active: true
                Fabricate :demand_block, demand: first_demand, block_type: :waiting_external_supplier, blocker: other_team_member, unblocker: team_member, block_reason: 'fifth_block', block_time: 5.days.ago, unblock_time: 3.days.ago, active: true
                Fabricate :demand_block, demand: second_demand, block_type: :waiting_external_supplier, blocker: team_member, unblocker: team_member, block_reason: 'sixth_block', block_time: 6.days.ago, unblock_time: 5.days.ago, active: true
                Fabricate :demand_block, demand: second_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'seventh_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: Time.zone.today
                Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'eigth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
                Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'ninth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
                Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'tenth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: false, discarded_at: nil

                Fabricate :demand_block, demand: other_company_demand, block_type: :coding_needed, block_reason: 'first_block', block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true

                post :search, params: { company_id: company, demand_blocks_ids: DemandBlock.all.map(&:id).join(','), blocks_team_member: other_team_member.id, blocks_ordering: :member_name }
                expect(response).to have_http_status :ok
                expect(assigns(:demand_blocks)).to match_array [second_block, third_block, fourth_block]
                expect(response).to render_template 'demand_blocks/index'
              end
            end
          end

          context 'if an ordering by block time was requested' do
            it 'builds the block list and render the template' do
              travel_to Time.zone.local(2020, 12, 2, 10, 0, 0) do
                first_demand = Fabricate :demand, project: first_project, company: company
                second_demand = Fabricate :demand, project: second_project, company: company
                third_demand = Fabricate :demand, project: third_project, company: company
                other_company_demand = Fabricate :demand, project: other_company_project, company: other_company

                team_member = Fabricate :team_member, company: company, name: 'zzz'
                other_team_member = Fabricate :team_member, company: company, name: 'aaa'

                Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'first_block', block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true
                second_block = Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: other_team_member, block_reason: 'second_block', block_time: 3.days.ago, unblock_time: 2.days.ago, active: true
                third_block = Fabricate :demand_block, demand: second_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'third_block', block_time: 5.days.ago, unblock_time: 4.days.ago, active: true
                fourth_block = Fabricate :demand_block, demand: first_demand, block_type: :specification_needed, blocker: other_team_member, unblocker: other_team_member, block_reason: 'fourth_block', block_time: 4.days.ago, unblock_time: Time.zone.yesterday, active: true
                Fabricate :demand_block, demand: first_demand, block_type: :waiting_external_supplier, blocker: other_team_member, unblocker: team_member, block_reason: 'fifth_block', block_time: 5.days.ago, unblock_time: 3.days.ago, active: true
                Fabricate :demand_block, demand: second_demand, block_type: :waiting_external_supplier, blocker: team_member, unblocker: team_member, block_reason: 'sixth_block', block_time: 6.days.ago, unblock_time: 5.days.ago, active: true
                Fabricate :demand_block, demand: second_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'seventh_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: Time.zone.today
                Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'eigth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
                Fabricate :demand_block, demand: third_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'ninth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: true, discarded_at: nil
                Fabricate :demand_block, demand: first_demand, block_type: :coding_needed, blocker: team_member, unblocker: team_member, block_reason: 'tenth_block', block_time: 7.days.ago, unblock_time: 6.days.ago, active: false, discarded_at: nil

                Fabricate :demand_block, demand: other_company_demand, block_type: :coding_needed, block_reason: 'first_block', block_time: 1.hour.ago, unblock_time: Time.zone.today, active: true

                post :search, params: { company_id: company, demand_blocks_ids: DemandBlock.all.map(&:id).join(','), blocks_team_member: other_team_member.id, blocks_ordering: :block_time }
                expect(response).to have_http_status :ok
                expect(assigns(:demand_blocks)).to eq [second_block, fourth_block, third_block]
                expect(response).to render_template 'demand_blocks/index'
              end
            end
          end
        end
      end

      context 'with no data' do
        it 'render the template with empty data' do
          post :search, params: { company_id: company, demand_blocks_ids: DemandBlock.all.map(&:id).join(','), blocks_start_date: 2.days.ago, blocks_end_date: Time.zone.today }
          expect(assigns(:demand_blocks)).to eq []
          expect(response).to render_template 'demand_blocks/index'
        end
      end
    end
  end
end
