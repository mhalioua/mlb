class IndexController < ApplicationController
	before_action :confirm_logged_in

	def home
		@yesterday = GameDay.yesterday
		@today = GameDay.today
		@tomorrow = GameDay.tomorrow
	end

	def game
		game_day = GameDay.find(params[:id])
		@head = "#{Date::MONTHNAMES[game_day.month]} #{game_day.day.ordinalize}"
		@games = game_day.games.sort_by{|game| (DateTime.parse(game.game_date) - game.home_team.timezone.hours) }
	end
end
