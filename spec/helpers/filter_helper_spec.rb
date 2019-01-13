# frozen_string_literal: true

RSpec.describe FilterHelper, type: :helper do
  describe '#period_options' do
    it { expect(helper.period_options).to eq options_for_select([[I18n.t('general.filter.period.option.last_month'), 'month'], [I18n.t('general.filter.period.option.last_quarter'), 'quarter'], [I18n.t('general.filter.period.option.all_period'), 'all']], :month) }
  end
end
