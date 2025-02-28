# frozen_string_literal: true

namespace :contracts do # rubocop:disable Metrics/BlockLength
  desc 'Fix demand contracts assignment based on end_date or discarded_at. Usage: rake contracts:fix_demand_contracts CUSTOMER_ID=X [DRY_RUN=true|false]'
  task fix_demand_contracts: :environment do
    customer_id = ENV.fetch('CUSTOMER_ID', nil)
    dry_run = ENV.fetch('DRY_RUN', 'true').downcase == 'true'

    if customer_id.blank?
      puts 'CUSTOMER_ID is required. Usage: rake contracts:fix_demand_contracts CUSTOMER_ID=X [DRY_RUN=true|false]'
      exit
    end

    customer = Customer.find_by(id: customer_id)
    if customer.nil?
      puts "Customer with ID #{customer_id} not found."
      exit
    end

    puts "Starting demand contract fix for customer: #{customer.name} (ID: #{customer.id})"
    puts "Mode: #{dry_run ? 'DRY RUN (no changes will be made)' : 'LIVE (changes will be applied)'}"

    fix_demand_contracts(customer, dry_run)
  end

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

      contract.contract_consolidations.destroy_all

      Consolidations::ContractConsolidationJob.perform_now(contract)

      processed += 1
    end

    puts "Reconsolidation completed! #{processed} contracts were processed."
  end

  def fix_demand_contracts(customer, dry_run)
    demands = Demand.where(customer_id: customer.id)
    contracts = verify_contracts_for_customer(customer)

    demands_to_update = find_demands_to_update(demands, contracts)
    exit_if_no_updates_needed(demands_to_update, customer)

    display_demands_to_update(demands_to_update)
    return if handle_dry_run(dry_run, customer)

    update_demands(demands_to_update)
  end

  def verify_contracts_for_customer(customer)
    contracts = Contract.where(customer_id: customer.id)

    if contracts.empty?
      puts "No contracts found for customer #{customer.name} (ID: #{customer.id})."
      exit
    end

    contracts
  end

  def find_demands_to_update(demands, contracts)
    most_recent_contract = contracts.order(start_date: :desc).first
    demands_to_update = []

    demands.find_each do |demand|
      reference_date = get_reference_date(demand)
      matching_contract = find_matching_contract(reference_date, contracts, most_recent_contract)

      next if demand.contract_id == matching_contract&.id || matching_contract.nil?

      demands_to_update << build_demand_data(demand, matching_contract, reference_date)
    end

    demands_to_update
  end

  def get_reference_date(demand)
    if demand.end_date.present?
      demand.end_date
    elsif demand.discarded_at.present?
      demand.discarded_at
    end
  end

  def find_matching_contract(reference_date, contracts, most_recent_contract)
    if reference_date.present?
      contracts.where('start_date <= ? AND (end_date >= ? OR end_date IS NULL)',
                      reference_date, reference_date).first
    else
      most_recent_contract
    end
  end

  def build_demand_data(demand, matching_contract, reference_date)
    reference_date_formatted = format_reference_date(demand, reference_date)

    {
      demand: demand,
      current_contract_id: demand.contract_id,
      suggested_contract_id: matching_contract.id,
      reference_date: reference_date_formatted
    }
  end

  def format_reference_date(demand, _reference_date)
    if demand.end_date.present?
      demand.end_date
    elsif demand.discarded_at.present?
      "#{demand.discarded_at} (discarded)"
    else
      'Não finalizada - Alocada no contrato mais recente'
    end
  end

  def exit_if_no_updates_needed(demands_to_update, customer)
    return unless demands_to_update.empty?

    puts "No demands need contract updates for customer #{customer.name}."
    exit
  end

  def display_demands_to_update(demands_to_update)
    puts "Found #{demands_to_update.size} demands that need contract updates:"
    puts ''

    demands_to_update.each_with_index do |data, index|
      demand = data[:demand]
      puts "#{index + 1}. Demand ##{demand.id}: #{demand.demand_title}"
      puts "   Reference Date: #{data[:reference_date]}"
      puts "   Current Contract: #{data[:current_contract_id] || 'None'}"
      puts "   Suggested Contract: #{data[:suggested_contract_id]}"
      puts ''
    end
  end

  def handle_dry_run(dry_run, customer)
    if dry_run
      puts 'DRY RUN COMPLETE. No changes were made to the database.'
      puts "To apply these changes, run: rake contracts:fix_demand_contracts CUSTOMER_ID=#{customer.id} DRY_RUN=false"
      true
    else
      puts "\nStarting demand updates..."
      puts ''
      false
    end
  end

  def update_demands(demands_to_update)
    updated_count = 0
    failed_count = 0

    Demand.transaction do
      demands_to_update.each_with_index do |data, index|
        result = update_single_demand(data, index, demands_to_update.size)
        updated_count += result ? 1 : 0
        failed_count += result ? 0 : 1
      end

      display_update_summary(updated_count, failed_count, demands_to_update.size)
    rescue StandardError => e
      handle_update_error(e)
    end
  end

  def update_single_demand(data, index, total_size)
    demand = data[:demand]
    old_contract_id = demand.contract_id
    new_contract_id = data[:suggested_contract_id]

    success = demand.update(contract_id: new_contract_id)

    if success
      display_success_message(index, total_size, demand.id, old_contract_id, new_contract_id)
    else
      display_failure_message(index, total_size, demand.id, demand.errors)
    end

    puts ''
    success
  end

  def display_success_message(index, total_size, demand_id, old_contract_id, new_contract_id)
    puts "✅ #{index + 1}/#{total_size}: Demand ##{demand_id} updated successfully."
    puts "   Contract changed: #{old_contract_id || 'None'} → #{new_contract_id}"
  end

  def display_failure_message(index, total_size, demand_id, errors)
    puts "❌ #{index + 1}/#{total_size}: Failed to update Demand ##{demand_id}."
    puts "   Errors: #{errors.full_messages.join(', ')}"
  end

  def display_update_summary(updated_count, failed_count, total_size)
    puts 'Update completed!'
    puts "Total demands updated: #{updated_count}/#{total_size}"
    puts "Failed updates: #{failed_count}"
  end

  def handle_update_error(error)
    puts "Error during update: #{error.message}"
    puts 'All changes have been rolled back.'
    raise ActiveRecord::Rollback, 'Rollback due to error.'
  end
end
