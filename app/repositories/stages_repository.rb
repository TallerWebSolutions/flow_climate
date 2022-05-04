# frozen_string_literal: true

class StagesRepository
  include Singleton

  def qty_hits_by_weekday(stage, transition_date_field)
    add_where_to_demand_transitions(stage, transition_date_field).group("EXTRACT(DOW FROM #{transition_date_field})").order(Arel.sql("EXTRACT(DOW FROM #{transition_date_field})")).count
  end

  def qty_hits_by_day(stage, transition_date_field)
    add_where_to_demand_transitions(stage, transition_date_field).group("EXTRACT(DAY FROM #{transition_date_field})").order(Arel.sql("EXTRACT(DAY FROM #{transition_date_field})")).count
  end

  def qty_hits_by_hour(stage, transition_date_field)
    add_where_to_demand_transitions(stage, transition_date_field).group("EXTRACT(HOUR FROM #{transition_date_field})").order(Arel.sql("EXTRACT(HOUR FROM #{transition_date_field})")).count
  end

  def average_seconds_in_stage_per_month(stage)
    stage.demand_transitions.select('EXTRACT(YEAR FROM last_time_in) AS year, EXTRACT(MONTH FROM last_time_in) AS month, EXTRACT(EPOCH FROM AVG(demand_transitions.last_time_out - demand_transitions.last_time_in)::INTERVAL) AS avg_duration').group('EXTRACT(YEAR FROM last_time_in)', 'EXTRACT(MONTH FROM last_time_in)').order(Arel.sql('EXTRACT(YEAR FROM last_time_in)'), Arel.sql('EXTRACT(MONTH FROM last_time_in)')).map { |avg| [avg.year, avg.month, avg.avg_duration] }
  end

  def hours_per_stage(projects, stream, stage_level, limit_date)
    stages_transitions_time = if stage_level == :coordination
                                stages_time_to_coordination_level(limit_date, projects, stream)
                              else
                                stages_time_to_team_level(limit_date, projects, stream)
                              end

    stages_transitions_time.group('stages.name, stages.order')
                           .order('stages.order, stages.name')
                           .map { |group_sum| [group_sum.name, group_sum.sum_duration] }
  end

  def save_stage(stage, stage_params)
    team_id = stage_params.delete(:team_id)
    team = Team.find_by(id: team_id)
    stage.add_team(team) if team.present?

    stage.update(stage_params)
    team = stage.teams.first
    stage.projects = (stage.projects + team.projects).uniq if team.present?
    stage.save

    stage
  end

  private

  def stages_time_to_team_level(limit_date, projects, stream)
    Stage.select('stages.name, SUM(demand_transitions.transition_time_in_sec) AS sum_duration')
         .joins('left join demand_transitions AS demand_transitions on demand_transitions.stage_id = stages.id')
         .joins('left join demands AS demands on demand_transitions.demand_id = demands.id')
         .where(stages: { stage_level: 0 })
         .where(demands: { project_id: projects.map(&:id) })
         .where('stages.end_point = false AND demand_transitions.last_time_in >= :limit_date AND demand_transitions.last_time_out IS NOT NULL AND stages.stage_stream = :stage_stream',
                limit_date: limit_date.beginning_of_day, stage_stream: Stage.stage_streams[stream])
  end

  def stages_time_to_coordination_level(limit_date, projects, stream)
    Stage.select('stages.name, SUM(demand_transitions.transition_time_in_sec) AS sum_duration')
         .joins('left join stages as team_stages on stages.id = team_stages.parent_id')
         .joins('left join demand_transitions AS demand_transitions on demand_transitions.stage_id = team_stages.id')
         .joins('left join demands AS demands on demand_transitions.demand_id = demands.id')
         .where(stages: { stage_level: 1 })
         .where(demands: { project_id: projects.map(&:id) })
         .where('stages.end_point = false AND demand_transitions.last_time_in >= :limit_date AND demand_transitions.last_time_out IS NOT NULL AND stages.stage_stream = :stage_stream',
                limit_date: limit_date.beginning_of_day, stage_stream: Stage.stage_streams[stream])
  end

  def add_where_to_demand_transitions(stage, transition_date_field)
    stage.demand_transitions.where("#{transition_date_field} IS NOT NULL")
  end
end
