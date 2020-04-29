# frozen_string_literal: true

RSpec.describe HomeController, type: :controller do
  context 'unauthenticated' do
    describe 'GET #show' do
      before { get :show }

      it { expect(response).to render_template 'home/show' }
    end
  end
end
