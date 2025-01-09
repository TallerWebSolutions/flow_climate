# frozen_string_literal: true

module Jira
  class JiraProductConfigsController < ApplicationController
    before_action :assign_product

    def index
      @jira_product_configs = @product.jira_product_configs
    end

    def new
      @jira_product_config = JiraProductConfig.new
    end

    def create
      @jira_product_config = JiraProductConfig.create(jira_product_config_params.merge(company: @company, product: @product))
      if @jira_product_config.valid?
        flash[:error] = I18n.t('jira_project_configs.create.success')
        redirect_to company_product_jira_product_configs_path(@company, @product)
      else
        flash[:error] = @jira_product_config.errors.full_messages.join(', ')
        @jira_product_configs = @product.jira_product_configs.order(:jira_product_key)
        render :new
      end
    end

    def destroy
      @jira_product_config = JiraProductConfig.find(params[:id])
      @jira_product_config.destroy
      @jira_product_configs = @product.jira_product_configs.order(:jira_product_key)

      redirect_to company_product_jira_product_configs_path(@company, @product)
    end

    private

    def jira_product_config_params
      params.require(:jira_jira_product_config).permit(:jira_product_key)
    end

    def assign_product
      @product = Product.friendly.find(params[:product_id])
    end
  end
end
