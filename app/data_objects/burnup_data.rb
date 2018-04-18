# frozen_string_literal: true

class BurnupData < ChartData
  attr_reader :weeks, :ideal, :current, :scope

  def initialize(projects, weeks)
    @projects = projects
    @weeks = weeks
    @ideal = []
    @current = []
    @scope = []

    mount_burnup_data
  end

  private

  def mount_burnup_data
    @weeks.each_with_index do |week_year, index|
      @ideal << ideal_burn(index)
      week = week_year[0]
      year = week_year[1]
      upstream_total_delivered = throughput_to_projects_and_stream(week, year, projects, :throughput_upstream)
      downstream_total_delivered = throughput_to_projects_and_stream(week, year, projects, :throughput_downstream)
      @current << upstream_total_delivered + downstream_total_delivered if add_data_to_chart?(week_year)
      @scope << ProjectResultsRepository.instance.scope_in_week_for_projects(projects, week, year)
    end
  end

  def ideal_burn(index)
    (projects.sum(&:last_week_scope).to_f / @weeks.count.to_f) * (index + 1)
  end
end
