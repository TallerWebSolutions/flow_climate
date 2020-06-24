# frozen_string_literal: true

class CustomersController < AuthenticatedController
  before_action :assign_company
  before_action :assign_customer, only: %i[edit update show destroy add_user_to_customer]

  def index
    @customers = @company.customers.order(:name)
  end

  def show
    @customers = [@customer]
    @customer_dashboard_data = CustomerDashboardData.new(customer_demands)
    @demands_chart_adapter = Highchart::DemandsChartsAdapter.new(customer_demands, start_date, end_date, 'month')
    @customer_flow_information = Flow::CustomerFlowInformation.new(@customer, 'month')
    @user_invite = UserInvite.new(invite_object_id: @customer.id, invite_type: :customer)
    @contracts = @customer.contracts.order(end_date: :desc)
    @contract = Contract.new(customer: @customer)
  end

  def new
    @customer = Customer.new(company: @company)
  end

  def create
    @customer = Customer.new(customer_params.merge(company: @company))
    return redirect_to company_customers_path(@company) if @customer.save

    render :new
  end

  def edit; end

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
      flash[:notice] = UserInviteService.instance.invite_customer(@company, @customer.id, invite_email, new_devise_customer_registration_url(user_email: invite_email))
    else
      flash[:error] = I18n.t('user_invites.create.error')
    end

    redirect_to company_customer_path(@company, @customer)
  end

  private

  def customer_demands
    @customer_demands ||= @customer.exclusives_demands.finished.order(:end_date)
  end

  def start_date
    @start_date ||= customer_demands.map(&:end_date).compact.min
  end

  def end_date
    @end_date ||= [customer_demands.map(&:end_date).compact.max, Time.zone.today].compact.min
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
