# frozen_string_literal: true

desc 'Start of plans'

namespace :plans do
  task create: :environment do
    Plan.create(plan_type: :trial, plan_period: :monthly, plan_value: 0, max_days_in_history: 0, max_number_of_downloads: 5, max_number_of_users: 0, extra_download_value: 0, plan_details: 'Sem gráficos e análises')
    Plan.create(plan_type: :lite, plan_period: :monthly, plan_value: 73.75, max_days_in_history: 7, max_number_of_downloads: 30, extra_download_value: 4.49, max_number_of_users: 0, plan_details: 'Gráficos de Status Report')
    Plan.create(plan_type: :gold, plan_period: :monthly, plan_value: 128.35, max_days_in_history: 30, max_number_of_downloads: 60, extra_download_value: 2.79, max_number_of_users: 0, plan_details: 'Capacidade Analítica Completa')
  end
end
