# frozen_string_literal: true

RSpec.describe DateHelper, type: :helper do
  describe '#time_distance_in_words' do
    context 'less than a day' do
      it { expect(helper.time_distance_in_words(5000)).to eq "1 #{I18n.t('datetime.date_attributes.hour', count: 1)}" }
    end

    context 'less than an hour' do
      it { expect(helper.time_distance_in_words(500)).to eq "8 #{I18n.t('datetime.date_attributes.minute', count: 8)}" }
    end

    context 'less than a minute' do
      it { expect(helper.time_distance_in_words(59)).to eq "59 #{I18n.t('datetime.date_attributes.second', count: 59)}" }
    end

    context 'greather than a day' do
      it { expect(helper.time_distance_in_words(300_000)).to eq "3 #{I18n.t('datetime.date_attributes.day', count: 3)} #{I18n.t('geenral.connector.and')} 11 #{I18n.t('datetime.date_attributes.hour', count: 11)}" }
    end
  end

  describe '#seconds_to_day' do
    context 'less than a day' do
      it { expect(helper.seconds_to_day(5000)).to eq 0.05787037037037037 }
    end

    context 'greather than a day' do
      it { expect(helper.seconds_to_day(300_000)).to eq 3.4722222222222223 }
    end
  end
end
