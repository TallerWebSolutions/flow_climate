# frozen_string_literal: true

RSpec.describe AuthenticatedController, type: :controller do
  describe '#authenticate_user!' do
    controller do
      def some_action
        render plain: 'success'
      end
    end
    context 'when unauthenticated' do
      it 'redirects to new session path' do
        routes.draw { get 'some_action' => 'authenticated#some_action' }
        get :some_action
        expect(response.status).to eq 302
        expect(response).to redirect_to new_user_session_path
      end
    end

    context 'when authenticated' do
      let(:user) { Fabricate :user }
      before { sign_in user }

      it 'calls the authneticate_user! method' do
        routes.draw { get 'some_action' => 'authenticated#some_action' }
        expect(controller).to receive(:authenticate_user!).once.and_call_original
        get :some_action
        expect(response.status).to eq 200
        expect(response.body).to eq 'success'
      end
    end
  end
end
