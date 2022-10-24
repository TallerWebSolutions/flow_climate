# frozen_string_literal: true

RSpec.describe PortfolioUnit do
  context 'enums' do
    it { is_expected.to define_enum_for(:portfolio_unit_type).with_values(product_module: 0, journey_stage: 1, theme: 2, epic: 4) }
  end

  context 'associations' do
    it { is_expected.to belong_to :product }
    it { is_expected.to belong_to(:parent).class_name('PortfolioUnit').inverse_of(:children).optional }
    it { is_expected.to have_many(:children).class_name('PortfolioUnit').inverse_of(:parent).dependent(:destroy) }
    it { is_expected.to have_many(:demands).dependent(:nullify) }
    it { is_expected.to have_one(:jira_portfolio_unit_config).dependent(:destroy) }
  end

  context 'validations' do
    context 'with simple ones' do
      it { is_expected.to validate_presence_of :portfolio_unit_type }
      it { is_expected.to validate_presence_of :name }
    end

    context 'with complex ones' do
      let(:product) { Fabricate :product }

      it 'rejects the one duplicated on name and parent' do
        parent = Fabricate.build :portfolio_unit, product: product, name: 'parent'
        first_portfolio_unit = Fabricate :portfolio_unit, product: product, parent: parent, name: 'aaa'
        second_portfolio_unit = Fabricate.build :portfolio_unit, product: product, name: 'aaa'
        third_portfolio_unit = Fabricate.build :portfolio_unit, product: product, parent: parent, name: 'aaa'

        expect(parent.valid?).to be true
        expect(first_portfolio_unit.valid?).to be true
        expect(second_portfolio_unit.valid?).to be true
        expect(third_portfolio_unit.valid?).to be false
        expect(third_portfolio_unit.errors_on(:name)).to eq [I18n.t('portfolio_unit.validations.name')]
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

  describe '#percentage_complete' do
    let(:portfolio_unit) { Fabricate :portfolio_unit }
    let(:child_portfolio_unit) { Fabricate :portfolio_unit, parent: portfolio_unit }
    let(:other_child_portfolio_unit) { Fabricate :portfolio_unit, parent: portfolio_unit }

    context 'with no demands' do
      it { expect(portfolio_unit.percentage_complete).to eq 0 }
    end

    context 'with demands' do
      it 'returns the percentage complete based on the demands' do
        Fabricate.times(2, :demand, portfolio_unit: other_child_portfolio_unit, end_date: nil, discarded_at: nil)

        Fabricate :demand, portfolio_unit: portfolio_unit, end_date: nil, discarded_at: nil
        Fabricate :demand, portfolio_unit: child_portfolio_unit, end_date: 1.day.ago, discarded_at: nil
        Fabricate :demand, portfolio_unit: portfolio_unit, end_date: nil, discarded_at: 1.day.ago

        expect(portfolio_unit.percentage_complete).to eq 0.25
      end
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

      it { expect(portfolio_unit.total_cost).to eq 583_000 }
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
      it { expect(portfolio_unit.total_hours).to eq 1350 }
    end
  end

  describe '#percentage_concluded' do
    context 'when it has no demands' do
      it 'returns zero' do
        unit = Fabricate :portfolio_unit
        expect(unit.percentage_concluded).to be_zero
      end
    end

    context 'when it has demands' do
      context 'and none concluded' do
        it 'returns zero' do
          unit = Fabricate :portfolio_unit
          Fabricate :demand, portfolio_unit: unit, end_date: nil
          expect(unit.percentage_concluded).to be_zero
        end
      end

      context 'and some are concluded' do
        it 'returns the relation between the numbers' do
          unit = Fabricate :portfolio_unit
          Fabricate :demand, portfolio_unit: unit, end_date: nil
          Fabricate :demand, portfolio_unit: unit, end_date: nil
          Fabricate :demand, portfolio_unit: unit, end_date: nil
          Fabricate :demand, portfolio_unit: unit, end_date: Time.zone.now
          Fabricate :demand, portfolio_unit: unit, end_date: Time.zone.now

          expect(unit.percentage_concluded).to eq 0.4
        end
      end
    end
  end

  describe '#lead_time_p80' do
    context 'with finished demands' do
      it 'returns the lead time for these demands' do
        travel_to Time.zone.local(2022, 8, 5, 17) do
          portfolio_unit = Fabricate :portfolio_unit
          child_portfolio_unit = Fabricate :portfolio_unit, parent: portfolio_unit
          other_child_portfolio_unit = Fabricate :portfolio_unit, parent: portfolio_unit

          Fabricate :demand, portfolio_unit: portfolio_unit, commitment_date: 2.days.ago, end_date: 1.day.ago
          Fabricate :demand, portfolio_unit: child_portfolio_unit, commitment_date: 5.days.ago, end_date: 1.day.ago
          Fabricate :demand, portfolio_unit: other_child_portfolio_unit, commitment_date: 5.days.ago
          Fabricate :demand, portfolio_unit: other_child_portfolio_unit, commitment_date: 4.days.ago, end_date: 2.days.ago
          Fabricate :demand, portfolio_unit: other_child_portfolio_unit, commitment_date: 4.days.ago, end_date: 2.days.ago, discarded_at: Time.zone.now

          expect(portfolio_unit.lead_time_p80).to eq 276_480
        end
      end
    end
  end
end
