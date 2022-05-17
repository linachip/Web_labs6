require_relative './base'

class HomeController < BaseController
  def index
    if current_user
      render 'index.html'
    else
      redirect_to '/sign_in'
    end
  end
end
