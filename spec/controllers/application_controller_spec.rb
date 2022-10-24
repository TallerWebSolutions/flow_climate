# frozen_string_literal: true

RSpec.describe ApplicationController do
  describe '#record_not_found' do
    controller do
      def inexistent_model
        raise ActiveRecord::RecordNotFound
      end
    end

    it 'responds to html' do
      routes.draw { get 'inexistent_model' => 'anonymous#inexistent_model' }

      get :inexistent_model
      expect(response).to have_http_status :not_found
      expect(response.body).to include I18n.t('general.error.not_found.title')
      expect(response.body).to include I18n.t('general.error.not_found.back')
    end

    it 'responds to ajax' do
      routes.draw { get 'inexistent_model' => 'anonymous#inexistent_model' }

      get :inexistent_model, xhr: true, format: :js
      expect(response).to have_http_status :not_found
      expect(response.body).to eq('404 Not Found')
    end
  end

  describe '#set_locale' do
    controller do
      def index
        head :ok, params: { content_type: 'text/html' }
      end
    end

    context 'with no request parameter' do
      context 'with no current_user nor language' do
        it 'uses the en locale' do
          routes.draw { get 'index' => 'anonymous#index' }

          get :index
          expect(I18n.locale).to eq I18n.default_locale
        end
      end

      context 'with current_user and language' do
        let(:user) { Fabricate :user, language: 'en' }

        it 'uses the en locale' do
          routes.draw { get 'index' => 'anonymous#index' }
          sign_in user

          get :index
          expect(I18n.locale).to eq :en
        end
      end
    end

    context 'with pt as browser language' do
      it 'uses the pt locale' do
        routes.draw { get 'index' => 'anonymous#index' }

        request.headers['HTTP_ACCEPT_LANGUAGE'] = 'en-US,en;q=0.9,pt-BR;q=0.8,pt;q=0.7'
        get :index
        expect(I18n.locale).to eq :'pt-BR'
      end
    end

    context 'without pt as browser language' do
      it 'uses the en locale' do
        routes.draw { get 'index' => 'anonymous#index' }

        request.headers['HTTP_ACCEPT_LANGUAGE'] = 'en-US,en;q=0.9'
        get :index
        expect(I18n.locale).to eq :en
      end
    end
  end
end
