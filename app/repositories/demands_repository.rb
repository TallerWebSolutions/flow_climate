# frozen_string_literal: true

class DemandsRepository
  include Singleton

  def known_scope_to_date(demands_ids, analysed_date)
    demands_list_data(demands_ids).opened_before_date(analysed_date)
  end

  def remaining_backlog_to_date(demands_ids, analysed_date)
    demands = demands_list_data(demands_ids).kept.opened_before_date(analysed_date)

    demands.where('(demands.end_date IS NULL OR demands.end_date > :analysed_date) AND (demands.commitment_date IS NULL OR demands.commitment_date > :analysed_date)', analysed_date: analysed_date).count
  end

  def committed_demands_to_period(demands, week, year)
    demands.kept.where('EXTRACT(WEEK FROM commitment_date) = :week AND EXTRACT(YEAR FROM commitment_date) = :year', week: week, year: year)
  end

  def wip_count(demands_ids, date = Time.zone.now)
    demands = demands_list_data(demands_ids).kept.opened_before_date(date)

    demands.where('(demands.end_date IS NULL OR demands.end_date > :analysed_date) AND (demands.commitment_date <= :analysed_date)', analysed_date: date.end_of_day).count
  end

  def demands_delivered_grouped_by_projects_to_period(demands, start_period, end_period)
    throughput_to_period(demands, start_period, end_period).group_by(&:project_name)
  end

  def throughput_to_period(demands, start_period, end_period)
    demands.kept.to_end_dates(start_period, end_period)
  end

  def throughput_to_products_team_and_period(products, team, start_period, end_period)
    Demand.kept.where(product_id: products, team: team).to_end_dates(start_period, end_period)
  end

  def created_to_projects_and_period(projects, start_period, end_period)
    demands_stories_to_projects(projects).where('demands.created_date BETWEEN :start_period AND :end_period', start_period: start_period, end_period: end_period)
  end

  def demands_delivered_for_period(demands, start_period, end_period)
    Demand.kept.where(id: demands.map(&:id)).to_end_dates(start_period, end_period)
  end

  def delivered_hours_in_month_for_projects(projects, date = Time.zone.today)
    demands_for_projects_finished_in_period(projects, date.beginning_of_month, date.end_of_month).sum(:effort_downstream) + demands_for_projects_finished_in_period(projects, date.beginning_of_month, date.end_of_month).sum(:effort_upstream)
  end

  def upstream_throughput_in_month_for_projects(projects, date = Time.zone.today)
    demands_for_projects_finished_in_period(projects, date.beginning_of_month, date.end_of_month).finished_in_upstream
  end

  def downstream_throughput_in_month_for_projects(projects, date = Time.zone.today)
    demands_for_projects_finished_in_period(projects, date.beginning_of_month, date.end_of_month).finished_in_downstream
  end

  def demands_delivered_for_period_accumulated(demands, upper_date_limit)
    Demand.kept.where(id: demands.map(&:id)).where('demands.end_date <= :upper_limit', upper_limit: upper_date_limit)
  end

  def filter_demands_by_text(demands, filter_text)
    return demands.includes(:project) if filter_text.blank?

    searched_demands = demands.includes(:project)
                              .left_outer_joins(:project)
                              .left_outer_joins(:product)
                              .left_outer_joins(:customer)
                              .left_outer_joins(:portfolio_unit)
                              .left_outer_joins(item_assignments: { membership: :team_member })
                              .where('demands.demand_title ILIKE :search_param
                                      OR demands.external_id ILIKE :search_param
                                      OR projects.name ILIKE :search_param
                                      OR portfolio_units.name ILIKE :search_param
                                      OR team_members.name ILIKE :search_param
                                      OR products.name ILIKE :search_param
                                      OR customers.name ILIKE :search_param', search_param: "%#{filter_text.downcase}%").uniq

    Demand.where(id: searched_demands.map(&:id))
  end

  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/PerceivedComplexity
  def flow_status_query(demands, flow_status)
    return demands if flow_status.blank? || flow_status.include?('all_demands')

    filtered_demands = []
    filtered_demands << demands.not_started.map(&:id) if flow_status.include?('not_started')
    filtered_demands << demands.in_wip.map(&:id) if flow_status.include?('wip')
    filtered_demands << demands.finished.map(&:id) if flow_status.include?('delivered')

    Demand.where(id: filtered_demands.flatten)
  end

  def demand_type_query(demands, demand_type)
    return demands.where(demand_type: demand_type) if demand_type.present? && demand_type.exclude?('all_types')

    demands
  end

  def demand_tags_query(demands, demand_tags)
    return demands.where('lower(demand_tags::text)::varchar[] @> lower(ARRAY[?]::text)::varchar[]', demand_tags) if demand_tags.present?

    demands
  end

  def class_of_service_query(demands, class_of_service)
    return demands.where(class_of_service: class_of_service) if class_of_service.present? && class_of_service.exclude?('all_classes')

    demands
  end

  def team_query(demands, team_id)
    return demands.joins(:team).where(team_id: team_id) if team_id.present?

    demands
  end

  def lead_time_zone_count(demands, lower_limit, higher_limit)
    if lower_limit.present? && higher_limit.blank?
      demands.finished_with_leadtime.where('leadtime <= :lead_time_zone', lead_time_zone: lower_limit).count
    elsif lower_limit.present? && higher_limit.present?
      demands.finished_with_leadtime.where('leadtime > :previous_zone AND leadtime <= :lead_time_zone', previous_zone: lower_limit, lead_time_zone: higher_limit).count
    else
      demands.finished_with_leadtime.where('leadtime > :previous_zone', previous_zone: higher_limit).count
    end
  end

  private

  def demands_list_data(demands_ids)
    Demand.where(id: demands_ids)
  end

  def demands_stories_to_projects(projects)
    Demand.kept.where(project_id: projects.map(&:id))
  end

  def demands_for_projects_finished_in_period(projects, start_period, end_period)
    Demand.kept.where(project_id: projects).to_end_dates(start_period, end_period)
  end
end
