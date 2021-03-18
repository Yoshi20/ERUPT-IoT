class HomeController < ApplicationController
  before_action :authenticate_user!
  before_action { @section = 'home' }

  # GET /home
  # GET /home.json
  def index
  end

end
