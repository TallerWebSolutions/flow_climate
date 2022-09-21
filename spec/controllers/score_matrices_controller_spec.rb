# frozen_string_literal: true

RSpec.describe ScoreMatricesController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #show' do
      before { get :show, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #customer_dimension' do
      before { get :customer_dimension, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #service_provider_dimension' do
      before { get :service_provider_dimension, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end

    describe 'GET #ordered_demands_list' do
      before { get :ordered_demands_list, params: { company_id: 'bar', id: 'foo' } }

      it { expect(response).to redirect_to new_user_session_path }
    end
  end

  context 'authenticated' do
    let(:user) { Fabricate :user }
    let(:company) { Fabricate :company, users: [user] }

    before { sign_in user }

    describe 'GET #show' do
      let(:product) { Fabricate :product, company: company }
      let!(:score_matrix) { Fabricate :score_matrix, product: product }

      let!(:first_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 20, question_type: :customer_dimension }
      let!(:second_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 10, question_type: :service_provider_dimension }
      let!(:third_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 25, question_type: :customer_dimension }

      let!(:first_demand) { Fabricate :demand, product: product, commitment_date: nil, end_date: nil }
      let!(:second_demand) { Fabricate :demand, product: product, commitment_date: nil, end_date: nil, created_at: 2.minutes.ago }
      let!(:third_demand) { Fabricate :demand, product: product, commitment_date: 3.months.ago, end_date: 2.months.ago }
      let!(:fourth_demand) { Fabricate :demand, product: product, commitment_date: 2.months.ago, end_date: nil }
      let!(:fifth_demand) { Fabricate :demand, product: product, commitment_date: nil, end_date: nil, demand_score: 3 }

      context 'with valid data' do
        context 'when questions_dimension is blank' do
          before { get :show, params: { company_id: company, id: score_matrix } }

          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:score_matrix)).to eq score_matrix
            expect(assigns(:demand_score_matrix)).to be_a_new DemandScoreMatrix
            expect(assigns(:backlog_demands)).to match_array [fifth_demand, second_demand, first_demand]
            expect(assigns(:score_matrix_questions)).to eq [third_question, first_question]
          end
        end

        context 'when questions_dimension is a customer_dimension' do
          before { get :show, params: { company_id: company, id: score_matrix, questions_dimension: :customer_dimension } }

          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:score_matrix_questions)).to eq [third_question, first_question]
          end
        end

        context 'when questions_dimension is a service_provider_dimension' do
          before { get :show, params: { company_id: company, id: score_matrix, questions_dimension: :service_provider_dimension } }

          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:score_matrix_questions)).to eq [second_question]
          end
        end
      end

      context 'with invalid' do
        context 'score matrix' do
          before { get :show, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #ordered_demands_list' do
      let(:product) { Fabricate :product, company: company }
      let!(:score_matrix) { Fabricate :score_matrix, product: product }

      let!(:first_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 20, question_type: :customer_dimension }
      let!(:second_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 10, question_type: :service_provider_dimension }
      let!(:third_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 25, question_type: :customer_dimension }

      let!(:first_demand) { Fabricate :demand, product: product, demand_title: 'first_demand', commitment_date: nil, end_date: nil, demand_score: 3 }
      let!(:second_demand) { Fabricate :demand, product: product, demand_title: 'second_demand', commitment_date: nil, end_date: nil, created_at: 2.minutes.ago, demand_score: 2 }
      let!(:third_demand) { Fabricate :demand, product: product, demand_title: 'third_demand', commitment_date: 3.months.ago, end_date: 2.months.ago, demand_score: 5 }
      let!(:fourth_demand) { Fabricate :demand, product: product, demand_title: 'fourth_demand', commitment_date: 2.months.ago, end_date: nil, demand_score: 4 }
      let!(:fifth_demand) { Fabricate :demand, product: product, demand_title: 'fifth_demand', commitment_date: nil, end_date: nil, demand_score: 2.3 }

      context 'with valid data' do
        context 'when questions_dimension is blank' do
          before { get :ordered_demands_list, params: { company_id: company, id: score_matrix } }

          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template :show
            expect(assigns(:score_matrix)).to eq score_matrix
            expect(assigns(:demand_score_matrix)).to be_a_new DemandScoreMatrix
            expect(assigns(:backlog_demands)).to eq [first_demand, fifth_demand, second_demand]
            expect(assigns(:score_matrix_questions)).to eq [third_question, first_question]
          end
        end

        context 'with invalid' do
          context 'score matrix' do
            before { get :ordered_demands_list, params: { company_id: company, id: 'foo' } }

            it { expect(response).to have_http_status :not_found }
          end
        end
      end
    end

    describe 'GET #customer_dimension' do
      let(:product) { Fabricate :product, company: company }
      let!(:score_matrix) { Fabricate :score_matrix, product: product }

      context 'with valid data' do
        let!(:first_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 20, question_type: :customer_dimension }
        let!(:second_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 10, question_type: :service_provider_dimension }
        let!(:third_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 25, question_type: :customer_dimension }

        context 'with customer dimension' do
          before { get :customer_dimension, params: { company_id: company, id: score_matrix } }

          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template 'score_matrices/show'
            expect(assigns(:score_matrix)).to eq score_matrix
            expect(assigns(:demand_score_matrix)).to be_a_new DemandScoreMatrix
            expect(assigns(:score_matrix_questions)).to eq [third_question, first_question]
          end
        end
      end

      context 'with no data' do
        before { get :customer_dimension, params: { company_id: company, id: score_matrix } }

        it 'assigns the instance variable and renders the template' do
          expect(response).to render_template 'score_matrices/show'
          expect(assigns(:score_matrix)).to eq score_matrix
          expect(assigns(:demand_score_matrix)).to be_a_new DemandScoreMatrix
          expect(assigns(:score_matrix_questions)).to eq []
        end
      end

      context 'with invalid' do
        context 'score matrix' do
          before { get :customer_dimension, params: { company_id: company, id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end

    describe 'GET #service_provider_dimension' do
      let(:product) { Fabricate :product, company: company }
      let!(:score_matrix) { Fabricate :score_matrix, product: product }

      context 'with valid data' do
        let!(:first_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 20, question_type: :customer_dimension }
        let!(:second_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 10, question_type: :service_provider_dimension }
        let!(:third_question) { Fabricate :score_matrix_question, score_matrix: score_matrix, question_weight: 25, question_type: :customer_dimension }

        context 'with customer dimension' do
          before { get :service_provider_dimension, params: { company_id: company, id: score_matrix } }

          it 'assigns the instance variable and renders the template' do
            expect(response).to render_template 'score_matrices/show'
            expect(assigns(:score_matrix)).to eq score_matrix
            expect(assigns(:demand_score_matrix)).to be_a_new DemandScoreMatrix
            expect(assigns(:score_matrix_questions)).to eq [second_question]
          end
        end
      end

      context 'with no data' do
        before { get :service_provider_dimension, params: { company_id: company, id: score_matrix } }

        it 'assigns the instance variable and renders the template' do
          expect(response).to render_template 'score_matrices/show'
          expect(assigns(:score_matrix)).to eq score_matrix
          expect(assigns(:demand_score_matrix)).to be_a_new DemandScoreMatrix
          expect(assigns(:score_matrix_questions)).to eq []
        end
      end

      context 'with invalid' do
        context 'score matrix' do
          before { get :service_provider_dimension, params: { company_id: 'bar', id: 'foo' } }

          it { expect(response).to have_http_status :not_found }
        end
      end
    end
  end
end
