# frozen_string_literal: true

RSpec.describe ApplicationHelper do
  describe '#alert' do
    it 'renders alert partial' do
      flash[:alert] = 'alert message'
      expect(helper.alert).to eq render('layouts/alert', message: flash[:alert])
    end
  end

  describe '#notice' do
    it 'renders notice partial' do
      flash[:notice] = 'notice message'
      expect(helper.notice).to eq render('layouts/notice', message: flash[:notice])
    end
  end

  describe '#error' do
    it 'renders error partial' do
      flash[:error] = 'error message'
      expect(helper.error).to eq render('layouts/error', message: flash[:error])
    end
  end
end
