class GameController < ApplicationController
	before_action :confirm_logged_in

	def new
		@game = Game.find_by_id(params[:id])
		@game_day = @game.game_day

		@away_team = @game.away_team
		@home_team = @game.home_team
		@image_url = @home_team.id.to_s + ".png"

		month = Date::MONTHNAMES[@game_day.month]
		day = @game_day.day.to_s
		@date = "#{month} #{day}"
	end
end
