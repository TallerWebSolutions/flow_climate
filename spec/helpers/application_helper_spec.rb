# frozen_string_literal: true

RSpec.describe ApplicationHelper, type: :helper do
  include Shoulda::Matchers::ActionController

  describe '#notice' do
    context 'having flash notice' do
      it 'calls the render to the template' do
        flash[:notice] = 'bla'
        expect(helper.notice).to render_template 'layouts/_notice'
      end
    end

    context 'having no flash notice' do
      it 'calls the render to the template' do
        flash[:notice] = nil
        expect(helper.notice).to be_nil
      end
    end
  end

  describe '#alert' do
    context 'having flash notice' do
      it 'calls the render to the template' do
        flash[:alert] = 'bla'
        expect(helper.alert).to render_template 'layouts/_alert'
      end
    end

    context 'having no flash notice' do
      it 'calls the render to the template' do
        flash[:alert] = nil
        expect(helper.alert).to be_nil
      end
    end
  end

  describe '#error' do
    context 'having flash notice' do
      it 'calls the render to the template' do
        flash[:error] = 'bla'
        expect(helper.error).to render_template 'layouts/_error'
      end
    end

    context 'having no flash notice' do
      it 'calls the render to the template' do
        flash[:error] = nil
        expect(helper.error).to be_nil
      end
    end
  end
end
