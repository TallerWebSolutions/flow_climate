# frozen_string_literal: true

class DemandsRepository
  include Singleton

  def known_scope_to_date(demands_ids, analysed_date)
    demands_list_data(demands_ids).opened_before_date(analysed_date)
  end

  def remaining_backlog_to_date(demands_ids, analysed_date)
    demands = demands_list_data(demands_ids).kept.opened_before_date(analysed_date)

    demands.where('(end_date IS NULL OR end_date > :analysed_date) AND (commitment_date IS NULL OR commitment_date > :analysed_date)', analysed_date: analysed_date).count
  end

  def committed_demands_to_period(demands, week, year)
    demands.kept.where('EXTRACT(WEEK FROM commitment_date) = :week AND EXTRACT(YEAR FROM commitment_date) = :year', week: week, year: year)
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
    demands_stories_to_projects(projects).where('created_date BETWEEN :start_period AND :end_period', start_period: start_period, end_period: end_period)
  end

  def effort_upstream_grouped_by_month(projects, start_date, end_date)
    effort_upstream_hash = {}
    Demand.kept
          .select('EXTRACT(YEAR from end_date) AS year, EXTRACT(MONTH from end_date) AS month, SUM(effort_upstream) AS computed_sum_effort')
          .where(project_id: projects.map(&:id))
          .to_end_dates(start_date, end_date)
          .order('year, month')
          .group('year, month')
          .map { |group_sum| effort_upstream_hash[[group_sum.year, group_sum.month]] = group_sum.computed_sum_effort.to_f }
    effort_upstream_hash
  end

  def grouped_by_effort_downstream_per_month(projects, start_date, end_date)
    effort_downstream_hash = {}
    Demand.kept
          .select('EXTRACT(YEAR from end_date) AS year, EXTRACT(MONTH from end_date) AS month, SUM(effort_downstream) AS computed_sum_effort')
          .where(project_id: projects.map(&:id))
          .to_end_dates(start_date, end_date)
          .order('year, month')
          .group('year, month')
          .map { |group_sum| effort_downstream_hash[[group_sum.year, group_sum.month]] = group_sum.computed_sum_effort.to_f }
    effort_downstream_hash
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

  def demands_delivered_for_period(demands, start_period, end_period)
    Demand.kept.where(id: demands.map(&:id)).to_end_dates(start_period, end_period)
  end

  def demands_delivered_for_period_accumulated(demands, upper_date_limit)
    Demand.kept.where(id: demands.map(&:id)).where('demands.end_date <= :upper_limit', upper_limit: upper_date_limit)
  end

  def filter_demands_by_text(demands, filter_text)
    return demands.includes(:project) if filter_text.blank?

    demands.includes(:project)
           .joins(:project)
           .joins(:product)
           .left_outer_joins(:portfolio_unit)
           .where('demands.demand_title ILIKE :search_param
                   OR demands.external_id ILIKE :search_param
                   OR projects.name ILIKE :search_param
                   OR portfolio_units.name ILIKE :search_param
                   OR products.name ILIKE :search_param', search_param: "%#{filter_text.downcase}%")
  end

  def flow_status_query(demands, flow_status)
    filtered_demands = demands
    filtered_demands = filtered_demands.not_started if flow_status == 'not_started'
    filtered_demands = filtered_demands.in_wip if flow_status == 'wip'
    filtered_demands = filtered_demands.finished if flow_status == 'delivered'

    filtered_demands
  end

  def demand_type_query(demands, demand_type)
    return demands.where(demand_type: demand_type) if demand_type.present? && demand_type != 'all_types'

    demands
  end

  def class_of_service_query(demands, class_of_service)
    return demands.where(class_of_service: class_of_service) if class_of_service.present? && class_of_service != 'all_classes'

    demands
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
