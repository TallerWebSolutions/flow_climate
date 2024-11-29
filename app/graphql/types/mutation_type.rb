# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_portfolio_unit, mutation: Mutations::CreatePortfolioUnitMutation
    field :create_product_risk_review, mutation: Mutations::CreateProductRiskReview
    field :create_project_additional_hours, mutation: Mutations::CreateProjectAdditionalHoursMutation
    field :create_service_delivery_review, mutation: Mutations::CreateServiceDeliveryReviewMutation
    field :create_service_delivery_review_action, mutation: Mutations::CreateServiceDeliveryReviewActionMutation
    field :create_team, mutation: Mutations::CreateTeamMutation
    field :create_work_item_type, mutation: Mutations::CreateWorkItemTypeMutation
    field :delete_demand, mutation: Mutations::DeleteDemandMutation
    field :delete_product_risk_review, mutation: Mutations::DeleteProductRiskReview
    field :delete_service_delivery_review, mutation: Mutations::DeleteServiceDeliveryReviewMutation
    field :delete_team, mutation: Mutations::DeleteTeamMutation
    field :delete_team_member, mutation: Mutations::DeleteTeamMemberMutation
    field :delete_work_item_type, mutation: Mutations::DeleteWorkItemTypeMutation
    field :discard_demand, mutation: Mutations::DiscardDemandMutation
    field :generate_project_cache, mutation: Mutations::GenerateProjectCacheMutation
    field :generate_replenishing_cache, mutation: Mutations::GenerateReplenishingCacheMutation
    field :me, Types::UserType, null: false
    field :save_membership, mutation: Mutations::SaveMembershipMutation
    field :send_auth_token, mutation: Mutations::SendAuthTokenMutation
    field :synchronize_jira_project_config, mutation: Mutations::SynchronizeJiraProjectConfigMutation
    field :toggle_product_user, mutation: Mutations::ToggleProductUserMutation
    field :update_jira_project_config, mutation: Mutations::UpdateJiraProjectConfigMutation
    field :update_portfolio_unit, mutation: Mutations::UpdatePortfolioUnitMutation
    field :update_team, mutation: Mutations::UpdateTeamMutation
    field :update_team_member, mutation: Mutations::UpdateTeamMemberMutation

    def me
      context[:current_user]
    end
  end
end
