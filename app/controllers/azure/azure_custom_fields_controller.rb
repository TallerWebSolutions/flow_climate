# frozen_string_literal: true

module Azure
  class AzureCustomFieldsController < AuthenticatedController
    before_action :assign_company

    def create
      @azure_account = @company.azure_account
      @new_azure_custom_field = Azure::AzureCustomField.create(azure_custom_field_params.merge(azure_account: @azure_account))
      @account_custom_fields = @azure_account.azure_custom_fields

      @new_azure_custom_field = Azure::AzureCustomField.new if @new_azure_custom_field.valid?

      respond_to { |format| format.js { render 'azure/azure_custom_fields/create' } }
    end

    def destroy
      @azure_custom_field = @company.azure_account.azure_custom_fields.find(params[:id])
      @azure_custom_field.destroy
      respond_to { |format| format.js { render 'azure/azure_custom_fields/destroy' } }
    end

    private

    def azure_custom_field_params
      params.require(:azure_azure_custom_field).permit(:custom_field_type, :custom_field_name, :field_order)
    end
  end
end
