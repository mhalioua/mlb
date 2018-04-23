class IndexController < ApplicationController
	before_action :confirm_logged_in

	def home
		@yesterday = Time.now - 1.days
    	@today = Time.now
    	@tomorrow = Time.now + 1.days
	end

	def game
	  	unless params[:id]
	  	  	params[:id] = Time.now.strftime("%Y-%m-%d") + " - " + Time.now.strftime("%Y-%m-%d")
	  	end
		@game_index = params[:id]
	  	@game_start_index = @game_index[0..9]
	  	@game_end_index = @game_index[13..23]

	  	@gameDays = GameDay.where("date between ? and ?", Date.strptime(@game_start_index).beginning_of_day, Date.strptime(@game_end_index).end_of_day)

		@head = "#{Date::MONTHNAMES[game_day.month]} #{game_day.day.ordinalize}"
		@games = @gameDays.games.sort_by{|game| (DateTime.parse(game.game_date) - game.home_team.timezone.hours) }
	end
end
