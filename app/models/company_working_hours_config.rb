# frozen_string_literal: true

# == Schema Information
#
# Table name: company_working_hours_configs
#
#  id            :bigint           not null, primary key
#  end_date      :date
#  hours_per_day :decimal(4, 1)    not null
#  start_date    :date             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  company_id    :bigint           not null
#
# Indexes
#
#  idx_company_working_hours_dates                    (company_id,start_date,end_date)
#  index_company_working_hours_configs_on_company_id  (company_id)
#
# Foreign Keys
#
#  fk_rails_98bd131790  (company_id => companies.id)
#
class CompanyWorkingHoursConfig < ApplicationRecord
  belongs_to :company

  validates :hours_per_day, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 24 }
  validates :start_date, presence: true
  validate :end_date_after_start_date
  validate :no_overlapping_periods

  scope :active, -> { where(active: true) }
  scope :for_date, ->(date) { active.where('start_date <= ? AND (end_date IS NULL OR end_date >= ?)', date, date) }

  # Retorna true se a configuração está vigente hoje
  def active_now?
    today = Time.zone.today
    start_date <= today && (end_date.nil? || end_date >= today)
  end

  private

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?
    return unless end_date < start_date

    errors.add(:end_date, 'must be after start date')
  end

  # Garante que não há sobreposição de períodos para a mesma empresa
  def no_overlapping_periods
    return if company.blank? || start_date.blank?

    configs = company.company_working_hours_configs.where.not(id: id)
    configs.each do |other|
      # Se o intervalo [start_date, end_date] deste registro sobrepõe o de outro
      other_start = other.start_date
      other_end = other.end_date || Date.new(3000, 1, 1)
      this_start = start_date
      this_end = end_date || Date.new(3000, 1, 1)
      if (this_start <= other_end) && (other_start <= this_end)
        errors.add(:base, 'overlaps with existing configuration period')
        break
      end
    end
  end
end
