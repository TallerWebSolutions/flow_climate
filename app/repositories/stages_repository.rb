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

  def add_where_to_demand_transitions(stage, transition_date_field)
    stage.demand_transitions.where("#{transition_date_field} IS NOT NULL")
  end
end
