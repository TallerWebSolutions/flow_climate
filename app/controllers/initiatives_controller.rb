# frozen_string_literal: true

class InitiativesController < AuthenticatedController
  before_action :assign_company

  def index
    @initiatives = @company.initiatives.order(start_date: :desc)
  end
end
