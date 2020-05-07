# frozen_string_literal: true

RSpec.describe CustomerDashboardData, type: :data_object do
  let(:company) { Fabricate :company }

  describe '.initialize' do
    let(:customer) { Fabricate :customer, company: company }
    let(:demand) { Fabricate :demand, company: company, customer: customer }
    let(:other_demand) { Fabricate :demand, company: company, customer: customer }

    it 'creates the data object computing and assigning the correct values' do
      statistic_info = instance_double('Flow::StatisticsFlowInformations', lead_time_accumulated: [10])
      time_info = instance_double('Flow::TimeFlowInformations', hours_delivered_upstream: [10], hours_delivered_downstream: [20])

      array_of_dates = [Time.zone.yesterday.to_date, Time.zone.today]

      expect(Flow::StatisticsFlowInformations).to(receive(:new).once { statistic_info })
      expect(Flow::TimeFlowInformations).to(receive(:new).once { time_info })
      expect(TimeService.instance).to(receive(:months_between_of).once { array_of_dates })
      expect(Demand).to(receive(:to_end_dates).twice { [demand, other_demand] })

      expect(statistic_info).to(receive(:statistics_flow_behaviour)).twice
      expect(time_info).to(receive(:hours_flow_behaviour)).twice

      described_class.new(customer.demands)
    end
  end
end
