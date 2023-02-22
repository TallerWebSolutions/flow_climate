# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_product_risk_review, mutation: Mutations::CreateProductRiskReview

    field :create_project_additional_hours, mutation: Mutations::CreateProjectAdditionalHoursMutation

    field :create_team, mutation: Mutations::CreateTeamMutation
    field :delete_team, mutation: Mutations::DeleteTeamMutation
    field :update_team, mutation: Mutations::UpdateTeamMutation

    field :create_work_item_type, mutation: Mutations::CreateWorkItemTypeMutation
    field :delete_work_item_type, mutation: Mutations::DeleteWorkItemTypeMutation

    field :generate_project_cache, mutation: Mutations::GenerateProjectCacheMutation
    field :generate_replenishing_cache, mutation: Mutations::GenerateReplenishingCacheMutation

    field :me, Types::UserType, null: false
    field :send_auth_token, mutation: Mutations::SendAuthTokenMutation

    field :update_initiative, mutation: Mutations::UpdateInitiativeMutation
    field :update_team_member, mutation: Mutations::UpdateTeamMemberMutation

    def me
      context[:current_user]
    end
  end
end
