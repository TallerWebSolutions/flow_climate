# frozen_string_literal: true

RSpec.describe Stats::Presenter::MonteCarloPresenter, type: :presenter do
  before { travel_to Time.zone.local(2018, 4, 12, 10, 0, 0) }
  after { travel_back }

  describe '.new' do
    let(:project) { Fabricate :project, start_date: Date.new(2018, 4, 10) }

    let!(:first_demand) { Fabricate :demand, project: project }
    let!(:second_demand) { Fabricate :demand, project: project }
    let!(:third_demand) { Fabricate :demand, project: project }
    let!(:first_completed_demand) { Fabricate :demand, project: project, commitment_date: Date.new(2018, 4, 2), end_date: Date.new(2018, 4, 12) }
    let!(:second_completed_demand) { Fabricate :demand, project: project, commitment_date: Date.new(2018, 3, 20), end_date: Date.new(2018, 4, 6) }
    let!(:third_completed_demand) { Fabricate :demand, project: project, commitment_date: Date.new(2018, 3, 25), end_date: Date.new(2018, 4, 2) }

    let(:dates_and_hits_hash) { { Date.new(2018, 4, 25).to_datetime.to_i => 1000 } }

    context 'having monte carlo data' do
      subject(:presenter) { Stats::Presenter::MonteCarloPresenter.new(dates_and_hits_hash) }

      it 'provides the correct monte carlo properties' do
        expect(presenter.dates_and_hits_hash).to eq(1_524_614_400 => 1000)
        expect(presenter.monte_carlo_date_hash).to eq(Date.new(2018, 4, 24) => 1)
        expect(presenter.predicted_dates).to eq [[1_524_614_400, 1000]]
      end
    end
  end
end
