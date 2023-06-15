# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_product_risk_review, mutation: Mutations::CreateProductRiskReview
    field :delete_product_risk_review, mutation: Mutations::DeleteProductRiskReview

    field :create_project_additional_hours, mutation: Mutations::CreateProjectAdditionalHoursMutation

    field :create_team, mutation: Mutations::CreateTeamMutation
    field :delete_team, mutation: Mutations::DeleteTeamMutation
    field :update_team, mutation: Mutations::UpdateTeamMutation

    field :delete_team_member, mutation: Mutations::DeleteTeamMemberMutation

    field :create_work_item_type, mutation: Mutations::CreateWorkItemTypeMutation
    field :delete_work_item_type, mutation: Mutations::DeleteWorkItemTypeMutation

    field :generate_project_cache, mutation: Mutations::GenerateProjectCacheMutation
    field :generate_replenishing_cache, mutation: Mutations::GenerateReplenishingCacheMutation

    field :me, Types::UserType, null: false
    field :send_auth_token, mutation: Mutations::SendAuthTokenMutation

    field :update_initiative, mutation: Mutations::UpdateInitiativeMutation
    field :update_team_member, mutation: Mutations::UpdateTeamMemberMutation

    field :save_membership, mutation: Mutations::SaveMembershipMutation

    field :create_portfolio_unit, mutation: Mutations::CreatePortfolioUnitMutation

    field :delete_demand, mutation: Mutations::DeleteDemandMutation

    field :discard_demand, mutation: Mutations::DiscardDemandMutation

    field :update_portfolio_unit, mutation: Mutations::UpdatePortfolioUnitMutation

    field :create_service_delivery_review, mutation: Mutations::CreateServiceDeliveryReviewMutation

    field :delete_service_delivery_review, mutation: Mutations::DeleteServiceDeliveryReviewMutation

    field :create_service_delivery_review_action, mutation: Mutations::CreateServiceDeliveryReviewActionMutation

    field :update_jira_project_config, mutation: Mutations::UpdateJiraProjectConfigMutation

    def me
      context[:current_user]
    end
  end
end
