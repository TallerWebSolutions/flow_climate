# frozen_string_literal: true

RSpec.describe DemandTransitionsController, type: :controller do
  context 'unauthenticated' do
    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'foo', stage_id: 'bar', id: 'sbbrubles' } }
      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    let(:company) { Fabricate :company, users: [user] }
    let(:project) { Fabricate :project }
    let!(:demand) { Fabricate :demand, project: project }
    let!(:stage) { Fabricate :stage, company: company, projects: [project] }

    before { sign_in user }

    describe 'DELETE #destroy' do
      let!(:demand_transition) { Fabricate :demand_transition, demand: demand, stage: stage }

      context 'passing valid IDs' do
        before { delete :destroy, params: { company_id: company, stage_id: stage, id: demand_transition } }
        it 'assigns the instance variable and renders the template' do
          expect(response).to redirect_to company_stage_path(company, stage)
          expect(DemandTransition.last).to be_nil
        end
      end

      context 'passing an invalid ID' do
        context 'non-existent company' do
          before { delete :destroy, params: { company_id: 'foo', stage_id: stage, id: demand_transition } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'non-existent stage' do
          before { delete :destroy, params: { company_id: company, stage_id: 'foo', id: demand_transition } }
          it { expect(response).to have_http_status :not_found }
        end
        context 'not permitted' do
          let(:company) { Fabricate :company, users: [] }

          before { delete :destroy, params: { company_id: company, stage_id: stage, id: demand_transition } }
          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
