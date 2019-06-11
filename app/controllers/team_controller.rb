class TeamController < ApplicationController
  def index
    @teams = Team.all.order('name')
  end

  def show
    id = params[:id]
    @team = Team.find_by(id: id)
    @games = Game.where("home_team_id = ? AND game_date < ? AND id > 10516", id, Date.current).or(Game.where("home_team_id = ? AND game_date < ? AND id < 10070 AND id >= 9058", id, Date.current)).order('game_date DESC').limit(50)
  end

  def filter
    @teams = Team.all.order('name')
    @games = Game.where("game_date < ? AND id > 10516", Date.current).or(Game.where("game_date < ? AND id < 10070 AND id >= 9058", Date.current)).order('game_date DESC')
    @team_id = nil
    @wind_dir = nil
    @wind_speed = nil
    @baro = nil
    @games = @games.select {|game|
      forecast_one = game.weathers.where(station: "Forecast", hour: 1).order("updated_at DESC").offset(1)
      forecast_two = game.weathers.where(station: "Forecast", hour: 2).order("updated_at DESC").offset(1)
      forecast_thr = game.weathers.where(station: "Forecast", hour: 3).order("updated_at DESC").offset(1)
      forecast_for = game.weathers.where(station: "Forecast", hour: 4).order("updated_at DESC").offset(1)

      if params[:team_id].present? && params[:team_id]
        @team_id = params[:team_id]
        is_filter = false
        is_filter = true if game.home_team_id === @team_id
        return false if is_filter === false
      end

      if params[:wind_dir].present? && params[:wind_dir]
        @wind_dir = params[:wind_dir]
        is_filter = false
        is_filter = true if forecast_one.wind_dir === @wind_dir
        is_filter = true if forecast_two.wind_dir === @wind_dir
        is_filter = true if forecast_thr.wind_dir === @wind_dir
        is_filter = true if forecast_for.wind_dir === @wind_dir
        return false if is_filter === false
      end

      if params[:wind_speed].present? && params[:wind_speed]
        @wind_speed = params[:wind_speed]
        is_filter = false
        is_filter = true if forecast_one.wind_speed >= @wind_speed - 3 && forecast_one.wind_speed <= @wind_speed + 3
        is_filter = true if forecast_two.wind_speed >= @wind_speed - 3 && forecast_two.wind_speed <= @wind_speed + 3
        is_filter = true if forecast_thr.wind_speed >= @wind_speed - 3 && forecast_thr.wind_speed <= @wind_speed + 3
        is_filter = true if forecast_for.wind_speed >= @wind_speed - 3 && forecast_for.wind_speed <= @wind_speed + 3
        return false if is_filter === false
      end

      if params[:baro].present? && params[:baro]
        @baro = params[:baro]
        is_filter = false
        is_filter = true if forecast_one.pressure_num >= (@baro - 0.04).round(2) && forecast_one.pressure_num <= (@baro + 0.04).round(2)
        is_filter = true if forecast_two.pressure_num >= (@baro - 0.04).round(2) && forecast_two.pressure_num <= (@baro + 0.04).round(2)
        is_filter = true if forecast_thr.pressure_num >= (@baro - 0.04).round(2) && forecast_thr.pressure_num <= (@baro + 0.04).round(2)
        is_filter = true if forecast_for.pressure_num >= (@baro - 0.04).round(2) && forecast_for.pressure_num <= (@baro + 0.04).round(2)
        return false if is_filter === false
      end

      return true
    }
    @games = @games[0..50]
  end
end