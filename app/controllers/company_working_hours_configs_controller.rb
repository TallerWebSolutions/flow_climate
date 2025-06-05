# frozen_string_literal: true

class CompanyWorkingHoursConfigsController < ApplicationController
  before_action :user_gold_check
  before_action :assign_company
  before_action :assign_config, only: %i[edit update destroy]

  def index
    @configs = @company.company_working_hours_configs.order(start_date: :desc)
  end

  def new
    @config = @company.company_working_hours_configs.new
  end

  def edit; end

  def create
    @config = @company.company_working_hours_configs.new(config_params)

    # Encerrar a configuração anterior automaticamente
    previous_config = @company.company_working_hours_configs
                              .where('start_date < ?', @config.start_date)
                              .where('end_date IS NULL OR end_date >= ?', @config.start_date)
                              .order(start_date: :desc)
                              .first
    previous_config.update(end_date: @config.start_date - 1.day) if previous_config.present?

    if @config.save
      redirect_to company_company_working_hours_configs_path(@company), notice: I18n.t('company_working_hours_configs.create.success')
    else
      render :new
    end
  end

  def update
    if @config.update(config_params)
      redirect_to company_company_working_hours_configs_path(@company), notice: I18n.t('company_working_hours_configs.update.success')
    else
      render :edit
    end
  end

  def destroy
    @config.update(end_date: Time.zone.today)
    redirect_to company_company_working_hours_configs_path(@company), notice: I18n.t('company_working_hours_configs.destroy.success')
  end

  private

  def assign_config
    @config = @company.company_working_hours_configs.find(params[:id])
  end

  def config_params
    params.require(:company_working_hours_config).permit(:hours_per_day, :start_date, :end_date)
  end
end
