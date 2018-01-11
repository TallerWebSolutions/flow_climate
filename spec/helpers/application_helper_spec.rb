# frozen_string_literal: true

RSpec.describe ApplicationController, type: :controller do
  describe '#record_not_found' do
    controller do
      def inexistent_model
        raise ActiveRecord::RecordNotFound
      end
    end

    it 'responds to html' do
      routes.draw { get 'inexistent_model' => 'anonymous#inexistent_model' }

      get :inexistent_model
      expect(response.status).to eq 404
      expect(response.body).to include "The page you were looking for doesn't exist (404)"
    end

    it 'responds to ajax' do
      routes.draw { get 'inexistent_model' => 'anonymous#inexistent_model' }

      get :inexistent_model, xhr: true, format: :js
      expect(response.status).to eq 404
      expect(response.body).to eq('404 Not Found')
    end
  end
end
