# frozen-string-literal: true

RSpec.describe ItemAssignmentsController, type: :controller do
  context 'unauthenticated' do
    describe 'DELETE #destroy' do
      before { delete :destroy, params: { company_id: 'bar', demand_id: 'xpto', id: 'foo' }, xhr: true }

      it { expect(response).to have_http_status :unauthorized }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    let(:company) { Fabricate :company, users: [user] }

    before { sign_in user }

    describe 'DELETE #destroy' do
      context 'with valid parameters' do
        let(:demand) { Fabricate :demand, company: company }
        let(:item_assignment) { Fabricate :item_assignment, demand: demand }

        it 'deletes the item assignment and renders the template' do
          delete :destroy, params: { company_id: company.id, demand_id: demand.id, id: item_assignment.id }, xhr: true

          expect(ItemAssignment.where(id: item_assignment.id).count).to eq 0
          expect(response).to render_template 'item_assignments/destroy'
        end
      end

      context 'with invalid' do
        context 'item assignment' do
          let(:demand) { Fabricate :demand, company: company }

          before { delete :destroy, params: { company_id: company, demand_id: demand, id: 'foo' }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'demand' do
          let(:demand) { Fabricate :demand, company: company }
          let(:item_assignment) { Fabricate :item_assignment, demand: demand }

          before { delete :destroy, params: { company_id: company, demand_id: 'foo', id: item_assignment }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end

        context 'not allowed company' do
          let(:company) { Fabricate :company }
          let(:demand) { Fabricate :demand, company: company }
          let(:item_assignment) { Fabricate :item_assignment, demand: demand }

          before { delete :destroy, params: { company_id: company, demand_id: demand, id: item_assignment }, xhr: true }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
