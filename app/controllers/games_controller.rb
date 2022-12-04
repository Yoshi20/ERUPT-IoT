class GamesController < ApplicationController
  before_action :authenticate_user!, except: [:index_for_iframe]
  before_action :get_games, only: [:index, :index_for_iframe]
  before_action { @section = 'games' }

  # GET /games
  def index
  end

  # GET /games_for_iframe
  def index_for_iframe
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
      @games << app if app['AppType'] == "Game"
      # @programs << app if app['AppType'] == "Program"
      # @settings << app if app['AppType'] == "Setting"
    end
    @games = @games.sort_by { |game| game["Name"] }
  end

end
