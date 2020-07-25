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
    @hum = nil
    @games = []
    if params[:team_id].present?
      @result.each do |game|
        if params[:team_id] != ''
          @team_id = params[:team_id].to_i
          is_filter = false
          is_filter = true if game.home_team_id == @team_id || @team_id == 0
          next if is_filter === false
        end

        forecast_one = game.weathers.where(station: "Forecast", hour: 1).order("updated_at DESC").offset(1).first
        next unless forecast_one
        forecast_two = game.weathers.where(station: "Forecast", hour: 2).order("updated_at DESC").offset(1).first
        next unless forecast_two
        forecast_thr = game.weathers.where(station: "Forecast", hour: 3).order("updated_at DESC").offset(1).first
        next unless forecast_thr
        forecast_for = game.weathers.where(station: "Forecast", hour: 4).order("updated_at DESC").offset(1).first
        next unless forecast_for

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
          forecast_one_wind_speed = forecast_one.wind_speed.to_i
          forecast_two_wind_speed = forecast_two.wind_speed.to_i
          forecast_thr_wind_speed = forecast_thr.wind_speed.to_i
          forecast_for_wind_speed = forecast_for.wind_speed.to_i
          is_filter = true if forecast_one && forecast_one_wind_speed >= @wind_speed - 3 && forecast_one_wind_speed <= @wind_speed + 3
          is_filter = true if forecast_two && forecast_two_wind_speed >= @wind_speed - 3 && forecast_two_wind_speed <= @wind_speed + 3
          is_filter = true if forecast_thr && forecast_thr_wind_speed >= @wind_speed - 3 && forecast_thr_wind_speed <= @wind_speed + 3
          is_filter = true if forecast_for && forecast_for_wind_speed >= @wind_speed - 3 && forecast_for_wind_speed <= @wind_speed + 3
          next if is_filter === false
        end

        if params[:baro].present? && params[:baro] != ''
          @baro = params[:baro].to_f
          is_filter = false
          forecast_one_pressure_num = forecast_one.pressure_num
          forecast_two_pressure_num = forecast_two.pressure_num
          forecast_thr_pressure_num = forecast_thr.pressure_num
          forecast_for_pressure_num = forecast_for.pressure_num
          is_filter = true if forecast_one && forecast_one_pressure_num >= (@baro - 0.04).round(2) && forecast_one_pressure_num <= (@baro + 0.04).round(2)
          is_filter = true if forecast_two && forecast_two_pressure_num >= (@baro - 0.04).round(2) && forecast_two_pressure_num <= (@baro + 0.04).round(2)
          is_filter = true if forecast_thr && forecast_thr_pressure_num >= (@baro - 0.04).round(2) && forecast_thr_pressure_num <= (@baro + 0.04).round(2)
          is_filter = true if forecast_for && forecast_for_pressure_num >= (@baro - 0.04).round(2) && forecast_for_pressure_num <= (@baro + 0.04).round(2)
          next if is_filter === false
        end

        if params[:dp].present? && params[:dp] != ''
          @dp = params[:dp].to_f
          is_filter = false
          forecast_one_dew_num = forecast_one.dew_num
          forecast_two_dew_num = forecast_two.dew_num
          forecast_thr_dew_num = forecast_thr.dew_num
          forecast_for_dew_num = forecast_for.dew_num
          is_filter = true if forecast_one && forecast_one_dew_num >= (@dp - 2).round(2) && forecast_one_dew_num <= (@dp + 2).round(2)
          is_filter = true if forecast_two && forecast_two_dew_num >= (@dp - 2).round(2) && forecast_two_dew_num <= (@dp + 2).round(2)
          is_filter = true if forecast_thr && forecast_thr_dew_num >= (@dp - 2).round(2) && forecast_thr_dew_num <= (@dp + 2).round(2)
          is_filter = true if forecast_for && forecast_for_dew_num >= (@dp - 2).round(2) && forecast_for_dew_num <= (@dp + 2).round(2)
          next if is_filter === false
        end

        if params[:hum].present? && params[:hum] != ''
          @hum = params[:hum].to_f
          is_filter = false
          forecast_one_humid_num = forecast_one.humid_num
          forecast_two_humid_num = forecast_two.humid_num
          forecast_thr_humid_num = forecast_thr.humid_num
          forecast_for_humid_num = forecast_for.humid_num
          is_filter = true if forecast_one && forecast_one_humid_num >= (@hum - 5).round(2) && forecast_one_humid_num <= (@hum + 5).round(2)
          is_filter = true if forecast_two && forecast_two_humid_num >= (@hum - 5).round(2) && forecast_two_humid_num <= (@hum + 5).round(2)
          is_filter = true if forecast_thr && forecast_thr_humid_num >= (@hum - 5).round(2) && forecast_thr_humid_num <= (@hum + 5).round(2)
          is_filter = true if forecast_for && forecast_for_humid_num >= (@hum - 5).round(2) && forecast_for_humid_num <= (@hum + 5).round(2)
          next if is_filter === false
        end

        @games.push(game)
        break if @games.length === 30
      end
    end
  end
end