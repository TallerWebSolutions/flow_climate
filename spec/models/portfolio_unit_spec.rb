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
    it { expect(child_portfolio_unit.parent_branches).to eq [portfolio_unit] }
    it { expect(other_child_portfolio_unit.parent_branches).to eq [portfolio_unit] }
    it { expect(granchild_portfolio_unit.parent_branches).to eq [child_portfolio_unit, portfolio_unit] }
    it { expect(great_granchild_portfolio_unit.parent_branches).to eq [granchild_portfolio_unit, child_portfolio_unit, portfolio_unit] }
  end

  describe '#total_portfolio_demands' do
    let(:portfolio_unit) { Fabricate :portfolio_unit }
    let(:child_portfolio_unit) { Fabricate :portfolio_unit, parent: portfolio_unit }
    let(:other_child_portfolio_unit) { Fabricate :portfolio_unit, parent: portfolio_unit }

    let!(:portfolio_unit_demands) { Fabricate.times(5, :demand, portfolio_unit: portfolio_unit) }
    let!(:child_portfolio_unit_demands) { Fabricate.times(7, :demand, portfolio_unit: child_portfolio_unit) }
    let!(:other_child_portfolio_unit_demands) { Fabricate.times(3, :demand, portfolio_unit: other_child_portfolio_unit) }

    it { expect(portfolio_unit.total_portfolio_demands.map(&:id)).to match_array Demand.all.map(&:id) }
    it { expect(child_portfolio_unit.total_portfolio_demands.map(&:id)).to match_array child_portfolio_unit_demands.map(&:id) }
    it { expect(other_child_portfolio_unit.total_portfolio_demands.map(&:id)).to match_array other_child_portfolio_unit_demands.map(&:id) }
  end

  describe '#percentage_complete' do
    let(:portfolio_unit) { Fabricate :portfolio_unit }
    let(:child_portfolio_unit) { Fabricate :portfolio_unit, parent: portfolio_unit }
    let(:other_child_portfolio_unit) { Fabricate :portfolio_unit, parent: portfolio_unit }

    context 'with no demands' do
      it { expect(portfolio_unit.percentage_complete).to eq 0 }
    end

    context 'with demands' do
      let!(:portfolio_unit_demands) { Fabricate.times(5, :demand, portfolio_unit: portfolio_unit, end_date: nil) }
      let!(:child_portfolio_unit_demands) { Fabricate.times(7, :demand, portfolio_unit: child_portfolio_unit, end_date: 1.day.from_now) }
      let!(:other_child_portfolio_unit_demands) { Fabricate.times(3, :demand, portfolio_unit: other_child_portfolio_unit, end_date: nil) }

      it { expect(portfolio_unit.percentage_complete).to eq 0.4666666666666667 }
    end
  end

  describe '#total_portfolio_demands' do
    let(:portfolio_unit) { Fabricate :portfolio_unit }
    let(:child_portfolio_unit) { Fabricate :portfolio_unit, parent: portfolio_unit }
    let(:other_child_portfolio_unit) { Fabricate :portfolio_unit, parent: portfolio_unit }

    context 'with no demands' do
      it { expect(other_child_portfolio_unit.total_portfolio_demands).to eq [] }
    end

    context 'with demands' do
      let!(:portfolio_unit_demands) { Fabricate.times(5, :demand, portfolio_unit: portfolio_unit, end_date: nil) }
      let!(:child_portfolio_unit_demands) { Fabricate.times(7, :demand, portfolio_unit: child_portfolio_unit, end_date: 1.day.from_now) }
      let!(:other_child_portfolio_unit_demands) { Fabricate.times(3, :demand, portfolio_unit: other_child_portfolio_unit, end_date: nil) }

      it { expect(other_child_portfolio_unit.total_portfolio_demands).to match_array other_child_portfolio_unit_demands }
      it { expect(child_portfolio_unit.total_portfolio_demands).to match_array child_portfolio_unit_demands }
      it { expect(portfolio_unit.total_portfolio_demands).to match_array Demand.all }
    end
  end

  describe '#total_cost' do
    let(:project) { Fabricate :project, hour_value: 100 }
    let(:portfolio_unit) { Fabricate :portfolio_unit }
    let(:child_portfolio_unit) { Fabricate :portfolio_unit, parent: portfolio_unit }
    let(:other_child_portfolio_unit) { Fabricate :portfolio_unit, parent: portfolio_unit }

    context 'with no demands' do
      it { expect(portfolio_unit.total_cost).to eq 0 }
    end

    context 'with demands' do
      let!(:portfolio_unit_demands) { Fabricate.times(5, :demand, project: project, portfolio_unit: portfolio_unit, end_date: nil, effort_upstream: 100, effort_downstream: 200) }
      let!(:child_portfolio_unit_demands) { Fabricate.times(7, :demand, project: project, portfolio_unit: child_portfolio_unit, end_date: 1.day.from_now, effort_upstream: 300, effort_downstream: 250) }
      let!(:other_child_portfolio_unit_demands) { Fabricate.times(3, :demand, project: project, portfolio_unit: other_child_portfolio_unit, end_date: nil, effort_upstream: 140, effort_downstream: 20) }

      it { expect(portfolio_unit.total_cost).to eq 0.583e6 }
    end
  end

  describe '#total_hours' do
    let(:portfolio_unit) { Fabricate :portfolio_unit }
    let(:child_portfolio_unit) { Fabricate :portfolio_unit, parent: portfolio_unit }
    let(:other_child_portfolio_unit) { Fabricate :portfolio_unit, parent: portfolio_unit }

    context 'with no demands' do
      it { expect(other_child_portfolio_unit.total_hours).to eq 0 }
    end

    context 'with demands' do
      let!(:portfolio_unit_demands) { Fabricate.times(5, :demand, portfolio_unit: portfolio_unit, end_date: nil) }
      let!(:child_portfolio_unit_demands) { Fabricate.times(7, :demand, portfolio_unit: child_portfolio_unit, end_date: 1.day.from_now) }
      let!(:other_child_portfolio_unit_demands) { Fabricate.times(3, :demand, portfolio_unit: other_child_portfolio_unit, end_date: nil) }

      it { expect(other_child_portfolio_unit.total_portfolio_demands).to match_array other_child_portfolio_unit_demands }
      it { expect(child_portfolio_unit.total_portfolio_demands).to match_array child_portfolio_unit_demands }
      it { expect(portfolio_unit.total_hours).to eq 0.135e4 }
    end
  end
end
