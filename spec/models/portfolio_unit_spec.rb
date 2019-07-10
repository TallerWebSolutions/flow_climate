# frozen_string_literal: true

RSpec.describe PortfolioUnit, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:portfolio_unit_type).with_values(product_module: 0, key_result: 1, source: 2, impact: 3, epic: 4) }
  end

  context 'associations' do
    it { is_expected.to belong_to :product }
    it { is_expected.to belong_to(:parent).class_name('PortfolioUnit').inverse_of(:children) }
    it { is_expected.to have_many(:children).class_name('PortfolioUnit').inverse_of(:parent).dependent(:destroy) }
    it { is_expected.to have_many(:demands).dependent(:nullify) }
    it { is_expected.to have_one(:jira_portfolio_unit_config).dependent(:destroy) }
  end

  context 'validations' do
    context 'with simple ones' do
      it { is_expected.to validate_presence_of :product }
      it { is_expected.to validate_presence_of :portfolio_unit_type }
      it { is_expected.to validate_presence_of :name }
    end

    context 'with complex ones' do
      let(:product) { Fabricate :product }
      let!(:first_portfolio_unit) { Fabricate :portfolio_unit, product: product, name: 'aaa' }
      let!(:second_portfolio_unit) { Fabricate.build :portfolio_unit, product: product, name: 'aaa' }

      it 'rejects the one duplicated on name' do
        expect(first_portfolio_unit.valid?).to be true
        expect(second_portfolio_unit.valid?).to be false
        expect(second_portfolio_unit.errors_on(:name)).to eq [I18n.t('portfolio_unit.validations.name')]
      end
    end
  end

  describe '#parent_branches' do
    let(:portfolio_unit) { Fabricate :portfolio_unit, name: 'bla' }
    let(:child_portfolio_unit) { Fabricate :portfolio_unit, parent: portfolio_unit, name: 'foo' }
    let(:granchild_portfolio_unit) { Fabricate :portfolio_unit, parent: child_portfolio_unit, name: 'bar' }
    let(:great_granchild_portfolio_unit) { Fabricate :portfolio_unit, parent: granchild_portfolio_unit, name: 'sbbrubles' }
    let(:other_child_portfolio_unit) { Fabricate :portfolio_unit, parent: portfolio_unit, name: 'xpto' }

    it { expect(portfolio_unit.parent_branches).to eq [] }
    it { expect(child_portfolio_unit.parent_branches).to eq ['bla'] }
    it { expect(other_child_portfolio_unit.parent_branches).to eq ['bla'] }
    it { expect(granchild_portfolio_unit.parent_branches).to eq %w[foo bla] }
    it { expect(great_granchild_portfolio_unit.parent_branches).to eq %w[bar foo bla] }
  end

  describe '#total_demands' do
    let(:portfolio_unit) { Fabricate :portfolio_unit }
    let(:child_portfolio_unit) { Fabricate :portfolio_unit, parent: portfolio_unit }
    let(:other_child_portfolio_unit) { Fabricate :portfolio_unit, parent: portfolio_unit }

    let!(:portfolio_unit_demands) { Fabricate.times(5, :demand, portfolio_unit: portfolio_unit) }
    let!(:child_portfolio_unit_demands) { Fabricate.times(7, :demand, portfolio_unit: child_portfolio_unit) }
    let!(:other_child_portfolio_unit_demands) { Fabricate.times(3, :demand, portfolio_unit: other_child_portfolio_unit) }

    it { expect(portfolio_unit.total_demands.map(&:id)).to match_array Demand.all.map(&:id) }
    it { expect(child_portfolio_unit.total_demands.map(&:id)).to match_array child_portfolio_unit_demands.map(&:id) }
    it { expect(other_child_portfolio_unit.total_demands.map(&:id)).to match_array other_child_portfolio_unit_demands.map(&:id) }
  end
end
