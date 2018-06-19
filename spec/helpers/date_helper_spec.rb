# frozen_string_literal: true

RSpec.describe DateHelper, type: :helper do
  describe '#time_distance_in_words' do
    context 'less than a day' do
      it { expect(helper.time_distance_in_words(5000)).to eq "1 #{I18n.t('datetime.date_attributes.hour', count: 1)}" }
    end

    context 'greather than a day' do
      it { expect(helper.time_distance_in_words(300_000)).to eq "3 #{I18n.t('datetime.date_attributes.day', count: 3)} #{I18n.t('geenral.connector.and')} 11 #{I18n.t('datetime.date_attributes.hour', count: 11)}" }
    end
  end
end
