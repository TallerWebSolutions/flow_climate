# frozen_string_literal: true

class SlackConfigurationsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_team
  before_action :assign_slack_config, only: %i[edit update toggle_active]

  def new
    @slack_configuration = SlackConfiguration.new(team: @team)

    respond_to { |format| format.js { render 'slack_configurations/new' } }
  end

  def create
    @slack_configuration = SlackConfiguration.new(slack_configuration_params.merge(team: @team))

    if @slack_configuration.save
      @slack_configurations = @team.slack_configurations.order(:created_at)
      respond_to { |format| format.js { render 'slack_configurations/create_update' } }
    else
      respond_to { |format| format.js { render 'slack_configurations/new' } }
    end
  end

  def edit
    respond_to { |format| format.js { render 'slack_configurations/edit' } }
  end

  def update
    if @slack_configuration.update(slack_configuration_params)
      @slack_configurations = @team.slack_configurations.order(:created_at)
      respond_to { |format| format.js { render 'slack_configurations/create_update' } }
    else
      respond_to { |format| format.js { render 'slack_configurations/edit' } }
    end
  end

  def toggle_active
    @slack_configuration.toggle_active
    respond_to { |format| format.js { render 'slack_configurations/toggle_active' } }
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
end
