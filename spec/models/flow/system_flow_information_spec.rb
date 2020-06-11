# frozen_string_literal: true

RSpec.describe Flow::SystemFlowInformation, type: :model do
  describe '.initialize' do
    context 'with data' do
      let(:company) { Fabricate :company }
      let(:customer) { Fabricate :customer, company: company }

      let(:first_project) { Fabricate :project, customers: [customer] }

      let(:demand) { Fabricate :demand, project: project }

      it 'assigns the correct information' do
        system_flow_info = described_class.new(Demand.all)

        expect(system_flow_info.demands).to match_array Demand.all
        expect(system_flow_info.demands_ids).to match_array Demand.all.map(&:id)
        expect(system_flow_info.current_limit_date).to eq Time.zone.today.end_of_week
      end
    end

    context 'with no data' do
      it 'assigns the correct information' do
        system_flow_info = described_class.new(Demand.all)
        expect(system_flow_info.demands).to eq []
        expect(system_flow_info.demands_ids).to eq []
        expect(system_flow_info.current_limit_date).to eq Time.zone.today.end_of_week
      end
    end
  end
end
