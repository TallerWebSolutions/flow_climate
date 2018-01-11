module ApplicationHelper
  def alert
    render('layouts/alert', message: flash[:alert].html_safe) if flash[:alert]
  end

  def notice
    render('layouts/notice', message: flash[:notice].html_safe) if flash[:notice]
  end

  def error
    render('layouts/error', message: flash[:error].html_safe) if flash[:error]
  end
end
