class TeamController < ApplicationController
  def index
    @teams = Team.all.order('name')
  end

  def show
    id = params[:id]
    @team = Team.find_by(id: id)
    @games = Game.where("home_team_id = ? AND game_date < ?", id, Date.current).order('game_date DESC').limit(50)
  end
end