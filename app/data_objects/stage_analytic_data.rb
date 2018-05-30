# frozen_string_literal: true

class StageAnalyticData
  attr_reader :entrances_per_weekday, :entrances_per_day, :entrances_per_hour, :out_per_weekday, :out_per_day, :out_per_hour, :avg_time_in_stage_per_month

  def initialize(stage)
    build_hits_per_weekday(stage)
    build_hits_per_day(stage)
    build_hits_per_hour(stage)
    build_avg_time_in_stage(stage)
  end

  private

  def build_hits_per_weekday(stage)
    entrance_hits_per_weekday = StagesRepository.instance.qty_hits_by_weekday(stage, :last_time_in).transform_keys { |key| I18n.t('date.day_names')[key] }
    @entrances_per_weekday = build_column_values(entrance_hits_per_weekday)

    out_hits_per_weekday = StagesRepository.instance.qty_hits_by_weekday(stage, :last_time_out).transform_keys { |key| I18n.t('date.day_names')[key] }
    @out_per_weekday = build_column_values(out_hits_per_weekday)
  end

  def build_hits_per_day(stage)
    entrance_hits_per_day = StagesRepository.instance.qty_hits_by_day(stage, :last_time_in)
    @entrances_per_day = build_column_values(entrance_hits_per_day)

    out_hits_per_day = StagesRepository.instance.qty_hits_by_day(stage, :last_time_out)
    @out_per_day = build_column_values(out_hits_per_day)
  end

  def build_hits_per_hour(stage)
    entrance_hits_per_hour = StagesRepository.instance.qty_hits_by_hour(stage, :last_time_in)
    @entrances_per_hour = build_column_values(entrance_hits_per_hour)

    out_hits_per_hour = StagesRepository.instance.qty_hits_by_hour(stage, :last_time_out)
    @out_per_hour = build_column_values(out_hits_per_hour)
  end

  def build_column_values(count_per_time_unit)
    hash_to_chart = {}
    highest_value = count_per_time_unit.max_by { |_k, v| v }

    count_per_time_unit.each do |x_axis, y_axis|
      color = 'rgb(73, 142, 142)'
      color = 'rgb(247, 229, 83)' if highest_value[0] == x_axis
      hash_to_chart[x_axis] = { y: y_axis, color: color }
    end
    hash_to_chart
  end

  def build_avg_time_in_stage(stage)
    @avg_time_in_stage_per_month = {}
    avg_per_month = StagesRepository.instance.average_seconds_in_stage_per_month(stage)

    avg_per_month.each do |year, month, seconds_avg_in_month|
      @avg_time_in_stage_per_month["#{I18n.t('date.month_names')[month]}/#{year.to_i}"] = { y: (seconds_avg_in_month || 0) / 1.hour }
    end
  end
end
