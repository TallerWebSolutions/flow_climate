# frozen_string_literal: true

namespace :contracts do # rubocop:disable Metrics/BlockLength
  desc 'Reconsolidates contracts to fix consumed hours. Use CUSTOMER_ID=X to process only a specific customer'
  task reconsolidate: :environment do
    customer_id = ENV.fetch('CUSTOMER_ID', nil)

    if customer_id.present?
      customer = Customer.find_by(id: customer_id)

      if customer.nil?
        puts "Customer with ID #{customer_id} not found."
        exit
      end

      puts "Starting contract reconsolidation for customer: #{customer.name} (ID: #{customer.id})"
      contracts = Contract.where(customer_id: customer.id)
    else
      puts 'Starting reconsolidation of ALL contracts...'
      contracts = Contract.all
    end

    process_contracts_reconsolidation(contracts)
  end

  private

  def process_contracts_reconsolidation(contracts)
    contracts_count = contracts.count
    processed = 0

    if contracts_count.zero?
      puts 'No contracts found to process.'
      exit
    end

    contracts.find_each do |contract|
      puts "Reconsolidating contract #{contract.id} - #{contract.product_name} (#{processed + 1}/#{contracts_count})"

      # Remove existing consolidations
      contract.contract_consolidations.destroy_all

      # Execute reconsolidation job
      Consolidations::ContractConsolidationJob.perform_now(contract)

      processed += 1
    end

    puts "Reconsolidation completed! #{processed} contracts were processed."
  end
end
