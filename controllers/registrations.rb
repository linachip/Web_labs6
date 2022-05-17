require_relative '../models/user'

class RegistrationsController < BaseController
  def new
    render 'new_registration.html'
  end

  def create
    user = User.new(params)
    if user.save
      redirect_to '/'
    else
      set_cookie('errors', 'message', user.errors.full_messages.join(', '))
      render 'new_registration.html'
    end
  end
end
