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
      end
    end

    context 'with no data' do
      it 'assigns the correct information' do
        system_flow_info = described_class.new(Demand.all)
        expect(system_flow_info.demands).to eq []
        expect(system_flow_info.demands_ids).to eq []
      end
    end
  end
end
