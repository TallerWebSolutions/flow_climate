# frozen_string_literal: true

module Mutations
  class UpdatePortfolioUnitMutation < Mutations::BaseMutation
    argument :jira_machine_name, String, required: true
    argument :name, String, required: true
    argument :parent_id, ID, required: false
    argument :portfolio_unit_type, String, required: true
    argument :product_id, ID, required: true
    argument :unit_id, ID, required: true

    field :status_message, Types::UpdateResponses, null: false

    def resolve(parent_id:, product_id:, unit_id:, name:, portfolio_unit_type:, jira_machine_name:)
      return { status_message: 'FAIL' } if PortfolioUnit.find_by(id: unit_id).blank?

      product = Product.find_by(id: product_id)
      params = { parent_id: parent_id, product_id: product_id, name: name, portfolio_unit_type: portfolio_unit_type, jira_portfolio_unit_config_attributes: { jira_field_name: jira_machine_name } }
      PortfolioUnit.find_by(id: unit_id).update(params.merge(product: product))

      { status_message: 'SUCCESS' }
    end
  end
end
