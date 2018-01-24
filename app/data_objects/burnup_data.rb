# frozen_string_literal: true

class BurnupData
  attr_reader :project, :weeks, :ideal, :current, :scope

  def initialize(project)
    @project = project
    @weeks = project.project_weeks
    @ideal = []
    @current = []
    @scope = []
    mount_data
  end

  private

  def mount_data
    total_delivered = 0

    @weeks.each_with_index do |week, index|
      @ideal << ideal_burn(index)
      total_delivered += ProjectResultsRepository.instance.th_in_week_for_project(project, week[0], week[1])
      @current << total_delivered if add_current_th?(week)
      @scope << ProjectResultsRepository.instance.scope_in_week_for_project(project, week[0], week[1])
    end
  end

  def add_current_th?(week)
    week[1] < Time.zone.today.cwyear || (week[0] <= Time.zone.today.cweek && week[1] <= Time.zone.today.cwyear)
  end

  def ideal_burn(index)
    (@project.current_backlog.to_f / @weeks.count.to_f) * (index + 1)
  end
end
