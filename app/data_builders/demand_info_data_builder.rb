# frozen_string_literal: true

class DemandInfoDataBuilder
  include Singleton

  def build_data_from_hash_per_week(info_grouped_by_date_hash, start_date, end_date)
    data_grouped_hash = {}

    return data_grouped_hash if start_date.blank? || end_date.blank?

    dates_array = TimeService.instance.weeks_between_of(start_date, end_date)

    dates_array.each { |date| data_grouped_hash[date] = info_grouped_by_date_hash[date] || 0 }

    data_grouped_hash
  end
end
