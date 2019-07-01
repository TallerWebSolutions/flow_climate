# frozen_string_literal: true

RSpec.describe PortfolioUnitHelper, type: :helper do
  describe '#period_options' do
    context 'with no argument' do
      it { expect(helper.portfolio_unit_type_options).to eq options_for_select([[I18n.t('activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.product_module'), :product_module], [I18n.t('activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.key_result'), :key_result], [I18n.t('activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.impact'), :impact], [I18n.t('activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.source'), :source]], :product_module) }
    end

    context 'with argument' do
      it { expect(helper.portfolio_unit_type_options(:impact)).to eq options_for_select([[I18n.t('activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.product_module'), :product_module], [I18n.t('activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.key_result'), :key_result], [I18n.t('activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.impact'), :impact], [I18n.t('activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.source'), :source]], :impact) }
    end
  end
end
