# frozen_string_literal: true

class FlowEventsController < AuthenticatedController
  before_action :assign_company
  before_action :assign_flow_event, only: %i[destroy edit update show]

  def new
    @flow_event = FlowEvent.new(company: @company, event_date: Time.zone.now)
  end

  def create
    @flow_event = FlowEvent.new(flow_event_params.merge(company: @company, user: current_user))

    if @flow_event.save
      flash[:notice] = I18n.t('flow_events.create.success')
      redirect_to company_flow_events_path(@company)
    else
      flash[:error] = I18n.t('flow_events.create.error')
      render :new
    end
  end

  def destroy
    @flow_event.destroy
    @flow_events = @company.flow_events.order(event_date: :desc)
    respond_to { |format| format.js { render 'flow_events/destroy' } }
  end

  def index
    @flow_events = @company.flow_events.order(event_date: :desc)
  end

  def edit; end

  def update
    @flow_event.update(flow_event_params)
    @demands_for_event_form = @flow_event.project.demands.kept.in_flow(Time.zone.now)

    redirect_to company_flow_events_path(@company)
  end

  def show; end

  private

  def assign_flow_event
    @flow_event = FlowEvent.find(params[:id])
  end

  def flow_event_params
    params.require(:flow_event).permit(:team_id, :project_id, :event_date, :event_end_date, :event_description, :event_type, :event_size)
  end
end
