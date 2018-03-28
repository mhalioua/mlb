class GameController < ApplicationController
	before_action :confirm_logged_in

	def new
		@game = Game.find_by_id(params[:id])
		@game_day = @game.game_day
		@season = @game_day.season

		@away_team = @game.away_team
		@home_team = @game.home_team
		@image_url = @home_team.id.to_s + ".png"

		month = Date::MONTHNAMES[@game_day.month]
		day = @game_day.day.to_s
		@date = "#{month} #{day}"

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
			@home_batters = Batter.none
		end

		unless @home_starting_lancer.empty?
			@away_left = @home_starting_lancer.first.throwhand == "L"
			@away_batters = @home_starting_lancer.first.opposing_lineup
			if @away_batters.empty?
			  @away_predicted = "Predicted "
			  @away_batters = @home_starting_lancer.first.predict_opposing_lineup
			end
		else
			@away_batters = Batter.none
		end

		@away_bullpen_lancers = @game.lancers.where(team_id: @away_team.id, bullpen: true, season_id: @season.id)
		@home_bullpen_lancers = @game.lancers.where(team_id: @home_team.id, bullpen: true, season_id: @season.id)

		@forecast = params[:forecast].to_i
		@forecasts = @game.weathers.where(station: "Forecast", hour: 2).order("updated_at DESC")

		@forecast_dropdown = []
		@forecasts.each_with_index do |forecast_one, index|
			@forecast_dropdown << [forecast_one.updated_at.advance(hours: @home_team.timezone).in_time_zone('Eastern Time (US & Canada)').strftime("%F %I:%M%p"), index/3]
		end

		@forecasts = @game.weathers.where(station: "Forecast").order("updated_at DESC").offset(@forecast*3).limit(3)
		@weathers = @game.weathers.where(station: "Actual").order(:hour)
	end
end
