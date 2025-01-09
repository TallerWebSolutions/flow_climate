# frozen_string_literal: true

class FlowEventsController < ApplicationController
  before_action :assign_flow_event, only: %i[destroy edit update show]

  def index
    @flow_events = @company.flow_events.order(event_date: :desc)
  end

  def show; end

  def new
    @flow_event = FlowEvent.new(company: @company, event_date: Time.zone.now)
  end

  def edit
    @projects_by_team = @company.teams.find(@flow_event.team_id).projects.running.order(:name) if @flow_event.team.present?
  end

  def create
    @flow_event = FlowEvent.new(flow_event_params.merge(company: @company, user: Current.user))

    if @flow_event.save
      flash[:notice] = I18n.t('flow_events.create.success')
      redirect_to company_flow_events_path(@company)
    else
      flash[:error] = I18n.t('flow_events.create.error')
      render :new
    end
  end

  def update
    @flow_event.update(flow_event_params)

    redirect_to company_flow_events_path(@company)
  end

  def destroy
    @flow_event.destroy
    @flow_events = @company.flow_events.order(event_date: :desc)
    respond_to { |format| format.js { render 'flow_events/destroy' } }
  end

  private

  def assign_flow_event
    @flow_event = FlowEvent.find(params[:id])
  end

  def flow_event_params
    params.require(:flow_event).permit(:team_id, :project_id, :event_date, :event_end_date, :event_description, :event_type, :event_size)
  end
end
