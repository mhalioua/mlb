class TeamController < ApplicationController
  def index
    @teams = Team.all
  end

  def show
    id = params[:id]
    @team = Team.find_by(id: id)
    @games = Game.where(home_team: id).or(Game.where(away_team: id)).order('game_date DESC').limit(50)
  end
end