class TeamController < ApplicationController
  def index
    @teams = Team.all.order('name')
  end

  def show
    id = params[:id]
    @team = Team.find_by(id: id)
    @games = Game.where("home_team_id = ? AND game_date < ? AND id > 10654", id, Date.current).or(Game.where("home_team_id = ? AND game_date < ? AND id < 10070 AND id >= 9058", id, Date.current)).order('id DESC')
  end

  def filter
    unless params[:date]
      params[:date] = Time.now.strftime("%b %d, %Y") + " - " + Time.now.strftime("%b %d, %Y")
    end
    @game_index = params[:date]
    @game_start_index = @game_index[0..12]
    @game_end_index = @game_index[15..27]
    @teams = Team.all.order('name')
    # @result = Game.where("game_date < ? AND id > 10654 AND game_date between ? and ?", Date.current, Date.strptime(@game_start_index, '%b %d, %Y').beginning_of_day, Date.strptime(@game_end_index, '%b %d, %Y').end_of_day)
    #               .or(Game.where("game_date < ? AND id < 10070 AND id >= 9058 AND game_date between ? and ?", Date.current, Date.strptime(@game_start_index, '%b %d, %Y').beginning_of_day, Date.strptime(@game_end_index, '%b %d, %Y').end_of_day)).order('game_date DESC')
    @result = Game.where("game_date < ? AND id > 10654", Date.current)
                  .or(Game.where("game_date < ? AND id < 10070 AND id >= 9058", Date.current)).order('game_date DESC')
    @team_id = nil
    @wind_dir = nil
    @wind_speed = nil
    @baro = nil
    @dp = nil
    @games = []
    if params[:team_id].present? && params[:team_id] != ''
      @result.each do |game|
        if params[:team_id].present? && params[:team_id] != ''
          @team_id = params[:team_id].to_i
          is_filter = false
          is_filter = true if game.home_team_id == @team_id
          next if is_filter === false
        end

        forecast_one = game.weathers.where(station: "Forecast", hour: 1).order("updated_at DESC").offset(1).first
        forecast_two = game.weathers.where(station: "Forecast", hour: 2).order("updated_at DESC").offset(1).first
        forecast_thr = game.weathers.where(station: "Forecast", hour: 3).order("updated_at DESC").offset(1).first
        forecast_for = game.weathers.where(station: "Forecast", hour: 4).order("updated_at DESC").offset(1).first

        if params[:wind_dir].present? && params[:wind_dir] != ''
          @wind_dir = params[:wind_dir]
          is_filter = false
          is_filter = true if forecast_one && forecast_one.wind_dir.upcase === @wind_dir.upcase
          is_filter = true if forecast_two && forecast_two.wind_dir.upcase === @wind_dir.upcase
          is_filter = true if forecast_thr && forecast_thr.wind_dir.upcase === @wind_dir.upcase
          is_filter = true if forecast_for && forecast_for.wind_dir.upcase === @wind_dir.upcase
          next if is_filter === false
        end

        if params[:wind_speed].present? && params[:wind_speed] != ''
          @wind_speed = params[:wind_speed].to_i
          is_filter = false
          is_filter = true if forecast_one && forecast_one.wind_speed.to_i >= @wind_speed - 3 && forecast_one.wind_speed.to_i <= @wind_speed + 3
          is_filter = true if forecast_two && forecast_two.wind_speed.to_i >= @wind_speed - 3 && forecast_two.wind_speed.to_i <= @wind_speed + 3
          is_filter = true if forecast_thr && forecast_thr.wind_speed.to_i >= @wind_speed - 3 && forecast_thr.wind_speed.to_i <= @wind_speed + 3
          is_filter = true if forecast_for && forecast_for.wind_speed.to_i >= @wind_speed - 3 && forecast_for.wind_speed.to_i <= @wind_speed + 3
          next if is_filter === false
        end

        if params[:baro].present? && params[:baro] != ''
          @baro = params[:baro].to_f
          is_filter = false
          is_filter = true if forecast_one && forecast_one.pressure_num >= (@baro - 0.04).round(2) && forecast_one.pressure_num <= (@baro + 0.04).round(2)
          is_filter = true if forecast_two && forecast_two.pressure_num >= (@baro - 0.04).round(2) && forecast_two.pressure_num <= (@baro + 0.04).round(2)
          is_filter = true if forecast_thr && forecast_thr.pressure_num >= (@baro - 0.04).round(2) && forecast_thr.pressure_num <= (@baro + 0.04).round(2)
          is_filter = true if forecast_for && forecast_for.pressure_num >= (@baro - 0.04).round(2) && forecast_for.pressure_num <= (@baro + 0.04).round(2)
          next if is_filter === false
        end

        if params[:dp].present? && params[:dp] != ''
          @dp = params[:dp].to_f
          is_filter = false
          is_filter = true if forecast_one && forecast_one.dew_num >= (@dp - 3).round(2) && forecast_one.dew_num <= (@dp + 3).round(2)
          is_filter = true if forecast_two && forecast_two.dew_num >= (@dp - 3).round(2) && forecast_two.dew_num <= (@dp + 3).round(2)
          is_filter = true if forecast_thr && forecast_thr.dew_num >= (@dp - 3).round(2) && forecast_thr.dew_num <= (@dp + 3).round(2)
          is_filter = true if forecast_for && forecast_for.dew_num >= (@dp - 3).round(2) && forecast_for.dew_num <= (@dp + 3).round(2)
          next if is_filter === false
        end

        @games.push(game)
        # break if @games.length === 50
      end
    end
  end
end