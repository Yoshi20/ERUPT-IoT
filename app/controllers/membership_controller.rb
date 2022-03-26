class MembershipController < ApplicationController
  before_action :authenticate_user!
  before_action { @section = 'membership' }

  # GET /membership
  # GET /membership.json
  def index
  end

end
