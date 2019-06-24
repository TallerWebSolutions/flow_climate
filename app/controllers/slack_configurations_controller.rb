# frozen_string_literal: true

class SlackConfigurationsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_team

  def new
    @slack_configuration = SlackConfiguration.new(team: @team)

    respond_to { |format| format.js { render 'slack_configurations/new' } }
  end

  def create
    @slack_configuration = SlackConfiguration.new(slack_configuration_params.merge(team: @team))

    if @slack_configuration.save
      @slack_configurations = @team.slack_configurations
      respond_to { |format| format.js { render 'slack_configurations/create' } }
    else
      respond_to { |format| format.js { render 'slack_configurations/new' } }
    end
  end

  def toggle_active
    @slack_configuration = SlackConfiguration.find(params[:id])
    @slack_configuration.toggle_active
    respond_to { |format| format.js { render 'slack_configurations/toggle_active' } }
  end

  private

  def slack_configuration_params
    params.require(:slack_configuration).permit(:room_webhook, :notification_hour, :notification_minute, :weekday_to_notify, :info_type)
  end

  def assign_team
    @team = Team.find(params[:team_id])
  end
end
