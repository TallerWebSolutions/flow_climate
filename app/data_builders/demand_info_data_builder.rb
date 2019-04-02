# frozen_string_literal: true

class DemandInfoDataBuilder
  include Singleton

  def build_data_from_hash_per_week(info_grouped_by_date_hash, start_date, end_date)
    data_grouped_hash = {}

    (start_date..end_date).each do |date|
      data_grouped_hash[date.beginning_of_week] = info_grouped_by_date_hash[[date.to_date.cweek.to_f, date.to_date.cwyear.to_f]] || 0
    end

    data_grouped_hash
  end
end
