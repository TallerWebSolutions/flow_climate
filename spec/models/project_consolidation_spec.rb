# frozen_string_literal: true

RSpec.describe ProjectConsolidation, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :project }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :project }
    it { is_expected.to validate_presence_of :consolidation_date }
  end

  describe '#demands_lead_times_average' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [0, 0, 0, 2.2, 3.1, 4.4, 5.8, 6.1, 6.2, 6.0, 7.1] }

      it { expect(project_consolidation.demands_lead_times_average.to_f).to eq 3.7181818181818183 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [] }

      it { expect(project_consolidation.demands_lead_times_average.to_f).to eq 0 }
    end
  end

  describe '#demands_lead_times_std_dev' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [0, 0, 0, 2.2, 3.1, 4.4, 5.8, 6.1, 6.2, 6.0, 7.1] }

      it { expect(project_consolidation.demands_lead_times_std_dev.to_f).to eq 2.782739003865861 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [] }

      it { expect(project_consolidation.demands_lead_times_std_dev.to_f).to eq 0 }
    end
  end

  describe '#lead_time_min' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [3.5, 0.1, 0.1, 2.2, 7.1, 4.4, 5.8, 6.1, 6.2, 6.0, 7.0] }

      it { expect(project_consolidation.lead_time_min.to_f).to eq 0.1 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [] }

      it { expect(project_consolidation.lead_time_min.to_f).to eq 0 }
    end
  end

  describe '#total_lead_time_range' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [3.5, 10.23, 9.1, 2.2, 7.1, 4.4, 5.8, 6.1, 6.2, 6.0, 7.0] }

      it { expect(project_consolidation.total_lead_time_range.to_f).to eq 8.03 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [] }

      it { expect(project_consolidation.total_lead_time_range.to_f).to eq 0 }
    end
  end

  describe '#histogram_range' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [3.5, 10.23, 9.1, 2.2, 7.1, 4.4, 5.8, 6.1, 6.2, 6.0, 7.0] }

      it { expect(project_consolidation.histogram_range.to_f).to eq 5.3533333333333335 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [] }

      it { expect(project_consolidation.histogram_range.to_f).to eq 0 }
    end
  end

  describe '#lead_time_histogram_bin_max' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [3.5, 10.23, 9.1, 2.2, 7.1, 4.4, 5.8, 6.1, 6.2, 6.0, 7.0] }

      it { expect(project_consolidation.lead_time_histogram_bin_max.to_f).to eq 8.891666666666667 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [] }

      it { expect(project_consolidation.lead_time_histogram_bin_max.to_f).to eq 0 }
    end
  end

  describe '#lead_time_histogram_bin_min' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [3.5, 10.23, 9.1, 2.2, 7.1, 4.4, 5.8, 6.1, 6.2, 6.0, 7.0] }

      it { expect(project_consolidation.lead_time_histogram_bin_min.to_f).to eq 3.5383333333333336 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [] }

      it { expect(project_consolidation.lead_time_histogram_bin_min.to_f).to eq 0 }
    end
  end

  describe '#project_monte_carlo_weeks_min' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, project_monte_carlo_weeks: [3, 10, 9, 2, 7, 4, 5, 6, 6, 6, 7] }

      it { expect(project_consolidation.project_monte_carlo_weeks_min.to_f).to eq 2.0 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, project_monte_carlo_weeks: [] }

      it { expect(project_consolidation.project_monte_carlo_weeks_min.to_f).to eq 0 }
    end
  end

  describe '#product_monte_carlo_weeks_min' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, products_monte_carlo_weeks: [3, 10, 9, 2, 7, 4, 5, 6, 6, 6, 7] }

      it { expect(project_consolidation.product_monte_carlo_weeks_min.to_f).to eq 2.0 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, products_monte_carlo_weeks: [] }

      it { expect(project_consolidation.product_monte_carlo_weeks_min.to_f).to eq 0 }
    end
  end

  describe '#project_monte_carlo_weeks_max' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, project_monte_carlo_weeks: [3, 10, 9, 2, 7, 4, 5, 6, 6, 6, 7] }

      it { expect(project_consolidation.project_monte_carlo_weeks_max.to_f).to eq 10.0 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, project_monte_carlo_weeks: [] }

      it { expect(project_consolidation.project_monte_carlo_weeks_max.to_f).to eq 0 }
    end
  end

  describe '#product_monte_carlo_weeks_max' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, products_monte_carlo_weeks: [3, 10, 9, 2, 7, 4, 5, 6, 6, 6, 7] }

      it { expect(project_consolidation.product_monte_carlo_weeks_max.to_f).to eq 10.0 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, products_monte_carlo_weeks: [] }

      it { expect(project_consolidation.product_monte_carlo_weeks_max.to_f).to eq 0 }
    end
  end

  describe '#team_monte_carlo_weeks_min' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, team_monte_carlo_weeks: [3, 10, 9, 2, 7, 4, 5, 6, 6, 6, 7] }

      it { expect(project_consolidation.team_monte_carlo_weeks_min.to_f).to eq 2.0 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, team_monte_carlo_weeks: [] }

      it { expect(project_consolidation.team_monte_carlo_weeks_min.to_f).to eq 0 }
    end
  end

  describe '#team_monte_carlo_weeks_max' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, team_monte_carlo_weeks: [3, 10, 9, 2, 7, 4, 5, 6, 6, 6, 7] }

      it { expect(project_consolidation.team_monte_carlo_weeks_max.to_f).to eq 10.0 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, team_monte_carlo_weeks: [] }

      it { expect(project_consolidation.team_monte_carlo_weeks_max.to_f).to eq 0 }
    end
  end

  describe '#team_monte_carlo_weeks_std_dev' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, team_monte_carlo_weeks: [3, 10, 9, 2, 7, 4, 5, 6, 6, 6, 7] }

      it { expect(project_consolidation.team_monte_carlo_weeks_std_dev.to_f).to eq 2.3855626361320073 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, team_monte_carlo_weeks: [] }

      it { expect(project_consolidation.team_monte_carlo_weeks_std_dev.to_f).to eq 0 }
    end
  end

  describe '#product_monte_carlo_weeks_std_dev' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, products_monte_carlo_weeks: [3, 10, 9, 2, 7, 4, 5, 6, 6, 6, 7] }

      it { expect(project_consolidation.product_monte_carlo_weeks_std_dev.to_f).to eq 2.3855626361320073 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, products_monte_carlo_weeks: [] }

      it { expect(project_consolidation.product_monte_carlo_weeks_std_dev.to_f).to eq 0 }
    end
  end

  describe '#lead_time_p25' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [3.5, 10.23, 9.1, 2.2, 7.1, 4.4, 5.8, 6.1, 6.2, 6.0, 7.0] }

      it { expect(project_consolidation.lead_time_p25.to_f).to eq 5.1 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [] }

      it { expect(project_consolidation.lead_time_p25.to_f).to eq 0 }
    end
  end

  describe '#lead_time_p75' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [3.5, 10.23, 9.1, 2.2, 7.1, 4.4, 5.8, 6.1, 6.2, 6.0, 7.0] }

      it { expect(project_consolidation.lead_time_p75.to_f).to eq 7.05 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [] }

      it { expect(project_consolidation.lead_time_p75.to_f).to eq 0 }
    end
  end

  describe '#interquartile_range' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [3.5, 10.23, 9.1, 2.2, 7.1, 4.4, 5.8, 6.1, 6.2, 6.0, 7.0] }

      it { expect(project_consolidation.interquartile_range.to_f).to eq 1.9500000000000002 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [] }

      it { expect(project_consolidation.interquartile_range.to_f).to eq 0 }
    end
  end

  describe '#project_little_law_weeks' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, project_weekly_throughput: [3, 10, 9, 2, 7, 4, 5, 6, 6, 6, 7] }

      it { expect(project_consolidation.project_little_law_weeks.to_f).to eq 5.076923076923077 }
      it { expect(project_consolidation.project_little_law_weeks(4).to_f).to eq 4.8 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, project_weekly_throughput: [] }

      it { expect(project_consolidation.project_little_law_weeks.to_f).to eq 0 }
    end
  end

  describe '#project_monte_carlo_weeks_percentil' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, project_monte_carlo_weeks: [3, 10, 9, 2, 7, 4, 5, 6, 6, 6, 7] }

      it { expect(project_consolidation.project_monte_carlo_weeks_percentil.to_f).to eq 7 }
      it { expect(project_consolidation.project_monte_carlo_weeks_percentil(60).to_f).to eq 6 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, project_monte_carlo_weeks: [] }

      it { expect(project_consolidation.project_monte_carlo_weeks_percentil.to_f).to eq 0 }
    end
  end

  describe '#team_monte_carlo_weeks_percentil' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, team_monte_carlo_weeks: [3, 10, 9, 2, 7, 4, 5, 6, 6, 6, 7] }

      it { expect(project_consolidation.team_monte_carlo_weeks_percentil.to_f).to eq 7 }
      it { expect(project_consolidation.team_monte_carlo_weeks_percentil(60).to_f).to eq 6 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, team_monte_carlo_weeks: [] }

      it { expect(project_consolidation.team_monte_carlo_weeks_percentil.to_f).to eq 0 }
    end
  end

  describe '#product_monte_carlo_weeks_percentil' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, products_monte_carlo_weeks: [3, 10, 9, 2, 7, 4, 5, 6, 6, 6, 7] }

      it { expect(project_consolidation.product_monte_carlo_weeks_percentil.to_f).to eq 7 }
      it { expect(project_consolidation.product_monte_carlo_weeks_percentil(60).to_f).to eq 6 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, products_monte_carlo_weeks: [] }

      it { expect(project_consolidation.product_monte_carlo_weeks_percentil.to_f).to eq 0 }
    end
  end

  describe '#population_lead_time' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [3.5, 10.23, 9.1, 2.2, 7.1, 4.4, 5.8, 6.1, 6.2, 6.0, 7.0] }

      it { expect(project_consolidation.population_lead_time(80).to_f).to eq 7.1 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, demands_lead_times: [] }

      it { expect(project_consolidation.population_lead_time(80).to_f).to eq 0 }
    end
  end

  describe '#project_monte_carlo_weeks_min_percentage' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, project_monte_carlo_weeks: [3, 10, 9, 2, 7, 4, 5, 6, 6, 6, 7] }

      it { expect(project_consolidation.project_monte_carlo_weeks_min_percentage).to eq 0.09090909090909091 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, project_monte_carlo_weeks: [] }

      it { expect(project_consolidation.project_monte_carlo_weeks_min_percentage.to_f).to eq 0 }
    end
  end

  describe '#team_monte_carlo_weeks_min_percentage' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, team_monte_carlo_weeks: [3, 10, 9, 2, 7, 4, 5, 6, 6, 6, 7] }

      it { expect(project_consolidation.team_monte_carlo_weeks_min_percentage).to eq 0.09090909090909091 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, team_monte_carlo_weeks: [] }

      it { expect(project_consolidation.team_monte_carlo_weeks_min_percentage.to_f).to eq 0 }
    end
  end

  describe '#product_monte_carlo_weeks_min_percentage' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, products_monte_carlo_weeks: [3, 10, 9, 2, 7, 4, 5, 6, 6, 6, 7] }

      it { expect(project_consolidation.product_monte_carlo_weeks_min_percentage).to eq 0.09090909090909091 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, products_monte_carlo_weeks: [] }

      it { expect(project_consolidation.product_monte_carlo_weeks_min_percentage.to_f).to eq 0 }
    end
  end

  describe '#project_monte_carlo_weeks_std_dev' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, project_monte_carlo_weeks: [3, 10, 9, 2, 7, 4, 5, 6, 6, 6, 7] }

      it { expect(project_consolidation.project_monte_carlo_weeks_std_dev).to eq 2.3855626361320073 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, project_monte_carlo_weeks: [] }

      it { expect(project_consolidation.project_monte_carlo_weeks_std_dev.to_f).to eq 0 }
    end
  end

  describe '#odds_to_deadline_project' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, project_monte_carlo_weeks: [3, 10, 9, 2, 7, 4, 5, 6, 6, 6, 7] }

      it { expect(project_consolidation.odds_to_deadline_project).to eq 0.36363636363636365 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, project_monte_carlo_weeks: [] }

      it { expect(project_consolidation.odds_to_deadline_project.to_f).to eq 0 }
    end
  end

  describe '#odds_to_deadline_team' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, team_monte_carlo_weeks: [3, 10, 9, 2, 7, 4, 5, 6, 6, 6, 7] }

      it { expect(project_consolidation.odds_to_deadline_team).to eq 0.36363636363636365 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, team_monte_carlo_weeks: [] }

      it { expect(project_consolidation.odds_to_deadline_team.to_f).to eq 0 }
    end
  end

  describe '#customer_happiness' do
    let(:project) { Fabricate :project, end_date: 4.weeks.from_now }

    context 'with data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, project_monte_carlo_weeks: [3, 10, 9, 2, 7, 4, 5, 6, 6, 6, 7] }

      it { expect(project_consolidation.customer_happiness).to eq 0.7142857142857143 }
    end

    context 'with no data' do
      let!(:project_consolidation) { Fabricate :project_consolidation, project: project, consolidation_date: 1.day.ago, project_monte_carlo_weeks: [] }

      it { expect(project_consolidation.customer_happiness.to_f).to eq 0 }
    end
  end
end
