# frozen_string_literal: true

class SlackConfigurationsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_slack_config, only: %i[edit update toggle_active]

  def new
    @slack_configuration = SlackConfiguration.new(team: @team)
    assign_teams
    assign_customers
    assign_stages
  end

  def create
    read_stages_in_params
    @slack_configuration = SlackConfiguration.new(slack_configuration_params.merge(stages_to_notify_transition: @stage_ids))

    if @slack_configuration.save
      redirect_to company_slack_configurations_path
    else
      assign_stages
      assign_teams
      assign_customers
      render :new
    end
  end

  def edit
    @slack_configurations = SlackConfiguration.all.order(:created_at)
    assign_teams
    assign_customers
    assign_stages
  end

  def update
    @slack_configurations = SlackConfiguration.all.order(:created_at)
    read_stages_in_params

    if @slack_configuration.update(slack_configuration_params.merge(stages_to_notify_transition: @stage_ids))
      redirect_to company_slack_configurations_path
    else
      assign_teams
      assign_customers
      assign_stages
      render :edit
    end
  end

  def toggle_active
    @slack_configuration.toggle_active
    respond_to { |format| format.js { render 'slack_configurations/toggle_active' } }
  end

  def index
    @slack_configurations = SlackConfiguration.all.order(:created_at)
  end

  private

  def assign_stages
    @stages = @company.stages.where('stages.order >= 0').order(:integration_pipe_id, :order)
  end

  def assign_teams
    @teams = @company.teams
  end

  def assign_customers
    @customers = @company.customers
  end

  def assign_slack_config
    @slack_configuration = SlackConfiguration.find(params[:id])
  end

  def slack_configuration_params
    params.require(:slack_configuration).permit(:room_webhook, :notification_hour, :notification_minute, :weekday_to_notify, :info_type, :config_type, :team_id, :customer_id)
  end

  def read_stages_in_params
    @stage_ids = []

    return unless slack_configuration_params[:info_type] == 'demand_state_changed'

    params.each_pair { |key, value| @stage_ids << value if key.starts_with?('stage_') }
  end
end
