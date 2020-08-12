# frozen_string_literal: true

class SlackConfigurationsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_team
  before_action :assign_slack_config, only: %i[edit update toggle_active]

  def new
    @slack_configuration = SlackConfiguration.new(team: @team)
    @slack_configurations = @team.slack_configurations.order(:created_at)

    respond_to { |format| format.js { render 'slack_configurations/new' } }
  end

  def create
    read_stages_in_params
    @slack_configuration = SlackConfiguration.new(slack_configuration_params.merge(team: @team, stages_to_notify_transition: @stage_ids))
    @slack_configurations = @team.slack_configurations.order(:created_at)

    if @slack_configuration.save
      respond_to { |format| format.js { render 'slack_configurations/create_update' } }
    else
      respond_to { |format| format.js { render 'slack_configurations/new' } }
    end
  end

  def edit
    @slack_configurations = @team.slack_configurations.order(:created_at)
    respond_to { |format| format.js { render 'slack_configurations/edit' } }
  end

  def update
    @slack_configurations = @team.slack_configurations.order(:created_at)
    read_stages_in_params

    if @slack_configuration.update(slack_configuration_params.merge(stages_to_notify_transition: @stage_ids))
      respond_to { |format| format.js { render 'slack_configurations/create_update' } }
    else
      respond_to { |format| format.js { render 'slack_configurations/edit' } }
    end
  end

  def toggle_active
    @slack_configuration.toggle_active
    respond_to { |format| format.js { render 'slack_configurations/toggle_active' } }
  end

  def index
    @slack_configurations = @team.slack_configurations.order(:created_at)
  end

  private

  def assign_slack_config
    @slack_configuration = SlackConfiguration.find(params[:id])
  end

  def slack_configuration_params
    params.require(:slack_configuration).permit(:room_webhook, :notification_hour, :notification_minute, :weekday_to_notify, :info_type)
  end

  def assign_team
    @team = Team.find(params[:team_id])
  end

  def read_stages_in_params
    @stage_ids = []
    params[:slack_configuration].each_pair { |key, value| @stage_ids << value if key.starts_with?('stage_') }
  end
end
