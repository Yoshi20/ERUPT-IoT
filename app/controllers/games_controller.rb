class GamesController < ApplicationController
  before_action :authenticate_user!, except: [:index_for_iframe]
  before_action :get_games, only: [:index, :index_for_iframe]
  before_action { @section = 'games' }

  # GET /games
  def index
  end

  # GET /games_for_iframe
  def index_for_iframe
    response.headers["X-FRAME-OPTIONS"] = "ALLOWALL"  # prevent CORS issues
    render "index", layout: "for_iframe"
  end

  # GET /games_refresh
  def refresh
    Rails.cache.delete("ggleap_apps")
    redirect_to games_path
  end

private

  def get_games
    jwt = Request::ggleap_auth
    ggleap_apps = Request::ggleap_apps(jwt)
    @games = []
    ggleap_apps.each do |app|
      if params['pc_group_uuid'].present?
        @games << app if app['AppType'] == "Game" && params['pc_group_uuid'].in?(app['EnabledPcGroups'])
        # PC games:       /games?pc_group_uuid=da13c17c-9a03-4922-ae17-cb5820246c47
        # Console games:  /games?pc_group_uuid=7f362b3b-5cf0-43d4-90ff-50911eddbee1
      else
        @games << app if app['AppType'] == "Game"
        # @programs << app if app['AppType'] == "Program"
        # @settings << app if app['AppType'] == "Setting"
      end
    end
    @games = @games.sort_by { |game| game["Rank"] }
  end

end
