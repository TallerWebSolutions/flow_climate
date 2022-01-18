# frozen_string_literal: true

RSpec.describe Flow::ContractsFlowInformation do
  let(:company) { Fabricate :company }
  let(:customer) { Fabricate :customer, company: company }
  let(:product) { Fabricate :product, company: company, customer: customer }

  describe '#build_financial_burnup' do
    context 'with no demands' do
      it 'builds the burnup with the correct information' do
        contract = Fabricate :contract, customer: customer, total_value: 100
        contract_flow = described_class.new(contract)

        expect(contract_flow.build_financial_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [] }, { name: I18n.t('charts.burnup.current'), data: [] }, { name: I18n.t('charts.burnup.ideal'), data: [] }])
      end
    end

    context 'with demands' do
      it 'builds the burnup with the correct information' do
        travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
          project = Fabricate :project, customers: [customer], products: [product]
          contract = Fabricate :contract, customer: customer, total_value: 1_000_000, total_hours: 20_000, start_date: 3.months.ago, end_date: 1.month.from_now

          demand = Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, end_date: Time.zone.now, effort_upstream: 10, effort_downstream: 30)

          Fabricate :demand_effort, demand: demand, start_time_to_computation: Time.zone.now, effort_value: 50
          Fabricate :demand_effort, demand: demand, start_time_to_computation: 1.month.ago, effort_value: 30

          Fabricate :demand_effort, demand: demand, start_time_to_computation: 3.months.ago, effort_value: 60
          Fabricate :demand_effort, demand: demand, start_time_to_computation: 4.months.ago, effort_value: 10

          contract_flow = described_class.new(contract)

          expect(contract_flow.dates_array).to eq [Date.new(2020, 3, 31), Date.new(2020, 4, 30), Date.new(2020, 5, 31), Date.new(2020, 6, 30), Date.new(2020, 7, 31)]
          expect(contract_flow.dates_limit_now_array).to eq [Date.new(2020, 3, 31), Date.new(2020, 4, 30), Date.new(2020, 5, 31), Date.new(2020, 6, 30)]

          expect(contract_flow.build_financial_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [1_000_000, 1_000_000, 1_000_000, 1_000_000, 1_000_000] }, { name: I18n.t('charts.burnup.current'), data: [0.0, 0.0, 0.0, 2000.0] }, { name: I18n.t('charts.burnup.ideal'), data: [200_000, 400_000, 600_000, 800_000, 1_000_000] }])

          expect(contract_flow.delivered_demands_count).to eq 1
          expect(contract_flow.remaining_backlog_count).to eq 665
          expect(contract_flow.consumed_hours).to eq 150
          expect(contract_flow.remaining_hours).to eq 19_850
        end
      end
    end
  end

  describe '#build_hours_burnup' do
    context 'with no demands' do
      it 'builds the burnup with the correct information' do
        contract = Fabricate :contract, customer: customer, total_value: 100
        contract_flow = described_class.new(contract)

        expect(contract_flow.build_hours_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [] }, { name: I18n.t('charts.burnup.current'), data: [] }, { name: I18n.t('charts.burnup.ideal'), data: [] }])
      end
    end

    context 'with demands and contracts' do
      it 'builds the burnup with the correct information' do
        travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
          product = Fabricate :product, company: company, customer: customer
          project = Fabricate :project, customers: [customer], products: [product]
          contract = Fabricate :contract, customer: customer, total_value: 100_000, total_hours: 2000, start_date: 3.months.ago, end_date: 1.month.from_now

          demand = Fabricate :demand, company: company, product: product, customer: customer, project: project, contract: contract, end_date: Time.zone.now, effort_upstream: 10, effort_downstream: 30

          Fabricate :demand_effort, demand: demand, start_time_to_computation: Time.zone.now, effort_value: 50
          Fabricate :demand_effort, demand: demand, start_time_to_computation: 1.month.ago, effort_value: 30

          Fabricate :demand_effort, demand: demand, start_time_to_computation: 3.months.ago, effort_value: 60
          Fabricate :demand_effort, demand: demand, start_time_to_computation: 4.months.ago, effort_value: 10

          contract_flow = described_class.new(contract)

          expect(contract_flow.build_hours_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [2000, 2000, 2000, 2000, 2000] }, { name: I18n.t('charts.burnup.current'), data: [0.0, 0.0, 0.0, 40.0] }, { name: I18n.t('charts.burnup.ideal'), data: [400, 800, 1200, 1600, 2000] }])
        end
      end
    end

    context 'with demands and contracts but no effort' do
      context 'with monthly period' do
        it 'builds the burnup with the correct information' do
          travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
            project = Fabricate :project, customers: [customer], products: [product]
            contract = Fabricate :contract, customer: customer, total_value: 100_000, total_hours: 2000, start_date: 3.months.ago, end_date: 1.month.from_now

            Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, end_date: Time.zone.now, effort_upstream: 10, effort_downstream: 30)
            Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, end_date: 1.month.ago, effort_upstream: 40, effort_downstream: 10)
            Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, end_date: 3.months.ago, effort_upstream: 0, effort_downstream: 50)
            Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, end_date: 4.months.ago, effort_upstream: 100, effort_downstream: 300)

            contract_flow = described_class.new(contract)

            expect(contract_flow.build_hours_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [2000, 2000, 2000, 2000, 2000] }, { name: I18n.t('charts.burnup.current'), data: [50.0, 50.0, 100.0, 140.0] }, { name: I18n.t('charts.burnup.ideal'), data: [400, 800, 1200, 1600, 2000] }])
          end
        end
      end
    end
  end

  describe '#build_scope_burnup' do
    context 'with no demands' do
      it 'builds the burnup with the correct information' do
        contract = Fabricate :contract, customer: customer, total_value: 100
        contract_flow = described_class.new(contract)

        expect(contract_flow.build_scope_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [] }, { name: I18n.t('charts.burnup.current'), data: [] }, { name: I18n.t('charts.burnup.ideal'), data: [] }])
      end
    end

    context 'with demands' do
      it 'builds the burnup with the correct information' do
        travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
          product = Fabricate :product, company: company, customer: customer
          project = Fabricate :project, customers: [customer], products: [product]
          contract = Fabricate :contract, customer: customer, total_value: 100_000, total_hours: 2000, hours_per_demand: 30, start_date: 3.months.ago, end_date: 1.month.from_now

          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, end_date: Time.zone.now, effort_upstream: 10, effort_downstream: 30)
          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, end_date: 1.month.ago, effort_upstream: 40, effort_downstream: 10)
          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, end_date: 3.months.ago, effort_upstream: 0, effort_downstream: 50)
          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, end_date: 4.months.ago, effort_upstream: 100, effort_downstream: 300)

          contract_flow = described_class.new(contract)

          expect(contract_flow.build_scope_burnup).to eq([{ name: I18n.t('charts.burnup.scope'), data: [66, 66, 66, 66, 66] }, { name: I18n.t('charts.burnup.current'), data: [1, 1, 2, 3] }, { name: I18n.t('charts.burnup.ideal'), data: [13.2, 26.4, 39.599999999999994, 52.8, 66.0] }])
        end
      end
    end
  end

  describe '#build_quality_info' do
    context 'with no demands' do
      it 'builds an empty quality info' do
        contract = Fabricate :contract, customer: customer, total_value: 100
        contract_flow = described_class.new(contract)

        expect(contract_flow.build_quality_info).to eq([{ name: I18n.t('charts.quality_info.bugs_by_delivery'), data: [] }, { name: I18n.t('charts.quality_info.bugs_by_delivery_month'), data: [] }])
      end
    end

    context 'with demands' do
      it 'builds the quality info with the correct information' do
        travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
          product = Fabricate :product, company: company, customer: customer
          project = Fabricate :project, customers: [customer], products: [product]
          contract = Fabricate :contract, customer: customer, total_value: 100_000, total_hours: 2000, hours_per_demand: 30, start_date: 3.months.ago, end_date: 1.month.from_now

          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :feature, end_date: Time.zone.now, effort_upstream: 10, effort_downstream: 30)
          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :bug, end_date: 1.month.ago, effort_upstream: 40, effort_downstream: 10)
          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :bug, end_date: 3.months.ago, effort_upstream: 0, effort_downstream: 50)
          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :feature, end_date: 4.months.ago, effort_upstream: 100, effort_downstream: 300)

          contract_flow = described_class.new(contract)

          expect(contract_flow.build_quality_info).to eq([{ name: I18n.t('charts.quality_info.bugs_by_delivery'), data: [0, 0, 0, 0.6666666666666666] }, { name: I18n.t('charts.quality_info.bugs_by_delivery_month'), data: [0, 0, 0, 0.6666666666666666] }])
        end
      end
    end
  end

  describe '#build_lead_time_info' do
    context 'with no demands' do
      it 'builds an empty lead time info' do
        contract = Fabricate :contract, customer: customer, total_value: 100
        contract_flow = described_class.new(contract)

        expect(contract_flow.build_lead_time_info).to eq([{ name: I18n.t('general.leadtime_p80_label'), data: [] }, { name: I18n.t('general.dashboards.lead_time_in_month'), data: [] }])
      end
    end

    context 'with demands' do
      it 'builds the lead time info with the correct information' do
        travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
          product = Fabricate :product, company: company, customer: customer
          project = Fabricate :project, customers: [customer], products: [product]
          contract = Fabricate :contract, customer: customer, total_value: 100_000, total_hours: 2000, hours_per_demand: 30, start_date: 3.months.ago, end_date: 1.month.from_now

          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :feature, commitment_date: 2.months.ago, end_date: Time.zone.now)
          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :bug, commitment_date: 35.days.ago, end_date: 1.month.ago)
          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :bug, commitment_date: 102.days.ago, end_date: 3.months.ago)
          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :feature, commitment_date: 134.days.ago, end_date: 4.months.ago)

          contract_flow = described_class.new(contract)

          expect(contract_flow.build_lead_time_info).to eq([{ name: I18n.t('general.leadtime_p80_label'), data: [10.0, 10.0, 8.8, 40.60000000000001] }, { name: I18n.t('general.dashboards.lead_time_in_month'), data: [10.0, 0, 4.0, 61.0] }])
        end
      end
    end
  end

  describe '#build_throughput_info' do
    context 'with no demands' do
      it 'builds an empty throughput info' do
        contract = Fabricate :contract, customer: customer, total_value: 100
        contract_flow = described_class.new(contract)

        expect(contract_flow.build_throughput_info).to eq([{ name: I18n.t('customer.charts.throughput.title'), data: [] }])
      end
    end

    context 'with demands and contracts' do
      it 'builds the throughput info with the correct information' do
        travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
          product = Fabricate :product, company: company, customer: customer
          project = Fabricate :project, customers: [customer], products: [product]
          contract = Fabricate :contract, customer: customer, total_value: 100_000, total_hours: 2000, hours_per_demand: 30, start_date: 3.months.ago, end_date: 1.month.from_now

          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :feature, commitment_date: 2.months.ago, end_date: Time.zone.now)
          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :bug, commitment_date: 35.days.ago, end_date: 1.month.ago)
          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :bug, commitment_date: 102.days.ago, end_date: 3.months.ago)
          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :feature, commitment_date: 134.days.ago, end_date: 4.months.ago)

          contract_flow = described_class.new(contract)

          expect(contract_flow.build_throughput_info).to eq([{ name: I18n.t('customer.charts.throughput.title'), data: [1, 1, 2, 3] }])
        end
      end
    end
  end

  describe '#build_risk_info' do
    context 'with no consolidations' do
      it 'builds an empty risk info' do
        contract = Fabricate :contract, customer: customer, total_value: 100
        contract_flow = described_class.new(contract)

        expect(contract_flow.build_risk_info).to eq([{ name: contract.start_date, data: [] }])
      end
    end

    context 'with consolidations' do
      it 'builds the risk info with the correct information' do
        travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
          product = Fabricate :product, company: company, customer: customer
          contract = Fabricate :contract, customer: customer, product: product, total_value: 100_000, total_hours: 2000, hours_per_demand: 30, start_date: 3.months.ago, end_date: 1.month.from_now

          Fabricate :contract_consolidation, contract: contract, consolidation_date: Time.zone.today, operational_risk_value: 0.2
          Fabricate :contract_consolidation, contract: contract, consolidation_date: 1.month.ago, operational_risk_value: 0.4

          contract_flow = described_class.new(contract)

          expect(contract_flow.build_risk_info).to eq([{ name: contract.start_date, data: [40, 20] }])
        end
      end
    end
  end

  describe '#build_hours_blocked_per_delivery_info' do
    context 'with no demands' do
      it 'builds an empty hours blocked per delivery info' do
        contract = Fabricate :contract, customer: customer, total_value: 100
        contract_flow = described_class.new(contract)

        expect(contract_flow.build_hours_blocked_per_delivery_info).to eq([{ name: I18n.t('customer.charts.hours_blocked_per_delivery.title'), data: [] }])
      end
    end

    context 'with demands and no blocks' do
      it 'builds the hours blocked info with the correct information' do
        travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
          product = Fabricate :product, company: company, customer: customer
          project = Fabricate :project, customers: [customer], products: [product]
          contract = Fabricate :contract, customer: customer, total_value: 100_000, total_hours: 2000, hours_per_demand: 30, start_date: 3.months.ago, end_date: 1.month.from_now

          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :feature, commitment_date: 2.days.ago, end_date: Time.zone.now)
          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :bug, commitment_date: 35.days.ago, end_date: 1.month.ago)
          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :bug, commitment_date: 102.days.ago, end_date: 3.months.ago)
          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :feature, commitment_date: 134.days.ago, end_date: 4.months.ago)

          contract_flow = described_class.new(contract)

          expect(contract_flow.build_hours_blocked_per_delivery_info).to eq([{ name: I18n.t('customer.charts.hours_blocked_per_delivery.title'), data: [0, 0, 0, 0] }])
        end
      end
    end

    context 'with demands and blocks' do
      it 'builds the hours blocked info with the correct information' do
        travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
          product = Fabricate :product, company: company, customer: customer
          project = Fabricate :project, customers: [customer], products: [product]
          contract = Fabricate :contract, customer: customer, total_value: 100_000, total_hours: 2000, hours_per_demand: 30, start_date: 3.months.ago, end_date: 1.month.from_now

          demand = Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :bug, commitment_date: 35.days.ago, end_date: 1.month.ago)
          other_demand = Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :bug, commitment_date: 39.days.ago, end_date: 35.days.ago)

          Fabricate :demand_block, demand: demand, block_time: 34.days.ago, unblock_time: 31.days.ago
          Fabricate :demand_block, demand: other_demand, block_time: 38.days.ago, unblock_time: 37.days.ago

          Demand.all.each { |demand_to_effort| DemandEffortService.instance.build_efforts_to_demand(demand_to_effort) }

          contract_flow = described_class.new(contract)

          expect(contract_flow.build_hours_blocked_per_delivery_info).to eq([{ name: I18n.t('customer.charts.hours_blocked_per_delivery.title'), data: [0, 0, 4, 4] }])
        end
      end
    end
  end

  describe '#build_external_dependency_info' do
    context 'with no demands' do
      it 'builds an empty external dependency info' do
        contract = Fabricate :contract, customer: customer, total_value: 100
        contract_flow = described_class.new(contract)

        expect(contract_flow.build_external_dependency_info).to eq([{ name: I18n.t('customer.charts.external_dependency.title'), data: [] }])
      end
    end

    context 'with demands and no blocks' do
      it 'builds the external dependency info with the correct information' do
        travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
          product = Fabricate :product, company: company, customer: customer
          project = Fabricate :project, customers: [customer], products: [product]
          contract = Fabricate :contract, customer: customer, total_value: 100_000, total_hours: 2000, hours_per_demand: 30, start_date: 3.months.ago, end_date: 1.month.from_now

          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :feature, commitment_date: 2.days.ago, end_date: Time.zone.now)
          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :bug, commitment_date: 35.days.ago, end_date: 1.month.ago)
          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :bug, commitment_date: 102.days.ago, end_date: 3.months.ago)
          Fabricate(:demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :feature, commitment_date: 134.days.ago, end_date: 4.months.ago)

          contract_flow = described_class.new(contract)

          expect(contract_flow.build_external_dependency_info).to eq([{ name: I18n.t('customer.charts.external_dependency.title'), data: [0, 0, 0, 0] }])
        end
      end
    end

    context 'with demands and blocks' do
      it 'builds the throughput info with the correct information' do
        travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
          product = Fabricate :product, company: company, customer: customer
          project = Fabricate :project, customers: [customer], products: [product]
          contract = Fabricate :contract, customer: customer, total_value: 100_000, total_hours: 2000, hours_per_demand: 30, start_date: 3.months.ago, end_date: 1.month.from_now

          Fabricate :demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :bug, commitment_date: 35.days.ago, end_date: 1.month.ago
          Fabricate :demand_block, demand: Demand.all.sample, block_time: 34.days.ago, unblock_time: 30.days.ago, block_type: :external_dependency

          contract_flow = described_class.new(contract)

          expect(contract_flow.build_external_dependency_info).to eq([{ name: I18n.t('customer.charts.external_dependency.title'), data: [0, 0, 1, 0] }])
        end
      end
    end
  end

  describe '#build_effort_info' do
    context 'with no demands' do
      it 'builds an empty external dependency info' do
        contract = Fabricate :contract, customer: customer, total_value: 100
        contract_flow = described_class.new(contract)

        expect(contract_flow.build_effort_info).to eq([{ type: 'column', yAxis: 1, name: I18n.t('general.dashboards.hours_delivered'), data: [0] }, { type: 'spline', name: I18n.t('general.dashboards.hours_delivered_acc'), data: [0] }])
      end
    end

    context 'with demands' do
      it 'builds the external dependency info with the correct information' do
        travel_to Time.zone.local(2020, 6, 24, 10, 0, 0) do
          product = Fabricate :product, company: company, customer: customer
          project = Fabricate :project, customers: [customer], products: [product]
          contract = Fabricate :contract, customer: customer, total_value: 100_000, total_hours: 2000, hours_per_demand: 30, start_date: 3.months.ago, end_date: 1.month.from_now

          demand = Fabricate :demand, company: company, product: product, customer: customer, project: project, contract: contract, demand_type: :feature, commitment_date: 2.days.ago, end_date: Time.zone.now

          Fabricate :demand_effort, demand: demand, start_time_to_computation: Time.zone.now, effort_value: 50
          Fabricate :demand_effort, demand: demand, start_time_to_computation: 1.month.ago, effort_value: 30

          Fabricate :demand_effort, demand: demand, start_time_to_computation: 3.months.ago, effort_value: 60
          Fabricate :demand_effort, demand: demand, start_time_to_computation: 4.months.ago, effort_value: 10

          contract_flow = described_class.new(contract)

          expect(contract_flow.build_effort_info).to eq([{ type: 'column', yAxis: 1, name: I18n.t('general.dashboards.hours_delivered'), data: [60.0, 0.0, 30.0, 50.0] }, { type: 'spline', name: I18n.t('general.dashboards.hours_delivered_acc'), data: [70.0, 70.0, 100.0, 150.0] }])
        end
      end
    end
  end
end
