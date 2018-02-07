# frozen_string_literal: true

class CompaniesController < AuthenticatedController
  before_action :assign_company, except: %i[new create index]

  def index
    @companies = current_user.companies.order(:name)
  end

  def show
    @financial_informations = @company.financial_informations.order(finances_date: :desc)
    @teams = @company.teams.order(:name)
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    @company.add_user(current_user)
    return redirect_to company_path(@company) if @company.save
    render :new
  end

  def edit
    assign_users_in_company
  end

  def update
    @company.update(company_params)
    return redirect_to company_path(@company) if @company.save
    assign_users_in_company
    render :edit
  end

  def add_user
    user = User.find_by(email: params[:user_email])
    return redirect_to(edit_company_path(@company), error: t('general.user_not_found')) if user.blank?
    @company.add_user(user)
    redirect_to edit_company_path(@company)
  end

  def send_company_bulletin
    UserNotifierMailer.company_weekly_bulletin(User.where(id: current_user.id), @company).deliver
    flash[:notice] = t('companies.send_company_bulletin.queued')
    redirect_to company_path(@company)
  end

  private

  def assign_users_in_company
    @users_in_company = @company.users.order(:first_name, :last_name)
  end

  def assign_company
    @company = Company.find(params[:id])
    not_found unless current_user.companies.include?(@company)
  end

  def company_params
    params.require(:company).permit(:name, :abbreviation)
  end
end
