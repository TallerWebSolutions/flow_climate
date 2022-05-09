class ProjectAdditionalHoursController < AuthenticatedController
  before_action :assign_company

  def new
    prepend_view_path Rails.root.join('public')
    render 'spa-build/index'
  end
end
