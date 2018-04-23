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
	  	game_day = Date.strptime(@game_start_index, '%Y-%m-%d')
		@head = "#{game_day.strftime("%B")} #{game_day.strftime("%e").ordinalize}"
		@games = game_day.games.sort_by{|game| (DateTime.parse(game.game_date) - game.home_team.timezone.hours) }
	end
end
