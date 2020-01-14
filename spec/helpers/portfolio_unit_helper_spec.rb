# frozen_string_literal: true

RSpec.describe PortfolioUnitHelper, type: :helper do
  describe '#period_options' do
    context 'with no argument' do
      it { expect(helper.portfolio_unit_type_options).to eq options_for_select([[I18n.t('activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.product_module'), :product_module], [I18n.t('activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.key_result'), :key_result], [I18n.t('activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.source'), :source], [I18n.t('activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.epic'), :epic]], :product_module) }
    end

    context 'with argument' do
      it { expect(helper.portfolio_unit_type_options(:epic)).to eq options_for_select([[I18n.t('activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.product_module'), :product_module], [I18n.t('activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.key_result'), :key_result], [I18n.t('activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.source'), :source], [I18n.t('activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.epic'), :epic]], :epic) }
    end
  end

  describe '#build_portfolio_tree' do
    let(:company) { Fabricate :company, name: 'abc', abbreviation: 'xyz' }
    let(:customer) { Fabricate :customer, company: company }

    context 'with data' do
      subject(:html_output) { helper.build_portfolio_tree(product.portfolio_units.root_units) }

      let(:product) { Fabricate :product, customer: customer }
      let!(:portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'bla' }
      let!(:child_portfolio_unit) { Fabricate :portfolio_unit, product: product, parent: portfolio_unit, name: 'foo' }
      let!(:granchild_portfolio_unit) { Fabricate :portfolio_unit, product: product, parent: child_portfolio_unit, name: 'bar' }
      let!(:great_granchild_portfolio_unit) { Fabricate :portfolio_unit, product: product, parent: granchild_portfolio_unit, name: 'sbbrubles' }
      let!(:other_child_portfolio_unit) { Fabricate :portfolio_unit, product: product, parent: portfolio_unit, name: 'xpto' }

      it { expect(html_output).to include('xpto') }
      it { expect(html_output).to include('sbbrubles') }
      it { expect(html_output).to include('bar') }
      it { expect(html_output).to include('foo') }
      it { expect(html_output).to include('bla') }
      it { expect(html_output).to include('0%') }
      it { expect(html_output).to include(I18n.t("activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.#{portfolio_unit.portfolio_unit_type}")) }
      it { expect(html_output).to include(I18n.t("activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.#{child_portfolio_unit.portfolio_unit_type}")) }
      it { expect(html_output).to include(I18n.t("activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.#{granchild_portfolio_unit.portfolio_unit_type}")) }
      it { expect(html_output).to include(I18n.t("activerecord.attributes.portfolio_unit.enums.portfolio_unit_type.#{other_child_portfolio_unit.portfolio_unit_type}")) }
    end

    context 'with no data' do
      it { expect(helper.build_portfolio_tree([])).to eq '' }
    end
  end
end
