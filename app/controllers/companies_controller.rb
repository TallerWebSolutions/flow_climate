# frozen_string_literal: true

class CompaniesController < AuthenticatedController
  before_action :assign_company, except: %i[new create index]

  def index
    @companies = current_user.companies.order(:name)
  end

  def show
    @financial_informations = @company.financial_informations.order(finances_date: :desc)
    @team_members = @company.team_members.order(:name)
  end

  def new
    @company = Company.new
  end

  def create
    @company = Company.new(company_params)
    @company.users << current_user
    return redirect_to company_path(@company) if @company.save
    render :new
  end

  private

  def assign_company
    @company = Company.find(params[:id])
    not_found unless current_user.companies.include?(@company)
  end

  def company_params
    params.require(:company).permit(:name)
  end
end
