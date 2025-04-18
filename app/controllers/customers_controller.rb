# frozen_string_literal: true

class CustomersController < ApplicationController
  before_action :assign_customer, only: %i[edit update show destroy add_user_to_customer update_cache remove_user_to_customer]

  def index
    @customers = @company.customers.order(:name)
  end

  def show
    @customers = [@customer]

    @customer_consolidations = build_customer_consolidations(@customer)
    @unscored_demands = @customer.exclusives_demands.unscored_demands.order(external_id: :asc)
    @demands_blocks = @customer.demand_blocks.active.order(block_time: :asc)
    @user_invite = UserInvite.new(invite_object_id: @customer.id, invite_type: :customer)
    @contracts = @customer.contracts.includes([:product]).order(end_date: :desc)
    @contract = Contract.new(customer: @customer)

    build_pressure_and_speed
  end

  def new
    @customer = Customer.new(company: @company)
  end

  def edit; end

  def create
    @customer = Customer.new(customer_params.merge(company: @company))
    return redirect_to company_customers_path(@company) if @customer.save

    render :new
  end

  def update
    @customer.update(customer_params.merge(company: @company))
    return redirect_to company_customers_path(@company) if @customer.save

    render :edit
  end

  def destroy
    return redirect_to company_customers_path(@company) if @customer.destroy

    redirect_to(company_customers_path(@company), flash: { error: @customer.errors.full_messages.join(',') })
  end

  def add_user_to_customer
    invite_email = user_invite_params[:invite_email]

    if invite_email.present?
      flash[:notice] = UserInviteService.instance.invite_customer(@company, @customer.id, invite_email, show_path(user_email: invite_email))
    else
      flash[:error] = I18n.t('user_invites.create.error')
    end

    redirect_to company_customer_path(@company, @customer)
  end

  def remove_user_to_customer
    devise_customers_id = params[:user_id]

    flash[:notice] = UserInviteService.instance.remove_customer(@customer, devise_customers_id)

    redirect_to company_customer_path(@company, @customer)
  end

  def update_cache
    start_date = @customer.start_date
    end_date = @customer.end_date

    cache_date_arrays = TimeService.instance.days_between_of(start_date, end_date)
    cache_date_arrays.each { |cache_date| Consolidations::CustomerConsolidationJob.perform_later(@customer, cache_date) }

    flash[:notice] = I18n.t('general.enqueued')

    redirect_to company_customer_path(@company, @customer)
  end

  private

  def build_customer_consolidations(customer)
    customer_last_data_point = customer.customer_consolidations.order(:consolidation_date).last
    customer.customer_consolidations.monthly_data.or(customer.customer_consolidations.where(id: customer_last_data_point&.id)).distinct.order(:consolidation_date)
  end

  def build_pressure_and_speed
    @flow_pressure = @customer_consolidations.last&.flow_pressure || @customer.total_flow_pressure
    @average_speed = DemandService.instance.average_speed(@customer.exclusives_demands)
  end

  def assign_customer
    @customer = @company.customers.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:name)
  end

  def user_invite_params
    params.require(:user_invite).permit(:invite_email, :invite_object_id, :invite_type)
  end
end
