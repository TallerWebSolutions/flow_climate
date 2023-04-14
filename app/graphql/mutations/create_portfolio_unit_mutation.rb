module Mutations
  class CreatePortfolioUnitMutation < Mutations::BaseMutation
    argument :parent_id, ID, required: false
    argument :product_id, ID, required: true
    argument :name, String, required: true
    argument :portfolio_unit_type, String, required: true
    argument :jira_machine_name, String, required: true

    field :portfolio_unit, Types::PortfolioUnitType, null: false
    field :status_message, Types::CreateResponses, null: false

    def resolve(parent_id:, product_id:, name:, portfolio_unit_type:, jira_machine_name:)
      product = Product.find_by(id: product_id)
      params = { parent_id: parent_id, product_id: product_id, name: name, portfolio_unit_type: portfolio_unit_type, jira_portfolio_unit_config_attributes: { jira_field_name: jira_machine_name } }
      portfolioUnit = PortfolioUnit.new(params.merge(product: product))

      if portfolioUnit.save
        { status_message: 'SUCCESS', portfolio_unit: portfolioUnit }
      else
        { status_message: 'FAIL' }
      end
    end
  end
end