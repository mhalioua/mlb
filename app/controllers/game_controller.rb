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

		@forecasts = @game.weathers.where(station: "Forecast").order(:hour)
		@weathers = @game.weathers.where(station: "Actual").order(:hour)
	end
end
