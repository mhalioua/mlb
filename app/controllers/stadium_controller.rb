class StadiumController < ApplicationController
  def index
    @teams = Team.all.order('name')
  end

  def show
    id = params[:id]
    @team = Team.find_by(id: id)
  end
end
