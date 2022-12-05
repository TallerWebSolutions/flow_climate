# frozen_string_literal: true

module Jira
  class JiraProductConfigsController < AuthenticatedController
    before_action :assign_product

    def new
      @jira_product_config = JiraProductConfig.new
      respond_to { |format| format.js }
    end

    def create
      @jira_product_config = JiraProductConfig.new(jira_product_config_params.merge(company: @company, product: @product))
      @jira_product_config.save
      flash[:error] = @jira_product_config.errors.full_messages.join(', ') unless @jira_product_config.valid?
      @jira_product_configs = @product.jira_product_configs.order(:jira_product_key)

      render 'jira/jira_product_configs/create'
    end

    def destroy
      @jira_product_config = JiraProductConfig.find(params[:id])
      @jira_product_config.destroy
      @jira_product_configs = @product.jira_product_configs.order(:jira_product_key)
      render 'jira/jira_product_configs/destroy'
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
