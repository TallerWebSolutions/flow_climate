# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :teams, [Types::Teams::TeamType], null: true, description: 'Set of teams'

    field :team, Types::Teams::TeamType, null: true, description: 'A team with consolidations' do
      argument :id, ID
    end

    field :risk_review, Types::RiskReviewType, null: true, description: 'A plain risk review' do
      argument :id, ID, required: true
    end

    field :project, Types::ProjectType, null: true, description: 'A plain project' do
      argument :id, ID
    end

    field :product, Types::ProductType, null: true, description: 'A plain product' do
      argument :slug, String
    end

    field :team_member, Types::Teams::TeamMemberType, null: true, description: 'A plain team_member' do
      argument :id, ID
    end

    field :team_members, [Types::Teams::TeamMemberType], null: true, description: 'Team Members of a Company' do
      argument :active, Boolean, required: false
      argument :company_id, Int, required: true
      argument :team_id, Int, required: false
    end

    field :membership, Types::Teams::MembershipType, null: true, description: 'A plain membership' do
      argument :id, ID
    end

    # TODO: this should be get inside the Project query
    field :project_consolidations, [Types::ProjectConsolidationType], null: true, description: 'Project consolidations' do
      argument :last_data_in_week, Boolean, required: false
      argument :project_id, ID
    end

    field :demands_list, Types::DemandsListType, null: true, description: 'Query for demands' do
      argument :search_options, Types::DemandsQueryAttributes, required: true
    end

    field :demand, Types::DemandType, null: true, description: 'A single demand by external ID' do
      argument :external_id, String, required: true
    end

    field :project_additional_hours, [Types::ProjectAdditionalHourType], null: true, description: 'A list of project additional hours' do
      argument :project_id, ID, required: true
    end

    field :me, Types::UserType, null: false

    field :projects, [Types::ProjectType], null: false, description: 'A list of projects using the arguments as search parameters' do
      argument :company_id, Int, required: true
      argument :end_date, GraphQL::Types::ISO8601Date, required: false
      argument :name, String, required: false
      argument :start_date, GraphQL::Types::ISO8601Date, required: false
      argument :status, String, required: false
    end

    field :portfolio_unit_by_id, Types::PortfolioUnitType, null: false do
      argument :id, ID, required: true
    end

    field :jira_portfolio_unit_by_id, String, null: true do
      argument :id, ID, required: true
    end

    field :jira_project_config, Types::JiraProjectConfigType, null: false do
      argument :id, ID, required: true
    end

    field :jira_project_config_list, [Types::JiraProjectConfigType], null: true do
      argument :id, ID, required: true
    end

    field :work_item_types, [Types::WorkItemTypeType], null: false, description: 'A list of work item types registered to the logged user last company'

    field :service_delivery_review, Types::ServiceDeliveryReviewType, null: true do
      argument :review_id, ID, required: true
    end

    field :service_delivery_reviews, [Types::ServiceDeliveryReviewType], null: false do
      argument :product_id, ID, required: true
    end

    field :memberships, [Types::Teams::MembershipType], null: false do
      argument :team_id, Int, required: true
    end

    def teams
      me.last_company.teams.preload(:company) if me.last_company.present?
    end

    def service_delivery_review(review_id:)
      ServiceDeliveryReview.find_by(id: review_id)
    end

    def service_delivery_reviews(product_id:)
      ServiceDeliveryReview.where(product_id: product_id).order(:meeting_date)
    end

    def portfolio_unit_by_id(id:)
      PortfolioUnit.find(id)
    end

    def jira_portfolio_unit_by_id(id:)
      return '' if PortfolioUnit.find(id).jira_portfolio_unit_config.blank?

      PortfolioUnit.find(id).jira_portfolio_unit_config[:jira_field_name]
    end

    def team(id:)
      Team.find(id)
    end

    def project_consolidations(project_id:, last_data_in_week: true)
      Consolidations::ProjectConsolidation.where(project_id: project_id, last_data_in_week: last_data_in_week).order(:consolidation_date)
    end

    def project(id:)
      Project.find(id)
    end

    def risk_review(id:)
      RiskReview.find(id)
    end

    def jira_project_config(id:)
      Jira::JiraProjectConfig.find_by(id: id)
    end

    def jira_project_config_list(id:)
      Jira::JiraProjectConfig.where(project_id: id)
    end

    def product(slug:)
      Product.friendly.find(slug)
    end

    def team_member(id:)
      TeamMember.find(id)
    end

    def membership(id:)
      Membership.find(id)
    end

    def memberships(team_id:)
      Membership.joins(:team_member).where(team_id: team_id).order('team_members.name')
    end

    def demands_list(search_options:)
      demands = base_demands(search_options)

      sort_direction = search_options.sort_direction || 'DESC'
      demands = demands.order(end_date: sort_direction, created_date: sort_direction)

      demands = demands.discarded if search_options.demand_status == 'DISCARDED_DEMANDS'

      total_effort = demands.sum { |demand| demand.demand_efforts.sum(&:effort_value) }
      if search_options.per_page.present?
        demands_paged = demands.page(search_options.page_number).per(search_options.per_page)
        { 'total_count' => demands.count, 'last_page' => demands_paged.last_page?, 'total_pages' => demands_paged.total_pages, 'demands' => demands_paged, 'total_effort' => total_effort }
      else
        { 'total_count' => demands.count, 'last_page' => true, 'total_pages' => 1, 'demands' => demands, 'total_effort' => total_effort }
      end
    end

    def demand(external_id:)
      Demand.where('lower(external_id) = ?', external_id.downcase).first
    end

    def team_members(company_id:, active: nil)
      company = Company.find(company_id)
      if active.nil?
        company.team_members.order(:name)
      elsif active
        company.team_members.active.order(:name)
      else
        company.team_members.inactive.order(:name)
      end
    end

    def project_additional_hours(project_id:)
      Project.find(project_id).project_additional_hours.order(:event_date)
    end

    def me
      context[:current_user]
    end

    def projects(company_id:, name: nil, status: nil, start_date: nil, end_date: nil)
      ProjectsRepository.instance.search(company_id, project_name: name, project_status: status, start_date: start_date, end_date: end_date)
    end

    def work_item_types
      me.last_company.work_item_types.order(:item_level, :name)
    end

    private

    def base_demands(search_options)
      demands = user_demands(project_id: search_options.project_id, product_id: search_options.product_id)

      DemandService.instance.search_engine(
        demands, search_options.start_date, search_options.end_date, search_options.search_text,
        search_options.demand_status, search_options.demand_type, search_options.demand_class_of_service, search_options.demand_tags,
        search_options.team_id
      )
    end

    def user_demands(project_id:, product_id:)
      demands = current_user.last_company.demands
      demands = demands.for_project(project_id) if project_id.present?
      demands = demands.for_product(product_id) if product_id.present?

      demands
    end
  end
end
