class GameController < ApplicationController
	before_action :confirm_logged_in, except: ["new"]

	def new
		@game = Game.find_by_id(params[:id])
		@game_stats = @game.game_stats
		@game_day = @game.game_day
		@season = @game_day.season

		@away_team = @game.away_team
		@home_team = @game.home_team
		@stadium_team = @game.stadium_team ? @game.stadium_team : @game.home_team
		@head = @away_team.espn_abbr + " @ " + @home_team.espn_abbr
		@image_url = @stadium_team.id.to_s + ".png"

		year = @game_day.year.to_s
		month = Date::MONTHNAMES[@game_day.month.to_i]
		day = @game_day.day.to_s
		@date = "#{month} #{day} #{year}"

		@away_starting_lancer = @game.lancers.where(team: @away_team, starter: true, season_id: @season.id)
		@home_starting_lancer = @game.lancers.where(team: @home_team, starter: true, season_id: @season.id)

		unless @away_starting_lancer.empty?
			@home_left = @away_starting_lancer.first.throwhand == "L"
			@home_batters = @away_starting_lancer.first.opposing_lineup
			if @home_batters.empty?
			  @home_predicted = "Predicted "
			  @home_batters = @away_starting_lancer.first.predict_opposing_lineup
			end
		else
			@home_batters = []
		end

		unless @home_starting_lancer.empty?
			@away_left = @home_starting_lancer.first.throwhand == "L"
			@away_batters = @home_starting_lancer.first.opposing_lineup
			if @away_batters.empty?
			  @away_predicted = "Predicted "
			  @away_batters = @home_starting_lancer.first.predict_opposing_lineup
			end
		else
			@away_batters = []
		end

		@away_bullpen_lancers = @game.lancers.where(team_id: @away_team.id, bullpen: true, season_id: @season.id)
		@home_bullpen_lancers = @game.lancers.where(team_id: @home_team.id, bullpen: true, season_id: @season.id)

		@forecast = params[:forecast].to_i
		@forecasts = @game.weathers.where(station: "Forecast", hour: 1).order("updated_at DESC").to_a

		@forecast_dropdown = []
		@forecasts.each_with_index do |forecast_one, index|
			next if index % 2 == 1
			break if index == 20
			@forecast_dropdown << [forecast_one.updated_at.advance(hours: @stadium_team.timezone).in_time_zone('Eastern Time (US & Canada)').strftime("%F %I:%M%p"), index]
		end

		@forecast_one = @game.weathers.where(station: "Forecast", hour: 1).order("updated_at DESC").offset(@forecast)
		@forecast_two = @game.weathers.where(station: "Forecast", hour: 2).order("updated_at DESC").offset(@forecast)
		@forecast_three = @game.weathers.where(station: "Forecast", hour: 3).order("updated_at DESC").offset(@forecast)
		@forecast_four = @game.weathers.where(station: "Forecast", hour: 4).order("updated_at DESC").offset(@forecast)
		@forecasts = [@forecast_one.first, @forecast_two.first, @forecast_three.first, @forecast_four.first]

		@forecast_pre_one = @game.weathers.where(station: "Forecast", hour: -1).order("updated_at DESC").offset(@forecast)
		@forecast_pre_two = @game.weathers.where(station: "Forecast", hour: 0).order("updated_at DESC").offset(@forecast)
		@forecast_after_one = @game.weathers.where(station: "Forecast", hour: 5).order("updated_at DESC").offset(@forecast)
		@additionalForecasts = [@forecast_pre_one.first, @forecast_pre_two.first, @forecast_one.first, @forecast_two.first, @forecast_three.first, @forecast_four.first, @forecast_after_one.first]

		@weathers = @game.weathers.where(station: "Actual").order(:hour)
		@additional = params[:option].to_i
    if @forecast_one.first
		  @weather_forecasts = @game.weathersources.where(table_number: 0, date: @forecast_one.first.updated_at.advance(hours: @stadium_team.timezone).in_time_zone('Eastern Time (US & Canada)').strftime("%F %I:%M%p")).order(:row_number)
		  @weather_previous = @game.weathersources.where(table_number: 1, date: @forecast_one.first.updated_at.advance(hours: @stadium_team.timezone).in_time_zone('Eastern Time (US & Canada)').strftime("%F %I:%M%p")).order(:row_number)
    end
		@weather_actual = @game.weathersources.where(table_number: 2).order(:row_number)

		@away_starting_lancer_previous = @game.prevpitchers.where(away: true).order(:start_index)
		@home_starting_lancer_previous = @game.prevpitchers.where(away: false).order(:start_index)

		@away_hitters = @game.hitters.where(team_id: @away_team.id).order(:index)
		@home_hitters = @game.hitters.where(team_id: @home_team.id).order(:index)

		@playbyplay = @game.playbyplays.first

		@wind_dirs = []
		@weathers.each do |weather|
			@wind_dirs.push(weather.wind_dir)
		end

		@offset = 5
		@offset = params[:offset].to_i if params[:offset].present?

		@umpires = Umpire.where("statfox = ? AND count is not NULL", @game.ump).order("year ASC")
	end

	def weather
		@game = Game.find_by_id(params[:id])
		@game_day = @game.game_day
		@game_stats = @game.game_stats

		@away_team = @game.away_team
		@home_team = @game.home_team
		@stadium_team = @game.stadium_team ? @game.stadium_team : @game.home_team
		@head = @away_team.espn_abbr + " @ " + @home_team.espn_abbr
		@image_url = @stadium_team.id.to_s + ".png"

		year = @game_day.year.to_s
		month = Date::MONTHNAMES[@game_day.month.to_i]
		day = @game_day.day.to_s
		@date = "#{month} #{day} #{year}"

		@forecast = params[:forecast].to_i
		@forecasts = @game.weathers.where(station: "Forecast", hour: 1).order("updated_at DESC").to_a

		@forecast_dropdown = []
		@forecasts.each_with_index do |forecast_one, index|
			next if index % 2 == 1
			break if index == 20
			@forecast_dropdown << [forecast_one.updated_at.advance(hours: @stadium_team.timezone).in_time_zone('Eastern Time (US & Canada)').strftime("%F %I:%M%p"), index]
		end

		@forecast_one = @game.weathers.where(station: "Forecast", hour: 1).order("updated_at DESC").offset(@forecast)
		@forecast_two = @game.weathers.where(station: "Forecast", hour: 2).order("updated_at DESC").offset(@forecast)
		@forecast_three = @game.weathers.where(station: "Forecast", hour: 3).order("updated_at DESC").offset(@forecast)
		@forecast_four = @game.weathers.where(station: "Forecast", hour: 4).order("updated_at DESC").offset(@forecast)
		@forecasts = [@forecast_one.first, @forecast_two.first, @forecast_three.first, @forecast_four.first]

		@forecast_pre_one = @game.weathers.where(station: "Forecast", hour: -1).order("updated_at DESC").offset(@forecast)
		@forecast_pre_two = @game.weathers.where(station: "Forecast", hour: 0).order("updated_at DESC").offset(@forecast)
		@forecast_after_one = @game.weathers.where(station: "Forecast", hour: 5).order("updated_at DESC").offset(@forecast)
		@additionalForecasts = [@forecast_pre_one.first, @forecast_pre_two.first, @forecast_one.first, @forecast_two.first, @forecast_three.first, @forecast_four.first, @forecast_after_one.first]

		@weathers = @game.weathers.where(station: "Actual").order(:hour)
		@additional = params[:option].to_i
    if @forecast_one.first
      @weather_forecasts = @game.weathersources.where(table_number: 0, date: @forecast_one.first.updated_at.advance(hours: @stadium_team.timezone).in_time_zone('Eastern Time (US & Canada)').strftime("%F %I:%M%p")).order(:row_number)
      @weather_previous = @game.weathersources.where(table_number: 1, date: @forecast_one.first.updated_at.advance(hours: @stadium_team.timezone).in_time_zone('Eastern Time (US & Canada)').strftime("%F %I:%M%p")).order(:row_number)
    end
		@weather_actual = @game.weathersources.where(table_number: 2).order(:row_number)

		@offset = 5
		@offset = params[:offset].to_i if params[:offset].present?

		@umpires = Umpire.where("statfox = ? AND count is not NULL", @game.ump).order("year ASC")
	end

	def stats
		@game = Game.find_by_id(params[:id])
		@game_day = @game.game_day
		@season = @game_day.season
		@game_stats = @game.game_stats

		@away_team = @game.away_team
		@home_team = @game.home_team
		@stadium_team = @game.stadium_team ? @game.stadium_team : @game.home_team
		@head = @away_team.espn_abbr + " @ " + @home_team.espn_abbr

		year = @game_day.year.to_s
		month = Date::MONTHNAMES[@game_day.month.to_i]
		day = @game_day.day.to_s
		@date = "#{month} #{day} #{year}"

		@away_starting_lancer = @game.lancers.where(team: @away_team, starter: true, season_id: @season.id)
		@home_starting_lancer = @game.lancers.where(team: @home_team, starter: true, season_id: @season.id)

		@home_transactions = Transaction.where(team_id: @home_team.id).order("updated_at DESC").limit(20)
		@away_transactions = Transaction.where(team_id: @away_team.id).order("updated_at DESC").limit(20)

		unless @away_starting_lancer.empty?
			@home_left = @away_starting_lancer.first.throwhand == "L"
			@home_batters = @away_starting_lancer.first.opposing_lineup
			if @home_batters.empty?
			  @home_predicted = "Predicted "
			  @home_batters = @away_starting_lancer.first.predict_opposing_lineup
			end
		else
			@home_batters = []
		end

		unless @home_starting_lancer.empty?
			@away_left = @home_starting_lancer.first.throwhand == "L"
			@away_batters = @home_starting_lancer.first.opposing_lineup
			if @away_batters.empty?
			  @away_predicted = "Predicted "
			  @away_batters = @home_starting_lancer.first.predict_opposing_lineup
			end
		else
			@away_batters = []
		end

		@away_bullpen_lancers = @game.lancers.where(team_id: @away_team.id, bullpen: true, season_id: @season.id)
		@home_bullpen_lancers = @game.lancers.where(team_id: @home_team.id, bullpen: true, season_id: @season.id)

		@away_hitters = @game.hitters.where(team_id: @away_team.id).order(:index)
		@home_hitters = @game.hitters.where(team_id: @home_team.id).order(:index)

		@playbyplay = @game.playbyplays.first

		@umpires = Umpire.where("statfox = ? AND count is not NULL", @game.ump).order("year ASC")
	end

	def previous
		@game = Game.find_by_id(params[:id])
		@game_day = @game.game_day
		@season = @game_day.season
		@game_stats = @game.game_stats

		@away_team = @game.away_team
		@home_team = @game.home_team
		@stadium_team = @game.stadium_team ? @game.stadium_team : @game.home_team
		@head = @away_team.espn_abbr + " @ " + @home_team.espn_abbr

		year = @game_day.year.to_s
		month = Date::MONTHNAMES[@game_day.month.to_i]
		day = @game_day.day.to_s
		@date = "#{month} #{day} #{year}"

		@away_starting_lancer = @game.lancers.where(team: @away_team, starter: true, season_id: @season.id)
		@home_starting_lancer = @game.lancers.where(team: @home_team, starter: true, season_id: @season.id)

		@away_starting_lancer_previous = @game.prevpitchers.where(away: true).order(:start_index)
		@home_starting_lancer_previous = @game.prevpitchers.where(away: false).order(:start_index)

		@umpires = Umpire.where("statfox = ? AND count is not NULL", @game.ump).order("year ASC")
	end

	def scout
		@game = Game.find_by_id(params[:id])
		@game_stats = @game.game_stats
		@game_day = @game.game_day
		@season = @game_day.season

		@away_team = @game.away_team
		@home_team = @game.home_team
		@stadium_team = @game.stadium_team ? @game.stadium_team : @game.home_team
		@head = @away_team.espn_abbr + " @ " + @home_team.espn_abbr
		@image_url = @stadium_team.id.to_s + ".png"

		year = @game_day.year.to_s
		month = Date::MONTHNAMES[@game_day.month.to_i]
		day = @game_day.day.to_s
		@date = "#{month} #{day} #{year}"

		@away_starting_lancer = @game.lancers.where(team: @away_team, starter: true, season_id: @season.id)
		@home_starting_lancer = @game.lancers.where(team: @home_team, starter: true, season_id: @season.id)

		unless @away_starting_lancer.empty?
			@home_left = @away_starting_lancer.first.throwhand == "L"
			@home_batters = @away_starting_lancer.first.opposing_lineup
			if @home_batters.empty?
				@home_predicted = "Predicted "
				@home_batters = @away_starting_lancer.first.predict_opposing_lineup
			end
		else
			@home_batters = []
		end

		unless @home_starting_lancer.empty?
			@away_left = @home_starting_lancer.first.throwhand == "L"
			@away_batters = @home_starting_lancer.first.opposing_lineup
			if @away_batters.empty?
				@away_predicted = "Predicted "
				@away_batters = @home_starting_lancer.first.predict_opposing_lineup
			end
		else
			@away_batters = []
		end

		@umpires = Umpire.where("statfox = ? AND count is not NULL", @game.ump).order("year ASC")
	end

	def lr
		@game = Game.find_by_id(params[:id])
		@game_stats = @game.game_stats
		@game_day = @game.game_day
		@season = @game_day.season

		@away_team = @game.away_team
		@home_team = @game.home_team
		@stadium_team = @game.stadium_team ? @game.stadium_team : @game.home_team
		@head = @away_team.espn_abbr + " @ " + @home_team.espn_abbr
		@image_url = @stadium_team.id.to_s + ".png"

		year = @game_day.year.to_s
		month = Date::MONTHNAMES[@game_day.month.to_i]
		day = @game_day.day.to_s
		@date = "#{month} #{day} #{year}"

		@weathers = @game.weathers.where(station: "Actual").order(:hour)
		@wind_dirs = []
		@weathers.each do |weather|
			@wind_dirs.push(weather.wind_dir)
		end

		@umpires = Umpire.where("statfox = ? AND count is not NULL", @game.ump).order("year ASC")
	end
end
