class TeamController < ApplicationController
  def index
    @teams = Team.all.order('name')
  end

  def show
    id = params[:id]
    @team = Team.find_by(id: id)
    @games = Game.where("home_team = ? AND game_date < ?", id, Date.today).or(Game.where("away_team = ? AND game_date < ?", id, Date.today)).order('game_date DESC').limit(50)
  end
end